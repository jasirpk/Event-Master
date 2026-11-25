import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/models/entrepreneur_document.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opening an entrepreneur's detail screen threw
/// `type 'Null' is not a subtype of type 'String'`.
///
/// Every field on an `entrepreneurs/{uid}` document is optional: the Media API
/// saves a profile with `update()` carrying only the keys the request named,
/// and clearing a website deletes the field outright. The screen's parameters
/// were nevertheless declared non-nullable, so each raw map read was an
/// implicit `dynamic → String` cast at the argument list, and an absent field
/// made it throw.
///
/// These tests pin both halves of the fix: the readers that narrow a raw value
/// without a cast, and the screen rendering each section only when it has one.

/// A profile with every field filled in.
Map<String, dynamic> fullProfile() => {
      'companyName': 'Tathkarah Events',
      'description': 'Weddings and corporate gatherings.',
      'phoneNumber': '9876543210',
      'emailAddress': 'hello@tathkarah.example',
      'website': 'https://tathkarah.example',
      'links': [
        {'link': 'https://instagram.example/tathkarah'},
      ],
      'images': [
        {'image': 'portfolio_images/uid/one.jpg', 'text': 'Reception'},
      ],
    };

/// The website and email rows are bare [RichText]s, not [Text]s, so
/// `find.text` does not reach them — their plain text is the label and the
/// value together.
Finder richTextContaining(String fragment) => find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains(fragment),
      description: 'RichText containing "$fragment"',
    );

Future<void> pumpDetail(
  WidgetTester tester,
  Map<String, dynamic> profile,
) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        // The same narrowing the View Detail menu item does, so these tests
        // exercise the real boundary rather than a hand-written shape.
        child: DetailFieldsWidget(
          imagePath: profileText(profile['profileImage']),
          companyName: profileText(profile['companyName']),
          screenHeight: 800,
          about: profileText(profile['description']),
          phoneNumber: profileOptionalText(profile['phoneNumber']),
          bussinessEmail: profileOptionalText(profile['emailAddress']),
          website: profileOptionalText(profile['website']),
          links: profileMapList(profile['links']),
          images: profileMapList(profile['images']),
          onRatingSubmit: (_) async => true,
          onLoadUserRating: () async => null,
          onRatingRemove: () async => true,
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  group('profileText', () {
    test('passes a stored string through unchanged', () {
      expect(profileText('Tathkarah Events'), 'Tathkarah Events');
    });

    test('an absent field reads as empty, not as a failed cast', () {
      // This is the exact call that threw: the map returns null for a key the
      // document never had.
      final Map<String, dynamic> profile = {};
      expect(profileText(profile['website']), '');
    });

    test('keeps an empty string empty', () {
      expect(profileText(''), '');
    });

    test('renders a legacy numeric value rather than dropping it', () {
      // Documents written before the Media API owned this collection could
      // store a phone number as a number.
      expect(profileText(9876543210), '9876543210');
    });
  });

  group('profileOptionalText', () {
    test('a stored value is trimmed and kept', () {
      expect(profileOptionalText('  https://example.com '),
          'https://example.com');
    });

    test('an absent field is null', () {
      expect(profileOptionalText(null), isNull);
    });

    test('a blank stored value counts as absent', () {
      // Firestore holds no blank state for a string, but a legacy document
      // can still carry one; both mean "nothing to show".
      expect(profileOptionalText('   '), isNull);
    });
  });

  group('profileMapList', () {
    test('converts a stored list of maps', () {
      final result = profileMapList([
        {'link': 'https://a.example'},
        {'link': 'https://b.example'},
      ]);

      expect(result, hasLength(2));
      expect(result.first['link'], 'https://a.example');
    });

    test('an absent field is an empty list, not a failed cast', () {
      // `List<Map<String, dynamic>>.from(null)` threw
      // "Null is not a subtype of Iterable" here.
      expect(profileMapList(null), isEmpty);
    });

    test('a value of the wrong shape is an empty list', () {
      expect(profileMapList('not a list'), isEmpty);
    });

    test('skips entries that are not maps instead of throwing', () {
      final result = profileMapList([
        {'link': 'https://a.example'},
        'junk',
        null,
      ]);

      expect(result, hasLength(1));
      expect(result.single['link'], 'https://a.example');
    });

    test('keys survive a map that is not already String-keyed', () {
      final result = profileMapList(<dynamic>[
        <dynamic, dynamic>{'link': 'https://a.example'},
      ]);

      expect(result.single['link'], 'https://a.example');
    });
  });

  group('detail screen', () {
    testWidgets('a complete profile shows every section', (tester) async {
      await pumpDetail(tester, fullProfile());

      expect(find.text('Tathkarah Events'), findsOneWidget);
      expect(find.text(Assigns.aboutUs), findsOneWidget);
      expect(find.text(Assigns.moreDetail), findsOneWidget);
      expect(find.text(Assigns.phoneNumber), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text(Assigns.otherLinks), findsOneWidget);
      expect(find.text(Assigns.media), findsOneWidget);
      expect(richTextContaining('https://tathkarah.example'),
          findsOneWidget);
      expect(richTextContaining('hello@tathkarah.example'),
          findsOneWidget);
    });

    testWidgets('a cleared website opens without throwing and hides its row',
        (tester) async {
      // Clearing a website deletes the field, so this is the shape the Media
      // API itself produces — the likeliest single cause of the crash.
      final profile = fullProfile()..remove('website');

      await pumpDetail(tester, profile);

      expect(tester.takeException(), isNull);
      expect(richTextContaining(Assigns.website), findsNothing);
      // The rest of the contact block is untouched.
      expect(find.text(Assigns.moreDetail), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
    });

    testWidgets('a missing phone number hides only the phone row',
        (tester) async {
      final profile = fullProfile()..remove('phoneNumber');

      await pumpDetail(tester, profile);

      expect(tester.takeException(), isNull);
      expect(find.text(Assigns.phoneNumber), findsNothing);
      expect(richTextContaining('https://tathkarah.example'),
          findsOneWidget);
    });

    testWidgets('no contact details at all drops the More Details heading',
        (tester) async {
      final profile = fullProfile()
        ..remove('phoneNumber')
        ..remove('emailAddress')
        ..remove('website');

      await pumpDetail(tester, profile);

      expect(tester.takeException(), isNull);
      // The heading used to stand over nothing.
      expect(find.text(Assigns.moreDetail), findsNothing);
      // The profile itself still reads.
      expect(find.text('Tathkarah Events'), findsOneWidget);
      expect(find.text(Assigns.aboutUs), findsOneWidget);
    });

    testWidgets('absent links and images drop their headings', (tester) async {
      final profile = fullProfile()
        ..remove('links')
        ..remove('images');

      await pumpDetail(tester, profile);

      expect(tester.takeException(), isNull);
      expect(find.text(Assigns.otherLinks), findsNothing);
      expect(find.text(Assigns.media), findsNothing);
      expect(find.text('Tathkarah Events'), findsOneWidget);
    });

    testWidgets('a link entry with no link field does not take the screen down',
        (tester) async {
      final profile = fullProfile()
        ..['links'] = [
          {'link': 'https://a.example'},
          <String, dynamic>{},
        ];

      await pumpDetail(tester, profile);

      expect(tester.takeException(), isNull);
      expect(richTextContaining('https://a.example'), findsOneWidget);
    });

    testWidgets('a profile that has saved nothing still opens', (tester) async {
      // An entrepreneur who signed up with Google and never saved a profile:
      // the document exists, and holds none of these fields.
      await pumpDetail(tester, <String, dynamic>{});

      expect(tester.takeException(), isNull);
      expect(find.text(Assigns.moreDetail), findsNothing);
      expect(find.text(Assigns.aboutUs), findsNothing);
      expect(find.text(Assigns.otherLinks), findsNothing);
      expect(find.text(Assigns.media), findsNothing);
      // The screen is still a screen: the booking action is there.
      expect(find.text('Book Now'), findsOneWidget);
    });
  });
}
