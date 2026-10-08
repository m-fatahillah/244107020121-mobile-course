import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/paged_posts_provider.dart';
import '../data/network_errors.dart' show friendlyErrorMessage;
import '../widgets/post_tile.dart';
import 'package:go_router/go_router.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(pagedPostsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(pagedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paged Posts API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pagedPostsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.read(pagedPostsProvider.notifier).refresh(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          if (state.posts.isEmpty) {
            return const Center(child: Text('Belum ada data dari server.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(pagedPostsProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.posts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final post = state.posts[index];
                return PostTile(
                  post: post,
                  onTap: () => context.push('/post/${post.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
