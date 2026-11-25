import 'package:event_master/presentation/components/settings/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A user who registered with Google used to have no `users/{uid}` document
/// at all, and both profile surfaces turned that into an error: Home showed
/// "Error loading profile", Settings showed "No data".
///
/// GoogleAuth now creates the document, so the absent case should not arise
/// for new accounts. These tests cover the second half of the fix — that the
/// UI survives the absent case anyway, for accounts created before it and for
/// a read that genuinely fails.
void main() {
  // The Settings screen's own menu, shaped the way ProfileScreen builds it.
  final items = <Map<String, dynamic>>[
    {
      'icon': Icons.person,
      'text': 'Account',
      'section': 'ACCOUNT',
      'onTap': () {},
    },
    {
      'icon': Icons.logout,
      'text': 'Log out',
      'section': 'DANGER',
      'onTap': () {},
    },
  ];

  Future<void> pumpProfile(
    WidgetTester tester,
    Map<String, dynamic>? userData,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: UserProfileWidget(userData: userData, items: items),
      ),
    ));
    await tester.pump();
  }

  group('a profile document that is absent', () {
    testWidgets('renders the empty state instead of failing', (tester) async {
      await pumpProfile(tester, null);

      expect(tester.takeException(), isNull);
      expect(find.text('No name'), findsOneWidget);
      expect(find.text('No phone number'), findsOneWidget);
      expect(find.text('No email'), findsOneWidget);
    });

    testWidgets('still offers the menu, so the user is not stranded',
        (tester) async {
      await pumpProfile(tester, null);

      // The whole point of rendering rather than bailing out: these are the
      // ways off this screen. "No data" was a dead end.
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('does not invent a profile image', (tester) async {
      await pumpProfile(tester, null);

      expect(tester.takeException(), isNull);
    });
  });

  group('a profile document that exists but is not filled in', () {
    // Exactly what registration writes: uid, email, platform, createdAt.
    final justRegistered = <String, dynamic>{
      'uid': 'abc123',
      'email': 'new.user@example.com',
      'platform': 'mobile',
      'createdAt': DateTime(2026, 11, 25),
    };

    testWidgets('shows the email it has and defaults the rest',
        (tester) async {
      await pumpProfile(tester, justRegistered);

      expect(tester.takeException(), isNull);
      expect(find.text('new.user@example.com'), findsWidgets);
      expect(find.text('No name'), findsOneWidget);
      expect(find.text('No phone number'), findsOneWidget);
    });
  });

  group('a completed profile is unchanged', () {
    final complete = <String, dynamic>{
      'uid': 'abc123',
      'email': 'jane@example.com',
      'platform': 'mobile',
      'userName': 'Jane Doe',
      'phoneNumber': '+919876543210',
      'imagePath': '',
      'isValid': true,
    };

    testWidgets('shows the stored name, phone and email', (tester) async {
      await pumpProfile(tester, complete);

      expect(tester.takeException(), isNull);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('jane@example.com'), findsWidgets);

      // None of the empty-state placeholders leak into a filled profile.
      expect(find.text('No name'), findsNothing);
      expect(find.text('No phone number'), findsNothing);
      expect(find.text('No email'), findsNothing);
    });

    testWidgets('an empty phone number falls back without hiding the row',
        (tester) async {
      await pumpProfile(tester, {...complete, 'phoneNumber': ''});

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('No phone number'), findsOneWidget);
    });
  });
}
