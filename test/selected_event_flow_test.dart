import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/list/list_stream.dart';
import 'package:event_master/presentation/pages/dashboard/create_event.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneurs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// The selected event has to survive every hop between picking a sub-template
/// and the Submit details form:
///
///   sub_templates / subcategory / favourites
///     -> EntrepreneursListScreen
///       -> ListOfStreamWidget -> FieldsWidget
///         -> VendorListScreen
///           -> SubmitDetailsScreen  (seeds Event type + About)
///
/// It used to be dropped at the second hop. EntrepreneursListScreen built
/// ListOfStreamWidget from two separate branches and only the non-searching
/// one forwarded subCategoryName/subdescripion, so typing in the search box —
/// or arriving with a stale SearchLoaded in the app-wide DashboardBloc — lost
/// the event and left both fields empty at the end of the chain.
///
/// These tests drive the real screens with real arguments rather than handing
/// values straight to SubmitDetailsScreen, so that hop stays covered.
///
/// ListOfStreamWidget's own build reaches Firestore and throws under test;
/// that is expected and swallowed. The widget it was built with is still in
/// the tree, which is what these assertions read.
const selectedName = 'Wedding';
const selectedDescription = 'A full wedding package with catering and decor.';
const selectedImage = 'subcategories/wedding.png';

Future<ListOfStreamWidget?> pumpEntrepreneurs(
  WidgetTester tester, {
  required DashboardBloc bloc,
  String? name = selectedName,
  String? description = selectedDescription,
  String? imagePath = selectedImage,
}) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: BlocProvider<DashboardBloc>.value(
      value: bloc,
      child: EntrepreneursListScreen(
        subImagePath: imagePath,
        subCategoryName: name,
        subdescripion: description,
      ),
    ),
  ));
  await tester.pump();

  // Firestore is not available in a unit test; the stream child is expected
  // to fail and must not mask the assertions below.
  tester.takeException();

  final found = find.byType(ListOfStreamWidget);
  if (found.evaluate().isEmpty) return null;
  return tester.widget<ListOfStreamWidget>(found);
}

Future<_SubmitDetailsScreenHandles> pumpSubmitDetails(
  WidgetTester tester, {
  String? name = selectedName,
  String? description = selectedDescription,
}) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final screen = SubmitDetailsScreen(
    EntrepreneurId: 'entrepreneur-1',
    selectedVendors: const [
      {
        'budget': {'to': 1000},
      },
    ],
    subCategoryName: name,
    subdescripion: description,
  );

  await tester.pumpWidget(MaterialApp(
    home: BlocProvider(create: (_) => DashboardBloc(), child: screen),
  ));
  await tester.pump();
  tester.takeException();

  final state = tester.state<State<SubmitDetailsScreen>>(
    find.byType(SubmitDetailsScreen),
  ) as dynamic;

  return _SubmitDetailsScreenHandles(
    eventType: state.eventTypeController as TextEditingController,
    about: state.aboutController as TextEditingController,
  );
}

class _SubmitDetailsScreenHandles {
  _SubmitDetailsScreenHandles({required this.eventType, required this.about});

  final TextEditingController eventType;
  final TextEditingController about;
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  group('the entrepreneurs screen keeps the selected event', () {
    late DashboardBloc bloc;

    setUp(() => bloc = DashboardBloc());
    tearDown(() => bloc.close());

    testWidgets('on first entry, before any search', (tester) async {
      final child = await pumpEntrepreneurs(tester, bloc: bloc);

      expect(child, isNotNull);
      expect(child!.subCategoryName, selectedName);
      expect(child.subdescripion, selectedDescription);
      expect(child.subImagePath, selectedImage);
      expect(child.searchTerm, '');
    });

    testWidgets('while a search is active — the regression', (tester) async {
      // Exactly what typing in the search box does.
      bloc.emit(SearchLoaded('cat'));

      final child = await pumpEntrepreneurs(tester, bloc: bloc);

      expect(child, isNotNull,
          reason: 'the searching branch must still build the list');
      // Before the fix these two were null: the searching branch never
      // forwarded them, so the chain below this point carried nothing.
      expect(child!.subCategoryName, selectedName);
      expect(child.subdescripion, selectedDescription);
      expect(child.subImagePath, selectedImage);
      // The search itself must keep working.
      expect(child.searchTerm, 'cat');
    });

    testWidgets('when a stale search state is left over from a past visit',
        (tester) async {
      // DashboardBloc is provided above GetMaterialApp and nothing resets it
      // on entry, so this is the state a second visit can start in — the
      // event was lost on the very first frame, with no typing at all.
      bloc.emit(SearchLoaded('leftover'));

      final child = await pumpEntrepreneurs(tester, bloc: bloc);

      expect(child!.subCategoryName, selectedName);
      expect(child.subdescripion, selectedDescription);
    });

    testWidgets('a search that is still loading shows progress, not a list',
        (tester) async {
      bloc.emit(SearchLoading());

      final child = await pumpEntrepreneurs(tester, bloc: bloc);

      expect(child, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a failed search still reports itself', (tester) async {
      bloc.emit(SearchError('no luck'));

      final child = await pumpEntrepreneurs(tester, bloc: bloc);

      expect(child, isNull);
      expect(find.text('no luck'), findsOneWidget);
    });

    testWidgets('entering with no event chosen invents nothing',
        (tester) async {
      final child = await pumpEntrepreneurs(
        tester,
        bloc: bloc,
        name: null,
        description: null,
        imagePath: null,
      );

      // "+Add Events" and the empty-handed entry points are a real path.
      expect(child!.subCategoryName, isNull);
      expect(child.subdescripion, isNull);
    });

    testWidgets('an event survives a search starting and then clearing',
        (tester) async {
      final before = await pumpEntrepreneurs(tester, bloc: bloc);
      expect(before!.subCategoryName, selectedName);

      bloc.emit(SearchLoaded('ca'));
      // Two frames: the bloc delivers on the stream, then the tree rebuilds.
      await tester.pump();
      await tester.pump();
      tester.takeException();

      final during =
          tester.widget<ListOfStreamWidget>(find.byType(ListOfStreamWidget));
      expect(during.subCategoryName, selectedName);
      expect(during.searchTerm, 'ca');

      // Back to a non-search state, as another screen's event would do.
      bloc.emit(DashboardInitial(pickImage: null, pickLocation: ''));
      await tester.pump();
      await tester.pump();
      tester.takeException();

      final after =
          tester.widget<ListOfStreamWidget>(find.byType(ListOfStreamWidget));
      expect(after.subCategoryName, selectedName);
      expect(after.subdescripion, selectedDescription);
      expect(after.searchTerm, '');
    });
  });

  group('submit details seeds the form from the selected event', () {
    testWidgets('both controllers hold the event on the first render',
        (tester) async {
      final form = await pumpSubmitDetails(tester);

      expect(form.eventType.text, selectedName);
      expect(form.about.text, selectedDescription);
    });

    testWidgets('both fields stay editable and independent', (tester) async {
      final form = await pumpSubmitDetails(tester);

      form.eventType.text = 'Reception';
      await tester.pump();

      // Editing one must not wipe the other.
      expect(form.about.text, selectedDescription);

      form.about.text = 'Smaller evening reception.';
      await tester.pump();

      expect(form.eventType.text, 'Reception');
    });

    testWidgets('a rebuild does not reset an edit', (tester) async {
      final form = await pumpSubmitDetails(tester);

      form.eventType.text = 'Reception';
      await tester.pump();
      await tester.pump();

      // initState seeds once; later frames must leave the user's text alone.
      expect(form.eventType.text, 'Reception');
    });

    testWidgets('arriving with no event leaves the fields empty, not filled',
        (tester) async {
      final form = await pumpSubmitDetails(
        tester,
        name: null,
        description: null,
      );

      expect(form.eventType.text, '');
      expect(form.about.text, '');
    });
  });
}
