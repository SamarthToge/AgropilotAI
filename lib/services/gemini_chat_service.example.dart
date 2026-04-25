import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

/// ⚠️  SETUP REQUIRED
/// ------------------
/// 1. Copy this file and rename it to: gemini_chat_service.dart
/// 2. Replace 'YOUR_GEMINI_API_KEY_HERE' with your actual API key
/// 3. Get a free key at: https://aistudio.google.com/app/apikey
///
/// The real gemini_chat_service.dart is git-ignored to protect your API key.

class GeminiChatService {
  GeminiChatService._();
  static final GeminiChatService instance = GeminiChatService._();

  // 🔑 Replace with your key from https://aistudio.google.com/app/apikey
  static const _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  // Try models in order — falls back if one is unavailable
  static const _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash-001',
    'gemini-2.0-flash-lite-001',
    'gemini-2.5-pro',
  ];

  String _systemPrompt = '';
  final List<Map<String, dynamic>> _history = [];
  bool _initialized = false;

  void initialize({
    required String cropType,
    required String growthStage,
    required int daysPlanted,
    required int totalDays,
    required double temperature,
    required double humidity,
    required double co2,
    required double soilMoisture,
    required int activeAlertCount,
    required double predictedYield,
    required double targetYield,
  }) {
    _systemPrompt = '''
You are AgroPilot Assistant — a knowledgeable, friendly AI advisor for greenhouse farmers.
You specialize in crop health, environmental conditions, yield optimization, and harvest planning.

Current farm context (use this to give personalized advice):
- Crop: $cropType
- Growth Stage: $growthStage (Day $daysPlanted of $totalDays)
- Temperature: ${temperature.toStringAsFixed(1)}°C
- Humidity: ${humidity.toStringAsFixed(1)}%
- CO₂ Level: ${co2.toStringAsFixed(0)} ppm
- Soil Moisture: ${soilMoisture.toStringAsFixed(1)}%
- Active Alerts: $activeAlertCount
- Predicted Yield: ${predictedYield.toStringAsFixed(2)} kg/m²
- Target Yield: ${targetYield.toStringAsFixed(2)} kg/m²

Rules:
- Keep answers concise, practical, and actionable
- Use emojis occasionally to make responses friendly
- Always reference the actual sensor values when relevant
- If something is out of range, clearly say what action to take
- Respond in the same language the user writes in
''';
    _history.clear();
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  Future<String> sendMessage(String userText) async {
    if (!_initialized) {
      return "⚠️ Chatbot not initialized. Please restart the app.";
    }

    _history.add({
      'role': 'user',
      'parts': [{'text': userText}],
    });

    String lastError = 'Unknown error';
    for (final model in _models) {
      try {
        dev.log('[GeminiChat] Trying model: $model', name: 'GeminiChatService');
        final reply = await _callGemini(model);
        if (reply != null) {
          _history.add({
            'role': 'model',
            'parts': [{'text': reply}],
          });
          return reply;
        }
      } catch (e) {
        lastError = e.toString().replaceFirst('Exception: ', '');
        dev.log('[GeminiChat] Model $model failed: $lastError', name: 'GeminiChatService');
        continue;
      }
    }

    if (_history.isNotEmpty) _history.removeLast();
    return "⚠️ AI unavailable: $lastError";
  }

  Future<String?> _callGemini(String model) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      'system_instruction': {
        'parts': [{'text': _systemPrompt}],
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 512,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String?;
        }
      }
      return null;
    }

    Map<String, dynamic> errorBody = {};
    try {
      errorBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    final errorMsg = (errorBody['error']?['message'] ?? '').toString().toLowerCase();

    if (errorMsg.contains('quota') || errorMsg.contains('rate') ||
        response.statusCode == 429) {
      return null;
    }

    final humanError = errorBody['error']?['message'] ?? 'HTTP ${response.statusCode}';
    throw Exception(humanError);
  }

  void resetSession() {
    _history.clear();
  }
}
