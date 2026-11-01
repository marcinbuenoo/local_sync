import 'package:flutter_test/flutter_test.dart';
import 'package:local_sync/app.dart';

void main() {
  testWidgets('mostra a tela de coleta', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Coleta parada'), findsOneWidget);
    expect(find.text('Iniciar coleta'), findsOneWidget);
  });
}
