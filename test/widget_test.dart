// Basic widget test for Klinik Merah Putih app.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:klinik/main.dart';
import 'package:klinik/services/auth_service.dart';

void main() {
  testWidgets('App renders terms screen on first launch', (WidgetTester tester) async {
    final authService = AuthService();
    
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: authService,
        child: const MyApp(
          initialDarkMode: false,
          termsAccepted: false,
        ),
      ),
    );

    // Verify terms screen is shown
    expect(find.text('Selamat Datang di Klinik Merah Putih'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsOneWidget);
  });
}
