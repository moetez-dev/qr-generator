import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_generator_standalone/main.dart';

void main() {
  testWidgets('shows generator empty state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ChangeNotifierProvider(create: (_) => QrState(prefs), child: const QrApp()));
    expect(find.text('Create your QR code'), findsOneWidget);
    expect(find.text('Your QR code will appear here'), findsOneWidget);
  });
}
