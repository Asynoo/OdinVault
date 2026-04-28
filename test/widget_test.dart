import 'package:flutter_test/flutter_test.dart';
import 'package:odin_vault/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OdinVaultApp());
    expect(find.byType(OdinVaultApp), findsOneWidget);
  });
}
