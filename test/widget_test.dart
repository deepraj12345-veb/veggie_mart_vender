import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart_vender/main.dart';

void main() {
  testWidgets('App launches to LoginScreen test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VeggieMartVendorApp()));

    expect(find.text('Veggie Mart Vendor'), findsOneWidget);
    expect(find.text('Get OTP'), findsOneWidget);
  });
}
