import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:_05_week_5_local_storage_offline_first/data/local/note.dart';
import 'package:_05_week_5_local_storage_offline_first/data/providers.dart';
import 'package:_05_week_5_local_storage_offline_first/main.dart';
import 'note_test.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'dark_mode': false,
      'last_opened_at': '2026-10-14T20:00:00.000Z',
    });
  });

  testWidgets('App smoke test renders navigation and notes list',
      (WidgetTester tester) async {
    final fakeRepo = FakeNoteRepository(
      items: [
        Note(
          id: 1,
          title: 'Catatan Uji Coba',
          body: 'Isi catatan tes',
          updatedAt: DateTime.now(),
          dirty: false,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Pastikan judul halaman dan navigasi tampil
    expect(find.text('Offline Notes'), findsOneWidget);
    expect(find.text('Catatan SQLite'), findsOneWidget);
    expect(find.text('Cache Posts'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Catatan Uji Coba'), findsOneWidget);
  });
}
