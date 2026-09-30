import 'package:flowledger/app/flowledger_app.dart';
import 'package:flowledger/app/locale_controller.dart';
import 'package:flowledger/app/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows language selection on first start', (tester) async {
    await tester.pumpWidget(
      FlowLedgerApp(
        themeController: ThemeController(),
        localeController: LocaleController(),
      ),
    );

    expect(find.text('FlowLedger'), findsOneWidget);
    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
