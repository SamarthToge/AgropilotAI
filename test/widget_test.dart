import 'package:flutter_test/flutter_test.dart';
import 'package:agropilot_ai/main.dart';
import 'package:provider/provider.dart';
import 'package:agropilot_ai/providers/app_state.dart';

void main() {
  testWidgets('App launches and shows LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const AgroPilotApp(),
      ),
    );
    expect(find.text('AgroPilot AI'), findsWidgets);
  });
}
