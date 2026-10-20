import 'dart:async';

import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/booking_index_api_service.dart';
import 'package:event_master/data_layer/services/booking_submission.dart';
import 'package:event_master/presentation/components/event/add_event/event_fields.dart';
import 'package:event_master/presentation/pages/dashboard/create_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Duplicate-submission protection and the in-flight state, on the real form.
///
/// The save is held open with a Completer, so the widget stays mid-submit for
/// the whole test and never reaches the navigation that follows success —
/// which is what lets this run without GetX or Firestore.

/// A submission whose save never finishes until the test releases it.
class HangingSubmission extends BookingSubmission {
  HangingSubmission()
      : super(
          indexApi: BookingIndexApiService(
            client: MockClient((_) async => http.Response('{}', 200)),
            tokenProvider: () async => 'test-token',
          ),
        );

  int submits = 0;
  final Completer<String> gate = Completer<String>();

  @override
  Future<BookingSubmissionResult> submit({
    required Future<String> Function() saveBooking,
  }) async {
    submits += 1;
    final eventId = await gate.future;
    return BookingSubmissionResult(
      eventId: eventId,
      outcome: BookingSubmissionOutcome.listed,
    );
  }
}

TextEditingController filled(String value) =>
    TextEditingController(text: value);

Future<HangingSubmission> pumpForm(
  WidgetTester tester, {
  bool complete = true,
}) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final submission = HangingSubmission();
  TextEditingController field(String v) =>
      complete ? filled(v) : TextEditingController();

  await tester.pumpWidget(MaterialApp(
    home: BlocProvider(
      create: (_) => DashboardBloc(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: EventFieldsWidget(
            EntrepreneurId: 'ent1',
            screenHeight: 800,
            screenWidth: 400,
            clientNameController: field('A Customer'),
            emailController: field('a@example.com'),
            phoneNumberController: field('1234567890'),
            locationController: field('Kozhikode'),
            dateController: field('01/01/2026'),
            timeController: field('6:00 PM'),
            eventTypeController: field('Wedding'),
            aboutController: field('About the event'),
            guestCountController: field('120'),
            imagePath:
                complete ? 'subcategory_images/sub1/1758800000000-a.jpg' : '',
            image: null,
            selectedColor: Colors.blue,
            sum: 25000,
            submission: submission,
            widget: SubmitDetailsScreen(
              EntrepreneurId: 'ent1',
              selectedVendors: complete
                  ? const [
                      {
                        'categoryName': 'Catering',
                        'imagePathUrl': '',
                        'budget': {'from': 1000, 'to': 25000},
                      }
                    ]
                  : const [],
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();

  return submission;
}

Future<void> tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Submit Details'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Submit Details'));
  await tester.pump();
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  testWidgets('submitting shows the in-flight state', (tester) async {
    final submission = await pumpForm(tester);

    expect(find.text('Submitting…'), findsNothing);

    await tapSubmit(tester);

    expect(submission.submits, 1);
    expect(find.text('Submitting…'), findsOneWidget);

    // Left in flight deliberately: completing it would run the success path
    // into GetX's snackbar, which needs a GetMaterialApp overlay. What these
    // assert is the in-flight state, which is already on screen.
  });

  testWidgets('the button is replaced while in flight', (tester) async {
    final submission = await pumpForm(tester);

    await tapSubmit(tester);

    // The protection: the control itself is gone, so it cannot be tapped.
    expect(find.text('Submit Details'), findsNothing);
    expect(submission.submits, 1);

    // Left in flight deliberately: completing it would run the success path
    // into GetX's snackbar, which needs a GetMaterialApp overlay. What these
    // assert is the in-flight state, which is already on screen.
  });

  testWidgets('a repeated tap cannot start a second booking', (tester) async {
    final submission = await pumpForm(tester);

    await tapSubmit(tester);
    expect(submission.submits, 1);

    await tester.tap(find.byType(CircularProgressIndicator),
        warnIfMissed: false);
    await tester.pump();

    expect(submission.submits, 1, reason: 'exactly one booking per submission');

    // Left in flight deliberately: completing it would run the success path
    // into GetX's snackbar, which needs a GetMaterialApp overlay. What these
    // assert is the in-flight state, which is already on screen.
  });

  testWidgets('an incomplete form never reaches submission', (tester) async {
    final submission = await pumpForm(tester, complete: false);

    await tapSubmit(tester);

    expect(submission.submits, 0);
    expect(find.text('Please choose an image for this event'), findsOneWidget);
  });
}
