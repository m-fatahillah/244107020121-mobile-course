import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/note.dart';
import 'local/post.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

// --- SharedPreferences & Settings Providers ---

final prefsRepositoryProvider = Provider<PrefsRepository>((ref) {
  return PrefsRepository();
});

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setVal(bool value) => state = value;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// --- SQLite Notes Providers ---

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

final notesProvider = FutureProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.fetchNotes();
}, retry: (count, error) => null);

final singleNoteProvider = FutureProvider.family<Note?, int>((ref, id) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getNoteById(id);
});

final dirtyCountProvider = FutureProvider<int>((ref) {
  ref.watch(notesProvider);
  final repo = ref.watch(noteRepositoryProvider);
  return repo.countDirty();
});

// --- Cache-First Posts Providers ---

class CachedPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final isOffline = ref.watch(forceOfflineProvider);
    final initialPosts = await loadPostsCacheFirst(
      forceOffline: isOffline,
      onBackgroundUpdated: (freshPosts) {
        state = AsyncData(freshPosts);
      },
    );
    return initialPosts;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final isOffline = ref.read(forceOfflineProvider);
      return loadPostsCacheFirst(
        forceOffline: isOffline,
        onBackgroundUpdated: (fresh) {
          state = AsyncData(fresh);
        },
      );
    });
  }
}

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Post>>(
  CachedPostsNotifier.new,
);
