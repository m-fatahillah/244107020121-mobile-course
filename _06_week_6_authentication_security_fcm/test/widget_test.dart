import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:_06_week_6_authentication_security_fcm/data/token_store.dart';
import 'package:_06_week_6_authentication_security_fcm/main.dart';
import 'package:_06_week_6_authentication_security_fcm/providers/auth_provider.dart';

class MockTokenStore extends TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccess() async => _access;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

void main() {
  testWidgets('CampusNotifyApp smoke test renders login page', (WidgetTester tester) async {
    final mockStore = MockTokenStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(mockStore),
        ],
        child: const CampusNotifyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.text('Portal Autentikasi & Push Messaging Polinema'), findsOneWidget);
    expect(find.text('Masuk Akun Kampus'), findsOneWidget);
  });
}
