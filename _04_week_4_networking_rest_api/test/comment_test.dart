import 'package:flutter_test/flutter_test.dart';
import 'package:_04_week_4_networking_rest_api/data/models/comment.dart';

void main() {
  group('Comment Model Test', () {
    test('fromJson handles null values and missing fields safely', () {
      final json = <String, dynamic>{
        'postId': null,
        'id': 2,
        // name is missing
        'email': null,
        'body': 'test body',
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 0); // null -> default 0
      expect(comment.id, 2);
      expect(comment.name, ''); // missing -> default ''
      expect(comment.email, ''); // null -> default ''
      expect(comment.body, 'test body');
    });
  });
}
