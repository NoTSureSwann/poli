// Basic widget test for Klinik Merah Putih app.

import 'package:flutter_test/flutter_test.dart';
import 'package:klinik/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KlinikApp(initialDarkMode: false));
    await tester.pumpAndSettle();

    // Verify login screen is shown (since no token is stored)
    expect(find.text('Login'), findsWidgets);
  });
}
