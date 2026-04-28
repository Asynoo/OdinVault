import 'package:flutter_test/flutter_test.dart';
import 'package:vault_pass/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VaultPassApp());
    expect(find.byType(VaultPassApp), findsOneWidget);
  });
}
