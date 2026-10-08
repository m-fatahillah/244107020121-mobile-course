import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:_04_week_4_networking_rest_api/data/models/post.dart';
import 'package:_04_week_4_networking_rest_api/data/repositories/post_repository.dart';

class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response<List> {}

void main() {
  late MockDio mockDio;
  late PostRepository postRepository;

  setUp(() {
    mockDio = MockDio();
    postRepository = PostRepository(mockDio);
  });

  group('PostRepository', () {
    test('fetchPosts returns list of posts on success', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.data).thenReturn([
        {
          'userId': 1,
          'id': 1,
          'title': 'Test Title',
          'body': 'Test Body',
        }
      ]);
      when(() => mockDio.get<List>('/posts')).thenAnswer((_) async => mockResponse);

      // Act
      final posts = await postRepository.fetchPosts();

      // Assert
      expect(posts, isA<List<Post>>());
      expect(posts.length, 1);
      expect(posts.first.title, 'Test Title');
      expect(posts.first.id, 1);
    });
  });
}
