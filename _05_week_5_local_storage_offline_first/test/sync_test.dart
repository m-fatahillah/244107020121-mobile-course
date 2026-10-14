import 'package:flutter_test/flutter_test.dart';
import 'package:_05_week_5_local_storage_offline_first/data/local/note.dart';
import 'package:_05_week_5_local_storage_offline_first/data/repositories/note_repository.dart';
import 'package:_05_week_5_local_storage_offline_first/data/sync.dart';

class SyncMockNoteRepository extends NoteRepository {
  SyncMockNoteRepository(this.notes)
      : super(openDb: () => throw UnimplementedError());

  List<Note> notes;
  bool isSynced = false;

  @override
  Future<int> countDirty() async {
    return notes.where((n) => n.dirty).length;
  }

  @override
  Future<void> markAllSynced() async {
    isSynced = true;
    notes = notes.map((n) => n.copyWith(dirty: false)).toList();
  }
}

void main() {
  group('Sync Functionality Test', () {
    test('syncNotes returns 0 when no dirty notes exist', () async {
      final repo = SyncMockNoteRepository([
        Note(title: 'Clean 1', updatedAt: DateTime.now(), dirty: false),
        Note(title: 'Clean 2', updatedAt: DateTime.now(), dirty: false),
      ]);

      final count = await syncNotes(repo);
      expect(count, 0);
      expect(repo.isSynced, isFalse);
    });

    test('syncNotes uploads dirty notes and marks them clean', () async {
      final repo = SyncMockNoteRepository([
        Note(title: 'Dirty 1', updatedAt: DateTime.now(), dirty: true),
        Note(title: 'Clean 1', updatedAt: DateTime.now(), dirty: false),
        Note(title: 'Dirty 2', updatedAt: DateTime.now(), dirty: true),
      ]);

      final count = await syncNotes(repo);
      expect(count, 2);
      expect(repo.isSynced, isTrue);
      expect(await repo.countDirty(), 0);
    });
  });
}
