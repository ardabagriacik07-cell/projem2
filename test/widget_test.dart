import 'package:flutter_test/flutter_test.dart';
import 'package:projem2/app/service_plus_app.dart';

void main() {
  testWidgets('auth gateway renders', (tester) async {
    await tester.pumpWidget(const ServicePlusApp());

    expect(find.text('Servis Plus Mobile'), findsOneWidget);
    expect(find.text('Uye Giris'), findsOneWidget);
  });
}
