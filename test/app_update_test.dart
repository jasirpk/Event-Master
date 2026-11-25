import 'dart:async';

import 'package:event_master/data_layer/services/app_update_service.dart';
import 'package:event_master/presentation/pages/onboarding/update_available_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The decisions the Event Master update gate makes, and what the update
/// screen offers once it has made one.
///
/// The Remote Config fetch itself needs a Firebase app, so it is not
/// exercised here. What is covered is everything the fetch feeds — which
/// build numbers mean which kind of update, which store listing each platform
/// is sent to, what happens when the console is missing a value or holds the
/// other app's URL, and whether the screen leaves a way out. Those are the
/// parts that can either strand a user or send them to the wrong app.
void main() {
  // The real identifiers, so a test that passes here is a test about this
  // app. Android comes from android/app/build.gradle; iOS from
  // ios/Runner.xcodeproj (still the flutter create placeholder).
  const String androidPackage = 'apps.client.event_master';
  const String iosBundle = 'com.example.eventMaster';

  // The live values under the is_event_master_* Remote Config conditions,
  // read from the console template for project event-master-2bf93.
  const String liveEventMasterPlayUrl =
      'https://play.google.com/store/apps/details?id=apps.client.event_master';
  const String liveAdminPlayUrl =
      'https://play.google.com/store/apps/details?id=apps.admin.admineventpro';

  AppUpdateInfo resolveAndroid({
    String currentBuildNumber = '2',
    int latestBuild = 2,
    int minimumBuild = 2,
    String latestVersion = '1.0.0',
    String updateMessage = 'A new version of Event Master is available.',
    String playUrl = liveEventMasterPlayUrl,
    String appStoreUrl = '',
  }) {
    return AppUpdateService.resolve(
      platform: TargetPlatform.android,
      packageName: androidPackage,
      currentVersion: '1.0.0',
      currentBuildNumber: currentBuildNumber,
      latestBuild: latestBuild,
      minimumBuild: minimumBuild,
      latestVersion: latestVersion,
      updateMessage: updateMessage,
      configuredPlayUrl: playUrl,
      configuredAppStoreUrl: appStoreUrl,
    );
  }

  AppUpdateInfo resolveIos({
    String currentBuildNumber = '2',
    int latestBuild = 2,
    int minimumBuild = 2,
    String playUrl = '',
    String appStoreUrl = '',
  }) {
    return AppUpdateService.resolve(
      platform: TargetPlatform.iOS,
      packageName: iosBundle,
      currentVersion: '1.0.0',
      currentBuildNumber: currentBuildNumber,
      latestBuild: latestBuild,
      minimumBuild: minimumBuild,
      latestVersion: '1.0.0',
      updateMessage: 'A new version of Event Master is available.',
      configuredPlayUrl: playUrl,
      configuredAppStoreUrl: appStoreUrl,
    );
  }

  // ------------------------------------------------------- 1, 2, 3: verdicts

  group('which update the build numbers call for', () {
    test('installed build equals latest — nothing to prompt (case A)', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 2, latestBuild: 2, minimumBuild: 2),
        AppUpdateRequirement.none,
      );
    });

    test('installed build ahead of latest — nothing to prompt', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 5, latestBuild: 3, minimumBuild: 2),
        AppUpdateRequirement.none,
      );
    });

    test('below latest but at or above the minimum — optional (case B)', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 2, latestBuild: 4, minimumBuild: 2),
        AppUpdateRequirement.optional,
      );
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 3, latestBuild: 4, minimumBuild: 2),
        AppUpdateRequirement.optional,
      );
    });

    test('below the minimum — mandatory (case C)', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 1, latestBuild: 4, minimumBuild: 2),
        AppUpdateRequirement.mandatory,
      );
    });

    test('the minimum outranks the latest when both would fire', () {
      // The live Event Master configuration: latest and minimum are both 2,
      // so build 1 is blocked rather than merely nudged.
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 1, latestBuild: 2, minimumBuild: 2),
        AppUpdateRequirement.mandatory,
      );
    });

    test('the live Event Master config leaves build 2 alone', () {
      // latest_build_number = 2 and minimum_supported_build_number = 2 for
      // both is_event_master_* conditions, against pubspec 1.0.0+2.
      expect(resolveAndroid().shouldPrompt, isFalse);
      expect(resolveIos().shouldPrompt, isFalse);
    });

    test('an optional update carries both versions and a store URL', () {
      final info = resolveAndroid(latestBuild: 4, latestVersion: '1.1.0');

      expect(info.requirement, AppUpdateRequirement.optional);
      expect(info.isBlocking, isFalse);
      expect(info.currentVersion, '1.0.0');
      expect(info.currentBuild, 2);
      expect(info.latestVersion, '1.1.0');
      expect(info.latestBuild, 4);
      expect(info.storeUrl, liveEventMasterPlayUrl);
      expect(info.nativeStoreUrl, 'market://details?id=$androidPackage');
    });

    test('a mandatory update blocks and still carries a store URL', () {
      final info = resolveAndroid(
        currentBuildNumber: '1',
        latestBuild: 4,
        minimumBuild: 2,
      );

      expect(info.requirement, AppUpdateRequirement.mandatory);
      expect(info.isBlocking, isTrue);
      expect(info.hasStoreUrl, isTrue);
    });
  });

  // ------------------------------------------------- 4, 8: missing / unfetched

  group('a configuration that could not be read', () {
    test('every parameter unset never prompts, on either platform', () {
      // What a device sees when the very first fetch fails: the registered
      // defaults, which are deliberately zero.
      expect(
        resolveAndroid(latestBuild: 0, minimumBuild: 0, playUrl: '')
            .shouldPrompt,
        isFalse,
      );
      expect(
        resolveIos(latestBuild: 0, minimumBuild: 0).shouldPrompt,
        isFalse,
      );
    });

    test('the zero defaults are the ones the service registers', () {
      expect(AppUpdateService.defaults[AppUpdateService.keyLatestBuild], 0);
      expect(AppUpdateService.defaults[AppUpdateService.keyMinimumBuild], 0);
      expect(AppUpdateService.defaults[AppUpdateService.keyPlayStoreUrl], '');
      expect(AppUpdateService.defaults[AppUpdateService.keyAppStoreUrl], '');
    });

    test('an empty update_message falls back to the packaged copy', () {
      final info = resolveAndroid(latestBuild: 4, updateMessage: '   ');

      expect(info.message, AppUpdateService.defaults['update_message']);
      expect(info.message, contains('Event Master'));
    });

    test('a missing latest_version degrades to the build number alone', () {
      final info = resolveAndroid(latestBuild: 4, latestVersion: '');
      expect(info.latestVersion, isEmpty);
      expect(info.latestBuild, 4);
    });

    test(
        'a refresh that fails does not downgrade a mandatory verdict: the '
        'cached values still resolve to the same block', () {
      // fetchAndActivate throwing leaves the previously activated values in
      // place, so resolve() is handed the same bag it was handed last time.
      final info = resolveAndroid(currentBuildNumber: '1', minimumBuild: 2);
      expect(info.requirement, AppUpdateRequirement.mandatory);
    });
  });

  // ---------------------------------------------------- 5: bad build numbers

  group('a build number that is not a positive integer', () {
    test('is never read as "older than everything"', () {
      for (final raw in <String>['', '   ', '0', '-1', 'abc', '1.0.0', '2b']) {
        expect(
          resolveAndroid(currentBuildNumber: raw, latestBuild: 999)
              .shouldPrompt,
          isFalse,
          reason: 'build number "$raw" must not trigger a prompt',
        );
      }
    });

    test('a padded build number is still read', () {
      expect(
        resolveAndroid(currentBuildNumber: ' 1 ', minimumBuild: 2).isBlocking,
        isTrue,
      );
    });

    test('the same guard sits in requirementFor', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 0, latestBuild: 999, minimumBuild: 999),
        AppUpdateRequirement.none,
      );
      expect(
        AppUpdateService.requirementFor(
            currentBuild: -1, latestBuild: 999, minimumBuild: 999),
        AppUpdateRequirement.none,
      );
    });
  });

  // ------------------------------------------------------ 6, 7: store URLs

  group('where each platform is sent', () {
    test('Android uses the configured Event Master listing', () {
      expect(
        AppUpdateService.storeUrlFor(
          platform: TargetPlatform.android,
          configuredPlayUrl: liveEventMasterPlayUrl,
          configuredAppStoreUrl: '',
          packageName: androidPackage,
        ),
        liveEventMasterPlayUrl,
      );
    });

    test('Android with no configured URL derives its own listing', () {
      expect(
        AppUpdateService.storeUrlFor(
          platform: TargetPlatform.android,
          configuredPlayUrl: '   ',
          configuredAppStoreUrl: '',
          packageName: androidPackage,
        ),
        'https://play.google.com/store/apps/details?id=$androidPackage',
      );
    });

    test(
        'Admin Event Pro\'s listing is rejected and replaced with this app\'s '
        'own, however it reached the config', () {
      // The two apps share one Remote Config template and are told apart only
      // by console conditions, so a mis-edited condition is a realistic way
      // to be handed the wrong listing — which would install a different
      // application.
      final url = AppUpdateService.storeUrlFor(
        platform: TargetPlatform.android,
        configuredPlayUrl: liveAdminPlayUrl,
        configuredAppStoreUrl: '',
        packageName: androidPackage,
      );

      expect(url, isNot(contains('admineventpro')));
      expect(url, 'https://play.google.com/store/apps/details?id=$androidPackage');
    });

    test('a Play URL that is not a Play URL is rejected', () {
      for (final bad in <String>[
        'http://play.google.com/store/apps/details?id=$androidPackage',
        'https://evil.example/store/apps/details?id=$androidPackage',
        'https://play.google.com/store/apps/details',
        'not a url at all ::::',
      ]) {
        expect(
          AppUpdateService.isPlayUrlFor(bad, androidPackage),
          isFalse,
          reason: '"$bad" must not be trusted',
        );
      }
      expect(
        AppUpdateService.isPlayUrlFor(liveEventMasterPlayUrl, androidPackage),
        isTrue,
      );
    });

    test('iOS is never sent to Google Play, even when Play is configured', () {
      final url = AppUpdateService.storeUrlFor(
        platform: TargetPlatform.iOS,
        configuredPlayUrl: liveEventMasterPlayUrl,
        configuredAppStoreUrl: '',
        packageName: iosBundle,
      );

      expect(url, isEmpty);
      expect(url, isNot(contains('play.google.com')));
    });

    test('iOS uses app_store_url once the console provides one', () {
      expect(
        AppUpdateService.storeUrlFor(
          platform: TargetPlatform.iOS,
          configuredPlayUrl: '',
          configuredAppStoreUrl: 'https://apps.apple.com/app/id123456789',
          packageName: iosBundle,
        ),
        'https://apps.apple.com/app/id123456789',
      );
    });

    test('an app_store_url pointing somewhere other than Apple is rejected',
        () {
      expect(
        AppUpdateService.storeUrlFor(
          platform: TargetPlatform.iOS,
          configuredPlayUrl: '',
          configuredAppStoreUrl: liveAdminPlayUrl,
          packageName: iosBundle,
        ),
        isEmpty,
      );
      expect(AppUpdateService.isAppStoreUrl('https://apps.apple.com/x'), isTrue);
      expect(
          AppUpdateService.isAppStoreUrl('https://itunes.apple.com/x'), isTrue);
      expect(AppUpdateService.isAppStoreUrl('http://apps.apple.com/x'), isFalse);
      expect(AppUpdateService.isAppStoreUrl(''), isFalse);
    });

    test('a desktop platform gets nothing, which suppresses the gate', () {
      for (final platform in <TargetPlatform>[
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        expect(
          AppUpdateService.storeUrlFor(
            platform: platform,
            configuredPlayUrl: liveEventMasterPlayUrl,
            configuredAppStoreUrl: 'https://apps.apple.com/x',
            packageName: androidPackage,
          ),
          isEmpty,
        );
      }
    });

    test('the native scheme opens the store app on each platform', () {
      expect(
        AppUpdateService.nativeStoreUrlFor(
          platform: TargetPlatform.android,
          storeUrl: liveEventMasterPlayUrl,
          packageName: androidPackage,
        ),
        'market://details?id=$androidPackage',
      );
      expect(
        AppUpdateService.nativeStoreUrlFor(
          platform: TargetPlatform.iOS,
          storeUrl: 'https://apps.apple.com/app/id123456789',
          packageName: iosBundle,
        ),
        'itms-apps://apps.apple.com/app/id123456789',
      );
      expect(
        AppUpdateService.nativeStoreUrlFor(
          platform: TargetPlatform.iOS,
          storeUrl: '',
          packageName: iosBundle,
        ),
        isNull,
      );
      expect(
        AppUpdateService.nativeStoreUrlFor(
          platform: TargetPlatform.android,
          storeUrl: '',
          packageName: androidPackage,
        ),
        isNull,
      );
    });
  });

  group('a platform with no listing configured', () {
    test('drops an optional prompt rather than show a dead button', () {
      // Today\'s iOS configuration: app_store_url is empty under every
      // condition, so there is nowhere to send the user.
      final info = resolveIos(latestBuild: 4, minimumBuild: 2);
      expect(info.shouldPrompt, isFalse);
    });

    test('keeps a mandatory block, with no store URL to offer', () {
      final info =
          resolveIos(currentBuildNumber: '1', latestBuild: 2, minimumBuild: 2);

      expect(info.requirement, AppUpdateRequirement.mandatory);
      expect(info.isBlocking, isTrue);
      expect(info.hasStoreUrl, isFalse,
          reason: 'the screen shows an explanation in place of the button');
    });
  });

  // ----------------------------- a slow network must not discard a verdict

  group('a refresh that never arrives', () {
    // The whole point of splitting refresh from read: the network leg is
    // bounded on its own, and the values already on the device are read
    // whatever becomes of it. Before that split, one 6s bound wrapped both
    // and a slow fetch could turn an activated mandatory update into "no
    // update" for that launch.

    const activatedMandatory = AppUpdateConfig(
      latestBuild: 4,
      minimumBuild: 3,
      latestVersion: '1.2.0',
      updateMessage: 'This version is no longer supported.',
      playStoreUrl: liveEventMasterPlayUrl,
    );

    const activatedOptional = AppUpdateConfig(
      latestBuild: 4,
      minimumBuild: 2,
      latestVersion: '1.2.0',
      updateMessage: 'A new version of Event Master is available.',
      playStoreUrl: liveEventMasterPlayUrl,
    );

    // What a device that has never completed a fetch sees: the registered
    // defaults, every one of them zero or empty.
    const nothingActivated = AppUpdateConfig();

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // The installed build: below activatedMandatory's minimum of 3, and
      // below activatedOptional's latest of 4.
      PackageInfo.setMockInitialValues(
        appName: 'Event Master',
        packageName: androidPackage,
        version: '1.0.0',
        buildNumber: '2',
        buildSignature: '',
      );
      // Outside a widget test defaultTargetPlatform reports the host, which
      // would send every case down the desktop branch and suppress the gate.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() => debugDefaultTargetPlatformOverride = null);

    /// Checks with a refresh bound short enough to keep the suite quick.
    Future<AppUpdateInfo> check(_FakeSource source) => AppUpdateService(
          source: source,
        ).check(
          refreshTimeout: const Duration(milliseconds: 50),
          timeout: const Duration(seconds: 5),
        );

    test('an activated mandatory update survives a fetch that hangs',
        () async {
      final source = _FakeSource(
        activated: activatedMandatory,
        // Never completes — a blackholed network, or a wedged plugin
        // channel that answers nothing at all.
        onRefresh: () => Completer<void>().future,
      );

      final info = await check(source);

      expect(info.requirement, AppUpdateRequirement.mandatory,
          reason: 'the block was already activated on this device');
      expect(info.isBlocking, isTrue);
      expect(source.reads, 1,
          reason: 'the cached values must still be read after the timeout');
    });

    test('an activated mandatory update survives a fetch that throws',
        () async {
      final source = _FakeSource(
        activated: activatedMandatory,
        onRefresh: () async => throw StateError('no network'),
      );

      final info = await check(source);

      expect(info.requirement, AppUpdateRequirement.mandatory);
      expect(source.reads, 1);
    });

    test(
        'setDefaults or setConfigSettings failing is handled like any other '
        'refresh failure', () async {
      // Those two calls sit inside refresh() with nothing catching them
      // there, so they arrive at the service as an ordinary failure.
      final source = _FakeSource(
        activated: activatedMandatory,
        onRefresh: () async =>
            throw PlatformException(code: 'channel-error'),
      );

      final info = await check(source);

      expect(info.requirement, AppUpdateRequirement.mandatory);
      expect(source.reads, 1);
    });

    test('a cached optional update survives a fetch failure', () async {
      final source = _FakeSource(
        activated: activatedOptional,
        onRefresh: () async => throw StateError('no network'),
      );

      final info = await check(source);

      expect(info.requirement, AppUpdateRequirement.optional);
      expect(info.latestBuild, 4);
      expect(info.latestVersion, '1.2.0');
      expect(info.storeUrl, liveEventMasterPlayUrl);
    });

    test(
        'nothing activated plus a failed fetch still fails open — a device '
        'that has never reached Remote Config behaves as before', () async {
      final source = _FakeSource(
        activated: nothingActivated,
        onRefresh: () async => throw StateError('no network'),
      );

      final info = await check(source);

      expect(info.shouldPrompt, isFalse);
      expect(source.reads, 1,
          reason: 'the read happens either way; it simply has nothing to say');
    });

    test('a refresh that succeeds is still read from, not bypassed', () async {
      final source = _FakeSource(activated: activatedMandatory);

      final info = await check(source);

      expect(source.refreshes, 1);
      expect(source.reads, 1);
      expect(info.requirement, AppUpdateRequirement.mandatory);
    });

    test('a read that throws is the one case that gives up', () async {
      final source = _FakeSource(activated: activatedMandatory, failRead: true);

      final info = await check(source);

      expect(info.requirement, AppUpdateRequirement.none,
          reason: 'nothing trustworthy to decide from');
    });
  });

  // ------------------------------------------------------------- the screen

  group('the update screen', () {
    const optional = AppUpdateInfo(
      requirement: AppUpdateRequirement.optional,
      currentVersion: '1.0.0',
      currentBuild: 2,
      latestVersion: '1.1.0',
      latestBuild: 4,
      message: 'Faster browsing and a redesigned booking flow.',
      storeUrl: liveEventMasterPlayUrl,
      nativeStoreUrl: 'market://details?id=$androidPackage',
    );

    const mandatory = AppUpdateInfo(
      requirement: AppUpdateRequirement.mandatory,
      currentVersion: '0.9.0',
      currentBuild: 1,
      latestVersion: '1.0.0',
      latestBuild: 2,
      message: 'This version is no longer supported.',
      storeUrl: liveEventMasterPlayUrl,
      nativeStoreUrl: 'market://details?id=$androidPackage',
    );

    const mandatoryWithoutStore = AppUpdateInfo(
      requirement: AppUpdateRequirement.mandatory,
      currentVersion: '0.9.0',
      currentBuild: 1,
      latestVersion: '1.0.0',
      latestBuild: 2,
      message: 'This version is no longer supported.',
      storeUrl: '',
    );

    Future<void> pumpScreen(
      WidgetTester tester,
      AppUpdateInfo info, {
      VoidCallback? onLater,
    }) async {
      await tester.pumpWidget(MaterialApp(
        home: UpdateAvailableScreen(info: info, onLater: onLater),
      ));
      await tester.pump();
    }

    testWidgets('shows the heading, the message and both versions',
        (tester) async {
      await pumpScreen(tester, optional, onLater: () {});

      expect(find.text('Update Available'), findsOneWidget);
      expect(find.text(optional.message), findsOneWidget);
      expect(find.text('1.0.0 (2)'), findsOneWidget);
      expect(find.text('1.1.0 (4)'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);
    });

    testWidgets('an optional update offers Later and it continues',
        (tester) async {
      var continued = 0;
      await pumpScreen(tester, optional, onLater: () => continued++);

      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Required update'), findsNothing);

      await tester.tap(find.text('Later'));
      await tester.pump();
      expect(continued, 1);
    });

    testWidgets('a mandatory update has no way past it', (tester) async {
      await pumpScreen(tester, mandatory);

      expect(find.text('Later'), findsNothing);
      expect(find.text('Required update'), findsOneWidget);
      expect(find.textContaining('required to continue'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse,
          reason: 'the system back gesture must not dismiss it');
    });

    testWidgets(
        'a mandatory update with no store URL keeps the block and explains '
        'itself instead of offering a dead button', (tester) async {
      await pumpScreen(tester, mandatoryWithoutStore);

      expect(find.text('Update Now'), findsNothing);
      expect(find.text('Later'), findsNothing);
      expect(find.text('Required update'), findsOneWidget);
      expect(find.textContaining('No store link is available'), findsOneWidget);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });

    /// Stands in for the platform's launcher. [openable] decides which URLs
    /// it claims to have opened; every attempt is recorded.
    ///
    /// Without this the channel has no handler at all and the launch future
    /// never completes, which is a property of the test environment rather
    /// than of any device — a real launcher always answers.
    List<String> mockLauncher(
      WidgetTester tester, {
      required bool Function(String url) openable,
    }) {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      final attempted = <String>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method != 'launch') return false;
        final url = (call.arguments as Map)['url'] as String;
        attempted.add(url);
        return openable(url);
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      return attempted;
    }

    testWidgets('a store launch that fails says so and offers a retry',
        (tester) async {
      final attempted = mockLauncher(tester, openable: (_) => false);
      await pumpScreen(tester, optional, onLater: () {});

      await tester.tap(find.text('Update Now'));
      await tester.pumpAndSettle();

      // Both routes tried before giving up: the store app, then the browser.
      expect(attempted, [optional.nativeStoreUrl, optional.storeUrl]);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.textContaining('could not open the store'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the store app is preferred, and the browser is the fallback',
        (tester) async {
      final attempted =
          mockLauncher(tester, openable: (url) => url.startsWith('https://'));
      await pumpScreen(tester, optional, onLater: () {});

      await tester.tap(find.text('Update Now'));
      await tester.pumpAndSettle();

      expect(attempted, [optional.nativeStoreUrl, optional.storeUrl]);
      expect(find.text('Update Now'), findsOneWidget,
          reason: 'the https fallback worked, so nothing failed');
      expect(find.textContaining('could not open the store'), findsNothing);
    });

    testWidgets('a mandatory update that cannot reach the store stays blocked',
        (tester) async {
      mockLauncher(tester, openable: (_) => false);
      await pumpScreen(tester, mandatory);

      await tester.tap(find.text('Update Now'));
      await tester.pumpAndSettle();

      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Later'), findsNothing,
          reason: 'a failed launch must not become a way past the block');
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
    });

    testWidgets('falls back to the build number when no version is published',
        (tester) async {
      await pumpScreen(
        tester,
        const AppUpdateInfo(
          requirement: AppUpdateRequirement.optional,
          currentVersion: '1.0.0',
          currentBuild: 2,
          latestVersion: '',
          latestBuild: 4,
          message: 'Update available.',
          storeUrl: liveEventMasterPlayUrl,
        ),
        onLater: () {},
      );

      expect(find.text('Build 4'), findsOneWidget);
    });

    testWidgets('renders within a short screen without overflowing',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1680);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pumpScreen(tester, optional, onLater: () {});
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

/// A source whose refresh behaviour the test chooses, and whose read always
/// returns the values the device is treated as already holding.
class _FakeSource implements AppUpdateConfigSource {
  _FakeSource({
    required this.activated,
    this.onRefresh,
    this.failRead = false,
  });

  final AppUpdateConfig activated;

  /// null means a refresh that completes immediately and successfully.
  final Future<void> Function()? onRefresh;
  final bool failRead;

  int refreshes = 0;
  int reads = 0;

  @override
  Future<void> refresh() {
    refreshes++;
    return onRefresh?.call() ?? Future<void>.value();
  }

  @override
  AppUpdateConfig read() {
    reads++;
    if (failRead) throw StateError('read failed');
    return activated;
  }
}
