import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/event/add_event/colortheme_selector.dart';
import 'package:event_master/presentation/components/event/add_event/event_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// The selected event's visibility on Submit Details, and the colour theme
/// swatches.
///
/// The selection is three optional strings carried from `sub_templates.dart`
/// through four screens; the one that matters here is the sub-template name.
/// Null is an ordinary path — the user can reach this form without choosing
/// one — so "absent" has to be as well behaved as "present".

Future<void> pumpEventType(
  WidgetTester tester, {
  String? selectedEventName,
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
            imagePath: null,
            image: null,
            selectedEventName: selectedEventName,
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

Future<void> pumpThemeSelector(
  WidgetTester tester, {
  required Color selected,
  required void Function(DashboardBloc bloc) capture,
}) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final bloc = DashboardBloc();
  capture(bloc);

  await tester.pumpWidget(MaterialApp(
    home: BlocProvider.value(
      value: bloc,
      child: Scaffold(
        body: SingleChildScrollView(
          child: ColorThemeSelector(selectedColor: selected),
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

  group('selected event banner', () {
    testWidgets('names the sub-template the booking started from',
        (tester) async {
      await pumpEventType(tester, selectedEventName: 'Beach Wedding');

      expect(find.text('Selected event'), findsOneWidget);
      expect(find.text('Beach Wedding'), findsOneWidget);
    });

    testWidgets('is absent when no event was selected', (tester) async {
      await pumpEventType(tester, selectedEventName: null);

      expect(find.text('Selected event'), findsNothing);
      // The form itself still stands: arriving without a selection is a
      // normal path, not an error state.
      expect(find.text('Event type'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('a blank name counts as no selection', (tester) async {
      await pumpEventType(tester, selectedEventName: '   ');

      expect(find.text('Selected event'), findsNothing);
    });

    testWidgets('does not replace the editable Event type field',
        (tester) async {
      // The banner states what was chosen; the field below stays editable so
      // the user can still override it.
      await pumpEventType(tester, selectedEventName: 'Corporate Gala');

      expect(find.text('Selected event'), findsOneWidget);
      expect(find.text('Event type'), findsOneWidget);
    });
  });

  group('colour theme swatches', () {
    testWidgets('every option is offered as a swatch', (tester) async {
      late DashboardBloc bloc;
      await pumpThemeSelector(tester,
          selected: Colors.blue, capture: (b) => bloc = b);
      addTearDown(bloc.close);

      // Five named options: Blue, Red, Green, Yellow, Teal.
      expect(find.bySemanticsLabel('Blue theme'), findsOneWidget);
      expect(find.bySemanticsLabel('Red theme'), findsOneWidget);
      expect(find.bySemanticsLabel('Green theme'), findsOneWidget);
      expect(find.bySemanticsLabel('Yellow theme'), findsOneWidget);
      expect(find.bySemanticsLabel('Teal theme'), findsOneWidget);
    });

    testWidgets('tapping a swatch raises ChangeColorTheme', (tester) async {
      // The swatches used to be bare CircleAvatars with no gesture at all —
      // only the dropdown could change the colour.
      late DashboardBloc bloc;
      final emitted = <Color>[];

      await pumpThemeSelector(tester,
          selected: Colors.blue, capture: (b) => bloc = b);
      addTearDown(bloc.close);

      final subscription = bloc.stream.listen((state) {
        if (state is ColorThemeChanged) emitted.add(state.newColor);
      });
      addTearDown(subscription.cancel);

      await tester.tap(find.bySemanticsLabel('Red theme'));
      await tester.pump();

      expect(emitted, contains(Colors.red));
    });

    testWidgets('tapping the already-selected swatch raises nothing',
        (tester) async {
      late DashboardBloc bloc;
      final emitted = <Color>[];

      await pumpThemeSelector(tester,
          selected: Colors.green, capture: (b) => bloc = b);
      addTearDown(bloc.close);

      final subscription = bloc.stream.listen((state) {
        if (state is ColorThemeChanged) emitted.add(state.newColor);
      });
      addTearDown(subscription.cancel);

      await tester.tap(find.bySemanticsLabel('Green theme'));
      await tester.pump();

      expect(emitted, isEmpty);
    });

    testWidgets('the selected swatch is marked and the others are not',
        (tester) async {
      late DashboardBloc bloc;
      await pumpThemeSelector(tester,
          selected: Colors.yellow, capture: (b) => bloc = b);
      addTearDown(bloc.close);

      // Exactly one swatch carries the tick; before this change nothing on
      // the row indicated which colour was in force.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
