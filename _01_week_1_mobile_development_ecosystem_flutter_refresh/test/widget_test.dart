// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:_01_week_1_mobile_development_ecosystem_flutter_refresh/main.dart';

void main() {
  testWidgets('ProfileApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProfileApp());

    // Verify that our profile information is displayed.
    expect(find.text('Nama Mahasiswa'), findsOneWidget);
    expect(find.text('Muhammad Fatahillah Athabrani'), findsOneWidget);
  });
}
