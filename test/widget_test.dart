import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_word/main.dart';

void main() {
  testWidgets('Game launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MaterialApp(home: HangmanGame()));

    // Verify that the title text appears
    expect(find.text('Guess The Word'), findsOneWidget);

    // Verify that the wrong guesses counter is visible
    expect(find.textContaining('Wrong guesses:'), findsOneWidget);
  });
}
