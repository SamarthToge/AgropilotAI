import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/chat_message.dart';
import '../providers/app_state.dart';
import '../providers/sensor_provider.dart';
import '../providers/history_provider.dart';
import '../services/gemini_chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _dotController;

  static const _suggestions = [
    "🌡️ What's wrong with my crop?",
    "💧 Should I water my plants?",
    "📅 When should I harvest?",
    "📈 How to improve yield?",
    "🌿 Tips for this growth stage?",
  ];

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Initialize the Gemini service with live context from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
      _addWelcomeMessage();
    });
  }

  void _initializeChat() {
    final appState = context.read<AppState>();
    final sensors = context.read<SensorProvider>();
    final history = context.read<HistoryProvider>();

    GeminiChatService.instance.initialize(
      cropType: appState.cropType,
      growthStage: appState.growthStage,
      daysPlanted: appState.daysPlanted,
      totalDays: appState.totalDays,
      temperature: sensors.temperature,
      humidity: sensors.humidity,
      co2: sensors.co2,
      soilMoisture: sensors.soilMoisture,
      activeAlertCount: history.activeAlerts.length,
      predictedYield: appState.predictedYield,
      targetYield: appState.targetYield,
    );
  }

  void _addWelcomeMessage() {
    final appState = context.read<AppState>();
    setState(() {
      _messages.add(ChatMessage(
        text:
            "👋 Hello! I'm your AgroPilot Assistant.\n\nI can see your **${appState.cropType}** is in the **${appState.growthStage}** stage (Day ${appState.daysPlanted} of ${appState.totalDays}).\n\nAsk me anything about your greenhouse — crop health, watering, CO₂ levels, harvest timing, and more!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    final reply = await GeminiChatService.instance.sendMessage(text.trim());

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length +
                  (_isTyping ? 1 : 0) +
                  (_messages.length == 1 ? 1 : 0),
              itemBuilder: (ctx, i) {
                // Show suggestions below welcome message
                if (_messages.length == 1 && i == 1) {
                  return _SuggestionChips(
                    suggestions: _suggestions,
                    onTap: _sendMessage,
                  );
                }

                // Typing indicator
                if (_isTyping && i == _messages.length + (_messages.length == 1 ? 1 : 0)) {
                  return _TypingIndicator(controller: _dotController);
                }

                // Adjust index for suggestions row
                final adjustedIndex =
                    (_messages.length == 1 && i > 0) ? i - 1 : i;

                if (adjustedIndex >= _messages.length) return const SizedBox();
                final msg = _messages[adjustedIndex];
                return _MessageBubble(message: msg);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌾', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AgroPilot Assistant',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Powered by Gemini AI',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Reset conversation',
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            GeminiChatService.instance.resetSession();
            setState(() => _messages.clear());
            _addWelcomeMessage();
          },
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _inputCtrl,
                onSubmitted: _sendMessage,
                maxLines: null,
                textInputAction: TextInputAction.send,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask about your crop…',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_inputCtrl.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ─────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🌾', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Typing Indicator ───────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  final AnimationController controller;
  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child:
                const Center(child: Text('🌾', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, child) {
                return Row(
                  children: List.generate(3, (i) {
                    final delay = i / 3;
                    final value = (controller.value - delay).clamp(0.0, 1.0);
                    final opacity = (value < 0.5
                            ? value / 0.5
                            : (1.0 - value) / 0.5)
                        .clamp(0.3, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion Chips ───────────────────────────────────────────────────────────
class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;

  const _SuggestionChips({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions
            .map(
              (s) => GestureDetector(
                onTap: () => onTap(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
