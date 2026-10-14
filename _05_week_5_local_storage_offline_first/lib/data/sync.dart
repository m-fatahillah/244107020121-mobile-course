import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'local/post.dart';
import 'repositories/note_repository.dart';

/// Sinkronisasi catatan kotor (dirty) ke server (disimulasikan).
/// Menjalankan upload bertahap dan menandai dirty = 0 setelah berhasil.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulasi proses upload: pada produksi nyata kirim data ke REST API
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

/// Membaca daftar post yang tersimpan di cache lokal SQLite
Future<List<Post>> readCachedPosts({Future<Database> Function()? openDb}) async {
  final dbOpener = openDb ?? openNotesDb;
  final db = await dbOpener();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows.map(Post.fromDbMap).toList();
}

/// Menyimpan post hasil fetch API ke tabel cached_posts
Future<void> saveCachedPosts(
  List<Post> posts, {
  Future<Database> Function()? openDb,
}) async {
  final dbOpener = openDb ?? openNotesDb;
  final db = await dbOpener();
  final batch = db.batch();
  for (final post in posts) {
    batch.insert(
      'cached_posts',
      post.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  await batch.commit(noResult: true);
}

/// Strategi Cache-First:
/// 1. Segera kembalikan cache lokal dari SQLite agar UI responsif seketika (bahkan saat offline).
/// 2. Di background (jika tidak forceOffline), fetch dari REST API menggunakan Dio.
/// 3. Simpan hasil teranyar ke SQLite dan panggil callback [onBackgroundUpdated].
Future<List<Post>> loadPostsCacheFirst({
  Future<Database> Function()? openDb,
  Dio? dioClient,
  bool forceOffline = false,
  void Function(List<Post>)? onBackgroundUpdated,
}) async {
  final cached = await readCachedPosts(openDb: openDb);

  // Jika dipaksa offline atau sedang offline, cukup kembalikan cache lokal
  if (forceOffline) {
    return cached;
  }

  // Lakukan background fetch dari remote API
  final dio = dioClient ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));
  
  // Menjalankan fetch secara asynchronous tanpa memblokir return cache awal
  () async {
    try {
      final response = await dio.get('https://jsonplaceholder.typicode.com/posts?_limit=10');
      if (response.statusCode == 200 && response.data is List) {
        final freshPosts = (response.data as List)
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();

        await saveCachedPosts(freshPosts, openDb: openDb);
        onBackgroundUpdated?.call(freshPosts);
      }
    } catch (_) {
      // Jika background fetch gagal (misal koneksi terputus), aplikasi tetap tenang
      // karena data cache lokal sudah ditampilkan.
    }
  }();

  return cached;
}
