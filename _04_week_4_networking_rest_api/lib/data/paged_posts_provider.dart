import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/post.dart';
import 'providers.dart';

class PagedPostsState {
  const PagedPostsState({
    this.posts = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
  });

  final List<Post> posts;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;

  PagedPostsState copyWith({
    List<Post>? posts,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
  }) {
    return PagedPostsState(
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class PagedPostsNotifier extends AsyncNotifier<PagedPostsState> {
  static const _limit = 10;

  @override
  Future<PagedPostsState> build() async {
    final repository = ref.watch(postRepositoryProvider);
    final initialPosts = await repository.fetchPostsPage(page: 1, limit: _limit);
    return PagedPostsState(
      posts: initialPosts,
      page: 1,
      hasMore: initialPosts.length == _limit,
    );
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(postRepositoryProvider);
      final nextPage = currentState.page + 1;
      final newPosts = await repository.fetchPostsPage(page: nextPage, limit: _limit);

      state = AsyncData(currentState.copyWith(
        posts: [...currentState.posts, ...newPosts],
        page: nextPage,
        isLoadingMore: false,
        hasMore: newPosts.length == _limit,
      ));
    } catch (e, st) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
      ref.read(postRepositoryProvider); // avoid unused variable warning if any
      throw e; // rethrow to be caught by UI or just let it fail
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      final newPosts = await repository.fetchPostsPage(page: 1, limit: _limit);
      state = AsyncData(PagedPostsState(
        posts: newPosts,
        page: 1,
        hasMore: newPosts.length == _limit,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final pagedPostsProvider = AsyncNotifierProvider<PagedPostsNotifier, PagedPostsState>(
  PagedPostsNotifier.new,
);
