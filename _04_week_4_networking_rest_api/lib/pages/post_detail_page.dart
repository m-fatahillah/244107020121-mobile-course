import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../data/network_errors.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.id});
  
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentListProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('Post Detail $id')),
      body: commentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(commentListProvider(id)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (comments) {
          if (comments.isEmpty) {
            return const Center(child: Text('Tidak ada komentar.'));
          }
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                leading: const Icon(Icons.comment),
                title: Text(comment.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(comment.body, maxLines: 3, overflow: TextOverflow.ellipsis),
              );
            },
          );
        },
      ),
    );
  }
}
