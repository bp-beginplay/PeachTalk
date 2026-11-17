import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:peachtalk/screens/chat_screen.dart';
import 'package:peachtalk/screens/character_select_screen.dart';

void main() {
  testWidgets('Chat screen sidebar shows shortcut icons and can be hidden', (
    WidgetTester tester,
  ) async {
    const character = CharacterInfo(
      id: 'nia',
      name: '니아',
      image: 'assets/images/characters/nia.png',
      description: 'test',
    );

    await tester.pumpWidget(
      const MaterialApp(home: ChatScreen(character: character)),
    );
    await tester.pumpAndSettle();

    // Starts hidden so the chat is full-width on open.
    final sidebar = find.byType(AnimatedContainer).first;
    expect(tester.getSize(sidebar).width, 0);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // The top bar's open button expands the sidebar, overlaying its three
    // shortcut icons (not a character list) on top of the chat, and the
    // open button itself disappears (it would sit under the sidebar).
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(tester.getSize(sidebar).width, 76);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    expect(find.byIcon(Icons.music_note), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsNothing);
    // The character's name still appears exactly once (the top bar title),
    // not a second time as a sidebar entry.
    expect(find.text('니아'), findsOneWidget);

    // The sidebar's own close button (not the now-covered top bar button)
    // collapses it back to zero width and brings the open button back.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(tester.getSize(sidebar).width, 0);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });
}
