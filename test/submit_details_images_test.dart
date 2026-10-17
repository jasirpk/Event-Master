import 'package:event_master/data_layer/services/media_image_resolver.dart';
import 'package:event_master/presentation/components/event/add_event/event_type.dart';
import 'package:event_master/presentation/components/event/add_event/selected_vendors.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
import 'package:event_master/presentation/pages/dashboard/create_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Image handling on the Submit Details screen.
///
/// Both widgets used to choose their provider with
/// `path.startsWith('http') ? NetworkImage(path) : AssetImage(path)`. Since the
/// R2 migration a stored path is usually an object key — `vendor_images/…` or
/// `subcategory_images/…` — so the else branch asked Flutter for a bundled
/// asset of that name and threw "Unable to load asset".
///
/// These run offline. An object key cannot be signed without Firebase, so the
/// resolver falls back to the placeholder, which is exactly the path under
/// test: whatever happens, no AssetImage is ever built from an object key.

SubmitDetailsScreen screenWith(List<Map<String, dynamic>> vendors) =>
    SubmitDetailsScreen(selectedVendors: vendors, EntrepreneurId: 'entrepreneur1');

Map<String, dynamic> vendorRow(dynamic imagePathUrl) => {
      'categoryName': 'Catering',
      'imagePathUrl': imagePathUrl,
      'budget': {'from': 1000, 'to': 25000},
    };

Future<void> pumpSelectedVendors(
    WidgetTester tester, List<Map<String, dynamic>> vendors) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SelectedVendorsWidget(
        screenHeight: 800,
        screenWidth: 400,
        widget: screenWith(vendors),
      ),
    ),
  ));
  await tester.pump();
}

ImageProvider? avatarImage(WidgetTester tester) =>
    tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage;

void main() {
  group('selected vendor thumbnails', () {
    testWidgets('an R2 object key never becomes an AssetImage',
        (tester) async {
      await pumpSelectedVendors(
          tester, [vendorRow('vendor_images/uid1/vendor1/photo.jpg')]);

      final provider = avatarImage(tester);
      expect(provider, isNot(isA<AssetImage>().having(
          (a) => a.assetName, 'assetName', contains('vendor_images'))));
      expect(provider, kMediaPlaceholderImage,
          reason: 'an unsignable key falls back to the shared placeholder');
    });

    testWidgets('an empty path falls back to the placeholder', (tester) async {
      await pumpSelectedVendors(tester, [vendorRow('')]);
      expect(avatarImage(tester), kMediaPlaceholderImage);
    });

    testWidgets('a missing imagePathUrl does not throw', (tester) async {
      await pumpSelectedVendors(tester, [vendorRow(null)]);
      expect(avatarImage(tester), kMediaPlaceholderImage);
    });

    testWidgets('a malformed imagePathUrl does not throw', (tester) async {
      await pumpSelectedVendors(tester, [vendorRow(42)]);
      expect(avatarImage(tester), kMediaPlaceholderImage);
    });

    testWidgets('the row still renders its name and budget', (tester) async {
      await pumpSelectedVendors(
          tester, [vendorRow('vendor_images/uid1/vendor1/photo.jpg')]);

      expect(find.text('Catering'), findsOneWidget);
      expect(find.text('₹25000'), findsOneWidget);
    });
  });

  group('event picture', () {
    Future<void> pumpEventType(WidgetTester tester, String? imagePath) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventTypeWidget(
            screenHeight: 800,
            screenWidth: 400,
            eventTypeController: TextEditingController(),
            aboutController: TextEditingController(),
            imagePath: imagePath,
            image: null,
          ),
        ),
      ));
      await tester.pump();
    }

    /// The decorated box the picker draws into.
    DecorationImage? pickerImage(WidgetTester tester) {
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.collections_bookmark),
          matching: find.byType(Container),
        ).last,
      );
      return (container.decoration as BoxDecoration?)?.image;
    }

    testWidgets('a subcategory R2 key never becomes an AssetImage',
        (tester) async {
      await pumpEventType(tester, 'subcategory_images/cat1/sub1/photo.jpg');

      // Unresolvable offline, so the slot stays empty — but critically it is
      // not an AssetImage built from the key, which is what used to throw.
      expect(pickerImage(tester)?.image, isNot(isA<AssetImage>()));
    });

    testWidgets('an empty path leaves the picker empty', (tester) async {
      await pumpEventType(tester, '');
      expect(pickerImage(tester), isNull);
    });

    testWidgets('a null path does not throw', (tester) async {
      await pumpEventType(tester, null);
      expect(pickerImage(tester), isNull);
    });

    testWidgets('the picker button survives', (tester) async {
      await pumpEventType(tester, 'subcategory_images/cat1/sub1/photo.jpg');
      expect(find.byIcon(Icons.collections_bookmark), findsOneWidget);
    });
  });

  group('legacy compatibility is preserved in the resolver', () {
    test('an https URL still resolves to a NetworkImage', () {
      final provider = MediaImageResolver.instance
          .resolveSync('https://firebasestorage.example/old.jpg');

      expect(provider, isA<NetworkImage>());
      expect((provider as NetworkImage).url,
          'https://firebasestorage.example/old.jpg');
    });

    test('a bundled asset path still resolves to an AssetImage', () {
      expect(MediaImageResolver.instance.resolveSync(kMediaPlaceholderAsset),
          isA<AssetImage>());
    });

    test('an object key resolves to nothing synchronously', () {
      expect(
          MediaImageResolver.instance
              .resolveSync('vendor_images/uid1/vendor1/photo.jpg'),
          isNull);
    });

    test('null and empty resolve to nothing', () {
      expect(MediaImageResolver.instance.resolveSync(null), isNull);
      expect(MediaImageResolver.instance.resolveSync('   '), isNull);
    });
  });
}
