import 'dart:convert';
import 'dart:io';

import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/create_event.dart';
import 'package:event_master/data_layer/services/event_image_api_service.dart';
import 'package:event_master/data_layer/services/media_service.dart';
import 'package:event_master/presentation/components/event/add_event/event_fields.dart';
import 'package:event_master/presentation/pages/dashboard/create_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Regressions for the default-image booking failure.
///
/// The bug: `storedImageRef` treated anything that was not an HTTPS URL or an
/// `event_images/…` key as a local file path. The default event picture is a
/// `subcategory_images/…` object key carried in from the template screens, so
/// it was handed to File.readAsBytes, which threw — and no booking was
/// written at all unless the user picked their own photo.

/// Fails the test if the upload path is reached.
class NeverUploads extends EventImageApiService {
  NeverUploads() : super(tokenProvider: () async => 't');

  @override
  Future<String> uploadEventImage(File file) async {
    throw StateError('uploadEventImage must not be called for "${file.path}"');
  }
}

/// Records that an upload happened, without touching the disk or network.
class RecordingUploader extends EventImageApiService {
  RecordingUploader() : super(tokenProvider: () async => 't');

  final List<String> uploaded = [];

  @override
  Future<String> uploadEventImage(File file) async {
    uploaded.add(file.path);
    return 'event_images/uid1/1758800000000-picked.jpg';
  }
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  group('B2 — stored object keys are references, not files', () {
    test('the default subcategory key is never read from disk', () async {
      final bookings = EventBookingMethods(imageApi: NeverUploads());
      const key = 'subcategory_images/sub1/1758800000000-wedding.jpg';

      expect(await bookings.storedImageRef(key), key);
    });

    test('an event key is not re-uploaded', () async {
      final bookings = EventBookingMethods(imageApi: NeverUploads());
      const key = 'event_images/uid1/1758800000000-party.jpg';

      expect(await bookings.storedImageRef(key), key);
    });

    test('a legacy HTTPS URL is preserved verbatim', () async {
      final bookings = EventBookingMethods(imageApi: NeverUploads());
      const url =
          'https://firebasestorage.googleapis.com/v0/b/x/o/y.jpg?alt=media';

      expect(await bookings.storedImageRef(url), url);
    });

    test('every recognised media family is preserved', () async {
      final bookings = EventBookingMethods(imageApi: NeverUploads());

      for (final key in const [
        'category_images/cat1/1758800000000-a.jpg',
        'subcategory_images/sub1/1758800000000-a.jpg',
        'profile_images/uid1/1758800000000-a.jpg',
        'profile_portfolio/uid1/1758800000000-a.jpg',
        'client_profile_images/uid1/1758800000000-a.jpg',
        'vendor_images/uid1/vendor1/1758800000000-a.jpg',
        'event_images/uid1/1758800000000-a.jpg',
      ]) {
        expect(await bookings.storedImageRef(key), key, reason: key);
      }
    });

    test('a local file path is still uploaded', () async {
      final uploader = RecordingUploader();
      final bookings = EventBookingMethods(imageApi: uploader);

      final result =
          await bookings.storedImageRef('/private/var/tmp/image_picker/x.jpg');

      expect(uploader.uploaded, ['/private/var/tmp/image_picker/x.jpg']);
      expect(result, startsWith('event_images/'));
    });

    test('an unknown folder is treated as a path, not a key', () async {
      // The roster is explicit on purpose: an arbitrary slash-bearing string
      // must not be mistaken for something already in storage.
      final uploader = RecordingUploader();
      final bookings = EventBookingMethods(imageApi: uploader);

      await bookings.storedImageRef('some_other_folder/a.jpg');
      expect(uploader.uploaded, ['some_other_folder/a.jpg']);
    });

    test('isMediaObjectKey accepts only known folders', () {
      expect(isMediaObjectKey('event_images/u/1-a.jpg'), isTrue);
      expect(isMediaObjectKey('subcategory_images/s/1-a.jpg'), isTrue);
      expect(isMediaObjectKey('/var/tmp/a.jpg'), isFalse);
      expect(isMediaObjectKey('a.jpg'), isFalse);
      expect(isMediaObjectKey(''), isFalse);
      expect(isMediaObjectKey('event_imagesX/u/a.jpg'), isFalse);
    });
  });

  group('B3 — missing image and unreadable files', () {
    testWidgets('submitting with no image shows a validation message',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider(
          create: (_) => DashboardBloc(),
          child: Scaffold(
            body: SingleChildScrollView(
              child: EventFieldsWidget(
                EntrepreneurId: 'e1',
                screenHeight: 800,
                screenWidth: 400,
                clientNameController: TextEditingController(),
                emailController: TextEditingController(),
                phoneNumberController: TextEditingController(),
                locationController: TextEditingController(),
                dateController: TextEditingController(),
                timeController: TextEditingController(),
                eventTypeController: TextEditingController(),
                aboutController: TextEditingController(),
                guestCountController: TextEditingController(),
                // No picture at all: the field defaults to '' in the screen,
                // which the old `!= null` check happily accepted.
                imagePath: '',
                image: null,
                selectedColor: Colors.blue,
                sum: 25000,
                widget: SubmitDetailsScreen(
                  EntrepreneurId: 'e1',
                  selectedVendors: const [],
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      // The form is taller than the test viewport, so the button has to be
      // scrolled to before it can be hit-tested. PushableButton then runs a
      // press animation and fires onPressed after it, so the tap needs to
      // settle before the snackbar exists.
      await tester.ensureVisible(find.text('Submit Details'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Details'));
      await tester.pumpAndSettle();

      expect(
          find.text('Please choose an image for this event'), findsOneWidget);
    });

    test('an unreadable file gives a safe message with no path', () async {
      var requested = false;

      final api = EventImageApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((_) async {
          requested = true;
          return http.Response('{}', 200);
        }),
      );

      const path = '/private/var/secret-folder/does-not-exist.jpg';

      try {
        await api.uploadEventImage(File(path));
        fail('expected a failure');
      } on EventImageApiException catch (error) {
        expect(error.message,
            'That image could not be read. Please choose another.');
        expect(error.message, isNot(contains('/private')));
        expect(error.message, isNot(contains('secret-folder')));
        expect(error.toString(), isNot(contains('test-token')));
      }

      // Nothing was asked of the API, so no booking can follow.
      expect(requested, isFalse);
    });

    test('a failed upload propagates, so no booking is written', () async {
      final bookings = EventBookingMethods(
        imageApi: EventImageApiService(
          tokenProvider: () async => 'test-token',
          client: MockClient((_) async => http.Response('{}', 500)),
        ),
      );

      await expectLater(
        bookings.storedImageRef('/private/var/tmp/nope.jpg'),
        throwsA(isA<EventImageApiException>()),
      );
    });
  });

  group('B4 — file name length', () {
    test('an overlong name is refused before any request', () async {
      var requested = false;

      final api = EventImageApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((_) async {
          requested = true;
          return http.Response('{}', 200);
        }),
      );

      final tmp = Directory.systemTemp.createTempSync('len_test');
      addTearDown(() => tmp.deleteSync(recursive: true));

      // 129 characters before the extension boundary: one over the server's
      // limit, which it measures on the trimmed name.
      final longName = '${'a' * 125}.jpg';
      expect(longName.length, 129);

      final file = File('${tmp.path}/$longName')
        ..writeAsBytesSync(List<int>.filled(16, 1));

      await expectLater(
        api.uploadEventImage(file),
        throwsA(isA<EventImageApiException>().having(
            (e) => e.message, 'message', contains('file name is too long'))),
      );
      expect(requested, isFalse);
    });

    test('a name at the limit is accepted and sent', () async {
      String? sent;

      final api = EventImageApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((request) async {
          if (request.url.path == '/api/events/upload-url') {
            sent = (jsonDecode(request.body) as Map)['fileName'] as String;
            return http.Response(
                jsonEncode({
                  'uploadUrl': 'https://r2.example/put',
                  'objectKey': 'event_images/u/1-a.jpg',
                }),
                200);
          }
          return http.Response('', 200);
        }),
      );

      final tmp = Directory.systemTemp.createTempSync('len_test');
      addTearDown(() => tmp.deleteSync(recursive: true));

      final name = '${'a' * 124}.jpg';
      expect(name.length, 128);

      final file = File('${tmp.path}/$name')
        ..writeAsBytesSync(List<int>.filled(16, 1));

      await api.uploadEventImage(file);
      expect(sent, name);
    });

    test('the client limit matches the server constant', () {
      expect(EventImageApiService.maxFileNameLength, 128);
    });
  });
}
