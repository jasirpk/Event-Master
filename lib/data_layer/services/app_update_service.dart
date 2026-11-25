import 'dart:async';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// How urgently the installed build needs replacing.
enum AppUpdateRequirement {
  /// Nothing to do — the installed build is current, or the check could not
  /// reach a verdict it is safe to act on.
  none,

  /// A newer build exists and the user may postpone it.
  optional,

  /// The installed build is below the minimum the backend still supports, so
  /// it must not be allowed any further into the app.
  mandatory,
}

/// The verdict of one version check, plus everything the update screen needs
/// to render itself and reach the right store listing.
@immutable
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.requirement,
    required this.currentVersion,
    required this.currentBuild,
    required this.latestVersion,
    required this.latestBuild,
    required this.message,
    required this.storeUrl,
    this.nativeStoreUrl,
  });

  /// The "carry on as before" verdict, used whenever the check cannot produce
  /// a trustworthy answer. Deliberately the cheapest possible value to build
  /// so that no failure path can itself fail.
  const AppUpdateInfo.none()
      : requirement = AppUpdateRequirement.none,
        currentVersion = '',
        currentBuild = 0,
        latestVersion = '',
        latestBuild = 0,
        message = '',
        storeUrl = '',
        nativeStoreUrl = null;

  final AppUpdateRequirement requirement;

  /// Marketing version of the installed build, e.g. `1.0.0`.
  final String currentVersion;

  /// Build number of the installed build, e.g. `2`.
  final int currentBuild;

  /// Marketing version being offered, straight from Remote Config.
  final String latestVersion;
  final int latestBuild;

  /// Copy shown under the heading, straight from Remote Config.
  final String message;

  /// The https listing for this platform, or empty when none could be
  /// trusted. Empty never reaches an optional prompt — see [AppUpdateService]
  /// — but it can reach a mandatory one, because dropping the block would be
  /// worse than showing a screen that explains why the button is missing.
  final String storeUrl;

  /// A scheme that opens the platform's store app directly (`market://` on
  /// Android, `itms-apps://` on iOS). Tried first, with [storeUrl] as the
  /// fallback, because the store app gives a one-tap install.
  final String? nativeStoreUrl;

  /// Whether the user must update before going any further.
  bool get isBlocking => requirement == AppUpdateRequirement.mandatory;

  /// Whether an update screen should be shown at all.
  bool get shouldPrompt => requirement != AppUpdateRequirement.none;

  /// Whether there is somewhere to send the user. False means the screen
  /// shows an explanation instead of a store button.
  bool get hasStoreUrl => storeUrl.isNotEmpty;
}

/// The Remote Config values one update check depends on, already narrowed to
/// the types the decision needs.
///
/// Every field defaults to the "nothing published" value, so a source that
/// cannot answer at all still produces a bag that [AppUpdateService.resolve]
/// reads as "no update" rather than as a reason to block anyone.
@immutable
class AppUpdateConfig {
  const AppUpdateConfig({
    this.latestBuild = 0,
    this.minimumBuild = 0,
    this.latestVersion = '',
    this.updateMessage = '',
    this.playStoreUrl = '',
    this.appStoreUrl = '',
  });

  final int latestBuild;
  final int minimumBuild;
  final String latestVersion;
  final String updateMessage;
  final String playStoreUrl;
  final String appStoreUrl;
}

/// Where [AppUpdateService] gets its numbers.
///
/// Refresh and read are deliberately separate operations. [refresh] talks to
/// the network and may hang or throw; [read] is local and cannot. Keeping
/// them apart is what stops a slow network discarding a verdict: the service
/// time-boxes the first and always performs the second, so an activated
/// mandatory configuration survives a fetch that never arrives.
abstract class AppUpdateConfigSource {
  /// Registers defaults, applies settings and pulls new values.
  ///
  /// Allowed to throw and allowed to hang — the caller bounds both.
  Future<void> refresh();

  /// The values currently in force: whatever was last activated, else the
  /// registered defaults. Local, synchronous and independent of [refresh].
  AppUpdateConfig read();
}

/// The real source, backed by Firebase Remote Config.
class RemoteConfigSource implements AppUpdateConfigSource {
  RemoteConfigSource({FirebaseRemoteConfig? remoteConfig})
      : _override = remoteConfig;

  final FirebaseRemoteConfig? _override;

  // Resolved on use rather than in the constructor, so building a service
  // never touches Firebase.
  FirebaseRemoteConfig get _remoteConfig =>
      _override ?? FirebaseRemoteConfig.instance;

  /// Nothing here is caught: [AppUpdateService] catches the lot and falls
  /// through to [read]. That includes `setDefaults` and `setConfigSettings`,
  /// which can fail on their own — and when `setConfigSettings` is the one
  /// that fails, `fetchAndActivate` runs with Firebase's own 60-second fetch
  /// timeout instead of the five configured here, which is precisely why the
  /// caller puts a bound around this whole method rather than trusting
  /// [RemoteConfigSettings.fetchTimeout] alone.
  @override
  Future<void> refresh() async {
    await _remoteConfig.setDefaults(AppUpdateService.defaults);
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        // Release builds respect Firebase's throttling so startup does not
        // make a network round trip every launch; debug builds skip it so a
        // console change can be tested without waiting an hour.
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  /// Remote Config serves the last activated values from disk, so this
  /// answers correctly offline, and answers with [AppUpdateService.defaults]
  /// on a device that has never fetched.
  @override
  AppUpdateConfig read() {
    return AppUpdateConfig(
      latestBuild: _remoteConfig.getInt(AppUpdateService.keyLatestBuild),
      minimumBuild: _remoteConfig.getInt(AppUpdateService.keyMinimumBuild),
      latestVersion:
          _remoteConfig.getString(AppUpdateService.keyLatestVersion),
      updateMessage:
          _remoteConfig.getString(AppUpdateService.keyUpdateMessage),
      playStoreUrl: _remoteConfig.getString(AppUpdateService.keyPlayStoreUrl),
      appStoreUrl: _remoteConfig.getString(AppUpdateService.keyAppStoreUrl),
    );
  }
}

/// Compares the installed build against the numbers published in Firebase
/// Remote Config for project `event-master-2bf93`.
///
/// Remote Config separates the apps sharing that project with conditions on
/// `app.id`: `is_event_master_android` and `is_event_master_ios` match the
/// two Firebase app ids in `firebase_options.dart`, and the Admin Event Pro
/// conditions match different ones. The parameters live in a console
/// parameter group, which is organisational only — the SDK sees one flat key
/// namespace, so the plain key names below are what this app reads.
///
/// Every failure mode resolves to [AppUpdateInfo.none]: a missing config, an
/// unreachable network, an unparseable build number. Keeping a working app
/// out of the user's hands is a far worse outcome than missing an update
/// prompt, so the check only ever speaks up when it is certain.
class AppUpdateService {
  AppUpdateService({AppUpdateConfigSource? source})
      : _source = source ?? RemoteConfigSource();

  final AppUpdateConfigSource _source;

  // Remote Config parameter names. These must match the keys in the Firebase
  // console for project event-master-2bf93.
  static const String keyLatestBuild = 'latest_build_number';
  static const String keyMinimumBuild = 'minimum_supported_build_number';
  static const String keyLatestVersion = 'latest_version';
  static const String keyUpdateMessage = 'update_message';
  static const String keyPlayStoreUrl = 'play_store_url';
  static const String keyAppStoreUrl = 'app_store_url';

  /// Values used until a fetch succeeds, and whenever one never does.
  ///
  /// Both build numbers default to zero so that an un-fetched config can
  /// never satisfy `installed < latest` — a device that has never reached
  /// Remote Config behaves exactly as it did before this feature existed.
  static final Map<String, dynamic> defaults = <String, dynamic>{
    keyLatestBuild: 0,
    keyMinimumBuild: 0,
    keyLatestVersion: '',
    keyUpdateMessage: 'A new version of Event Master is available with the '
        'latest improvements and fixes.',
    keyPlayStoreUrl: '',
    keyAppStoreUrl: '',
  };

  /// Runs the whole check: refresh, read the values in force, read the
  /// installed version, compare.
  ///
  /// Two bounds, doing different jobs. [refreshTimeout] caps only the network
  /// leg; when it expires the check carries on and decides from the last
  /// activated values, so a slow or blackholed network costs a refresh and
  /// never a verdict. [timeout] is a backstop around everything else — in
  /// practice only `PackageInfo.fromPlatform` — and is set well clear of the
  /// refresh bound so that it cannot fire on a slow fetch.
  ///
  /// It is meant to be awaited concurrently with the splash dwell, so on a
  /// healthy device it costs nothing.
  Future<AppUpdateInfo> check({
    Duration timeout = const Duration(seconds: 10),
    Duration refreshTimeout = const Duration(seconds: 6),
  }) async {
    try {
      return await _check(refreshTimeout).timeout(timeout);
    } on TimeoutException {
      // Reaching here means something other than the fetch hung: the fetch
      // has its own, shorter bound and falls through rather than throwing.
      // Without an installed build number there is no verdict to keep, so
      // there is nothing to preserve by waiting longer.
      log('App update check timed out after ${timeout.inSeconds}s — '
          'continuing without a prompt');
      return const AppUpdateInfo.none();
    } catch (error) {
      log('App update check failed ($error) — continuing without a prompt');
      return const AppUpdateInfo.none();
    }
  }

  Future<AppUpdateInfo> _check(Duration refreshTimeout) async {
    final packageInfo = await PackageInfo.fromPlatform();

    // Bounded and swallowed, so execution always reaches the read below.
    await _refresh(refreshTimeout);

    final AppUpdateConfig config;
    try {
      config = _source.read();
    } catch (error) {
      // A read is local and should not fail. If it somehow does there is
      // nothing trustworthy to decide from, so nobody is prompted.
      log('Remote Config could not be read ($error) — continuing without a '
          'prompt');
      return const AppUpdateInfo.none();
    }

    return resolve(
      platform: defaultTargetPlatform,
      packageName: packageInfo.packageName,
      currentVersion: packageInfo.version,
      currentBuildNumber: packageInfo.buildNumber,
      latestBuild: config.latestBuild,
      minimumBuild: config.minimumBuild,
      latestVersion: config.latestVersion,
      updateMessage: config.updateMessage,
      configuredPlayUrl: config.playStoreUrl,
      configuredAppStoreUrl: config.appStoreUrl,
    );
  }

  /// Pulls new values, giving up after [timeout].
  ///
  /// Never throws and never rethrows. Every way a refresh can fail —
  /// `setDefaults`, `setConfigSettings`, the fetch itself, a wedged plugin
  /// channel that answers nothing at all — ends here, and the caller goes on
  /// to read whatever was last activated. An already activated mandatory
  /// update therefore survives every one of them.
  Future<void> _refresh(Duration timeout) async {
    try {
      await _source.refresh().timeout(timeout);
    } on TimeoutException {
      log('Remote Config refresh timed out after ${timeout.inSeconds}s — '
          'deciding from the last activated values');
    } catch (error) {
      log('Remote Config refresh failed ($error) — deciding from the last '
          'activated values');
    }
  }

  /// Turns one set of config values and one installed build into a verdict.
  ///
  /// Everything the decision depends on is a parameter, so every case the
  /// console can produce — an unset parameter, a build number the platform
  /// did not report, a missing store URL, a URL belonging to the other app
  /// sharing this Firebase project — is reachable from a test without a
  /// Firebase app. [_check] only gathers the inputs.
  ///
  /// A failed fetch needs no special case here: Remote Config serves the
  /// last activated values, or [defaults], so this is handed the same kind
  /// of value bag either way. In particular a mandatory verdict that came
  /// from cached values is reached again on the next launch even if that
  /// launch's refresh fails.
  @visibleForTesting
  static AppUpdateInfo resolve({
    required TargetPlatform platform,
    required String packageName,
    required String currentVersion,
    required String currentBuildNumber,
    required int latestBuild,
    required int minimumBuild,
    required String latestVersion,
    required String updateMessage,
    required String configuredPlayUrl,
    required String configuredAppStoreUrl,
  }) {
    final currentBuild = int.tryParse(currentBuildNumber.trim()) ?? 0;

    // Nothing sensible to compare against. Happens on platforms that do not
    // report a build number, and must not be read as "older than everything".
    if (currentBuild <= 0) {
      log('Installed build number "$currentBuildNumber" is not a positive '
          'integer — skipping the update check');
      return const AppUpdateInfo.none();
    }

    final requirement = requirementFor(
      currentBuild: currentBuild,
      latestBuild: latestBuild,
      minimumBuild: minimumBuild,
    );
    if (requirement == AppUpdateRequirement.none) {
      return const AppUpdateInfo.none();
    }

    final storeUrl = storeUrlFor(
      platform: platform,
      configuredPlayUrl: configuredPlayUrl,
      configuredAppStoreUrl: configuredAppStoreUrl,
      packageName: packageName,
    );

    // An optional prompt whose only button cannot work is pure noise, so it
    // is dropped. A mandatory one is kept: the installed build is below the
    // minimum the backend supports, and letting the user past it because the
    // console is missing a URL would defeat the whole point. The screen
    // renders an explanation in place of the button.
    if (storeUrl.isEmpty) {
      if (requirement == AppUpdateRequirement.optional) {
        log('No store URL configured for $platform — suppressing the '
            'optional update prompt');
        return const AppUpdateInfo.none();
      }
      log('No store URL configured for $platform — showing the mandatory '
          'update screen without a store button');
    }

    final message = updateMessage.trim();

    return AppUpdateInfo(
      requirement: requirement,
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      latestVersion: latestVersion.trim(),
      latestBuild: latestBuild,
      message:
          message.isNotEmpty ? message : defaults[keyUpdateMessage]! as String,
      storeUrl: storeUrl,
      nativeStoreUrl: nativeStoreUrlFor(
        platform: platform,
        storeUrl: storeUrl,
        packageName: packageName,
      ),
    );
  }

  /// Which kind of update, if any, the numbers call for.
  ///
  /// Pure and parameterised so the three rules can be exercised without a
  /// Firebase app. A non-positive [currentBuild] means the platform did not
  /// report a usable build number, which must never be read as "older than
  /// everything"; a non-positive Remote Config value means the parameter is
  /// unset, and an unset parameter never triggers a prompt.
  @visibleForTesting
  static AppUpdateRequirement requirementFor({
    required int currentBuild,
    required int latestBuild,
    required int minimumBuild,
  }) {
    if (currentBuild <= 0) return AppUpdateRequirement.none;
    if (minimumBuild > 0 && currentBuild < minimumBuild) {
      return AppUpdateRequirement.mandatory;
    }
    if (latestBuild > 0 && currentBuild < latestBuild) {
      return AppUpdateRequirement.optional;
    }
    return AppUpdateRequirement.none;
  }

  /// The https store listing for [platform], or an empty string when there is
  /// nothing safe to open.
  ///
  /// Remote Config is shared with Admin Event Pro, and the two apps are told
  /// apart only by console conditions. A condition that is edited, reordered
  /// or removed would hand this app Admin's listing — which installs a
  /// different application — so a configured Play URL is used only when it
  /// names the running package. Anything else is discarded in favour of a URL
  /// derived from the app's own id, which cannot point anywhere but here.
  @visibleForTesting
  static String storeUrlFor({
    required TargetPlatform platform,
    required String configuredPlayUrl,
    required String configuredAppStoreUrl,
    required String packageName,
  }) {
    switch (platform) {
      case TargetPlatform.android:
        final configured = configuredPlayUrl.trim();
        if (configured.isNotEmpty) {
          if (isPlayUrlFor(configured, packageName)) return configured;
          log('Configured play_store_url "$configured" does not name '
              '$packageName — ignoring it and deriving this app\'s own '
              'listing instead');
        }
        return 'https://play.google.com/store/apps/details?id=$packageName';
      case TargetPlatform.iOS:
        // Never Google Play, whatever the console holds. There is no
        // id-derived App Store URL either — the numeric Apple id is not
        // knowable from the bundle — so without a valid console value iOS
        // has nowhere to send the user.
        final configured = configuredAppStoreUrl.trim();
        if (configured.isEmpty) return '';
        if (isAppStoreUrl(configured)) return configured;
        log('Configured app_store_url "$configured" is not an App Store '
            'listing — ignoring it');
        return '';
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
    }
  }

  /// Whether [url] is a Play listing for [packageName] and nothing else.
  @visibleForTesting
  static bool isPlayUrlFor(String url, String packageName) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    if (uri.host != 'play.google.com') return false;
    return uri.queryParameters['id'] == packageName;
  }

  /// Whether [url] is an Apple store listing. There is no per-app check to
  /// make here — the numeric id cannot be derived from the bundle — so this
  /// only rules out a value that would open something other than the App
  /// Store.
  @visibleForTesting
  static bool isAppStoreUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    return uri.host == 'apps.apple.com' || uri.host == 'itunes.apple.com';
  }

  /// The scheme that hands the user straight to the installed store app.
  @visibleForTesting
  static String? nativeStoreUrlFor({
    required TargetPlatform platform,
    required String storeUrl,
    required String packageName,
  }) {
    switch (platform) {
      case TargetPlatform.android:
        // Empty when there is no listing at all, so the screen does not offer
        // a button that resolves to nothing.
        if (storeUrl.isEmpty) return null;
        return 'market://details?id=$packageName';
      case TargetPlatform.iOS:
        return storeUrl.startsWith('https://')
            ? storeUrl.replaceFirst('https://', 'itms-apps://')
            : null;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return null;
    }
  }
}
