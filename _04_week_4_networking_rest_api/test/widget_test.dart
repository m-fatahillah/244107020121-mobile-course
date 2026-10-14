import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:_04_week_4_networking_rest_api/main.dart';
import 'package:_04_week_4_networking_rest_api/data/models/post.dart';
import 'package:_04_week_4_networking_rest_api/data/providers.dart';
import 'package:_04_week_4_networking_rest_api/data/repositories/post_repository.dart';

class FakePostRepository extends Fake implements PostRepository {
  @override
  Future<List<Post>> fetchPosts({int page = 1, int limit = 10}) async {
    return [
      const Post(id: 1, userId: 1, title: 'Test Post', body: 'Test Body'),
    ];
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
