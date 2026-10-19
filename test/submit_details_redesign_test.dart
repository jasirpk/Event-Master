import 'dart:io';

import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/event/add_event/client_details.dart';
import 'package:event_master/presentation/components/event/add_event/event_type.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers the redesigned Submit Details sections.
///
/// The image-preview assertions matter because the older tests in
/// submit_details_images_test.dart were written against the previous widget
/// tree and now pass without exercising much of the new one.

Future<void> pumpClientDetails(
  WidgetTester tester, {
  required TextEditingController location,
  bool locating = false,
}) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: BlocProvider(
      create: (_) => DashboardBloc(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: ClientDeatailsWidget(
            screenHeight: 800,
            clientNameController: TextEditingController(),
            emailController: TextEditingController(),
            phoneNumberController: TextEditingController(),
            locationController: location,
            dateController: TextEditingController(),
            timeController: TextEditingController(),
            locating: locating,
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

Future<void> pumpEventType(
  WidgetTester tester, {
  String? imagePath,
  File? image,
}) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: BlocProvider(
      create: (_) => DashboardBloc(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: EventTypeWidget(
            screenHeight: 800,
            screenWidth: 400,
            eventTypeController: TextEditingController(),
            aboutController: TextEditingController(),
            imagePath: imagePath,
            image: image,
          ),
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

  group('location card', () {
    testWidgets('offers an explicit action and no "Enable location" field',
        (tester) async {
      await pumpClientDetails(tester, location: TextEditingController());

      expect(find.text('Event location'), findsOneWidget);
      expect(find.text('Use current'), findsOneWidget);
      expect(find.text('Enable location'), findsNothing);
    });

    testWidgets('shows the selected location', (tester) async {
      await pumpClientDetails(tester,
          location: TextEditingController(text: 'Kozhikode, India'));

      expect(find.text('Kozhikode, India'), findsOneWidget);
    });

    testWidgets('the value can be typed when GPS is unavailable',
        (tester) async {
      final location = TextEditingController();
      await pumpClientDetails(tester, location: location);

      // Several fields render a TextField; this is the card's own.
      final locationField = find.byWidgetPredicate((w) =>
          w is TextField &&
          w.decoration?.hintText == 'Use current location, or type it');

      await tester.enterText(locationField, 'Calicut Beach');
      expect(location.text, 'Calicut Beach');
    });

    testWidgets('progress replaces the action while locating', (tester) async {
      await pumpClientDetails(tester,
          location: TextEditingController(), locating: true);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Use current'), findsNothing);
    });

    testWidgets('date and time sit on one row', (tester) async {
      await pumpClientDetails(tester, location: TextEditingController());

      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);

      final date = tester.getRect(find.text('Date'));
      final time = tester.getRect(find.text('Time'));
      expect(date.top, closeTo(time.top, 4));
      expect(date.width, greaterThan(0));
    });
  });

  group('event image preview', () {
    testWidgets('an R2 key goes through MediaImage, never AssetImage',
        (tester) async {
      await pumpEventType(tester,
          imagePath: 'subcategory_images/sub1/1758800000000-a.jpg');

      expect(find.byType(MediaImage), findsOneWidget);
      expect(find.text('Change image'), findsOneWidget);
    });

    // A legacy https URL is deliberately not rendered here: the resolver
    // hands back a NetworkImage, and painting one offline fails a widget
    // test. That mapping is covered directly in
    // submit_details_images_test.dart, and this widget no longer has an
    // AssetImage branch at all for it to fall into.

    testWidgets('with nothing set the card invites a choice', (tester) async {
      await pumpEventType(tester, imagePath: '');

      expect(find.text('Add image'), findsOneWidget);
      expect(find.text('Tap to choose an image'), findsOneWidget);
    });

    testWidgets('a locally picked file is previewed directly', (tester) async {
      final tmp = Directory.systemTemp.createTempSync('preview_test');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final file = File('${tmp.path}/pick.jpg')
        ..writeAsBytesSync(List<int>.filled(8, 0));

      await pumpEventType(tester, imagePath: '', image: file);

      // The local file wins over any stored reference.
      expect(find.byType(Image), findsWidgets);
      expect(find.text('Change image'), findsOneWidget);
    });

    testWidgets('a null path does not throw', (tester) async {
      await pumpEventType(tester, imagePath: null);
      expect(find.text('Add image'), findsOneWidget);
    });
  });
}
