import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_gamificado_flutter/config/dependencies.dart';
import 'package:pomodoro_gamificado_flutter/main.dart';

void main() {
  testWidgets('sin sesión iniciada abre la pantalla de login', (tester) async {
    await tester.pumpWidget(
      MultiProvider(providers: providersLocal, child: const MainApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
