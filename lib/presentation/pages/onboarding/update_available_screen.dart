import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/app_update_service.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:event_master/presentation/pages/onboarding/splash_screen.dart'
    show kSplashLogoAsset;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The screen shown between the splash and the rest of the app when a newer
/// build is available.
///
/// It is always pushed with `Get.offAll`, so it owns the whole stack: there is
/// nothing underneath it to pop back to, and it can never appear on top of
/// Home. [onLater] is the only way forward and is null for a mandatory
/// update, which together with the [PopScope] below leaves the store button as
/// the single exit.
class UpdateAvailableScreen extends StatefulWidget {
  const UpdateAvailableScreen({
    super.key,
    required this.info,
    this.onLater,
  });

  final AppUpdateInfo info;

  /// Continues the normal authentication routing. Null when the update is
  /// mandatory, which also hides the "Maybe Later" button.
  final VoidCallback? onLater;

  @override
  State<UpdateAvailableScreen> createState() => _UpdateAvailableScreenState();
}

class _UpdateAvailableScreenState extends State<UpdateAvailableScreen> {
  bool _launching = false;
  bool _launchFailed = false;

  bool get _isBlocking => widget.onLater == null;

  Future<void> _openStore() async {
    // Guards the double tap: the store takes a moment to come to the front
    // and the button stays on screen throughout.
    if (_launching) return;

    setState(() {
      _launching = true;
      _launchFailed = false;
    });

    final opened = await _launchStore();

    if (!mounted) return;
    setState(() {
      _launching = false;
      _launchFailed = !opened;
    });
  }

  /// Tries the store app first, then the browser.
  ///
  /// `canLaunchUrl` is deliberately not used: resolving `market://` on
  /// Android 11+ needs a `<queries>` manifest entry, and failing that it
  /// reports false for a scheme that would in fact have opened. Attempting
  /// the launch and falling through on failure needs no manifest change.
  Future<bool> _launchStore() async {
    final native = widget.info.nativeStoreUrl;
    if (native != null && native.isNotEmpty) {
      if (await _tryLaunch(native)) return true;
    }
    return _tryLaunch(widget.info.storeUrl);
  }

  Future<bool> _tryLaunch(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 700;
    final hasStore = widget.info.hasStoreUrl;

    return PopScope(
      // A mandatory update must not be dismissed with the system back
      // gesture. An optional one has nothing beneath it to pop back to
      // either, so blocking the pop simply makes "Maybe Later" the only
      // deliberate way on.
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isCompact ? 20 : 32,
              ),
              child: ConstrainedBox(
                // Keeps the column readable on a tablet instead of letting
                // the body text run the full width.
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Logo(compact: isCompact),
                    SizedBox(height: isCompact ? 22 : 30),
                    if (_isBlocking) ...[
                      const _RequiredBadge(),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      'Update Available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kTextPrimary,
                        fontFamily: 'JacquesFracois',
                        fontSize: isCompact ? 24 : 27,
                        letterSpacing: 0.6,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.info.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kTextSecondary,
                        fontSize: 14.5,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (_isBlocking) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'This version is no longer supported. Updating is '
                        'required to continue using Event Master.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kTextMuted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                    SizedBox(height: isCompact ? 22 : 28),
                    _VersionCard(
                      installed: _label(
                        widget.info.currentVersion,
                        widget.info.currentBuild,
                      ),
                      latest: _label(
                        widget.info.latestVersion,
                        widget.info.latestBuild,
                      ),
                    ),
                    if (hasStore && _launchFailed) ...[
                      const SizedBox(height: 16),
                      const _Notice(
                        'We could not open the store. Check your connection '
                        'and tap Try again.',
                      ),
                    ],
                    // No listing to send anyone to. Only a mandatory update
                    // gets this far — the service drops an optional one
                    // rather than show a dead button — so the block stays in
                    // place and the screen says why there is nothing to tap.
                    if (!hasStore) ...[
                      const SizedBox(height: 16),
                      const _Notice(
                        'No store link is available for this device yet. '
                        'Please install the latest Event Master build from '
                        'your app store to continue.',
                      ),
                    ],
                    SizedBox(height: isCompact ? 22 : 28),
                    if (hasStore)
                      PushableButton_Widget(
                        buttonText: _launching
                            ? 'Opening store…'
                            : (_launchFailed ? 'Try again' : 'Update Now'),
                        onpressed: _openStore,
                      ),
                    if (!_isBlocking) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _launching ? null : widget.onLater,
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: kTextSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(kRadiusField),
                          ),
                        ),
                        child: const Text(
                          'Later',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `1.0.0 (2)`, or just the build when Remote Config carries no marketing
  /// version for the release.
  static String _label(String version, int build) {
    if (version.isEmpty) return 'Build $build';
    return '$version ($build)';
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 108 : 128;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: myColor.withValues(alpha: 0.08),
          border: Border.all(color: myColor.withValues(alpha: 0.22)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(size * 0.2),
              child: Image.asset(
                kSplashLogoAsset,
                fit: BoxFit.contain,
                // The screen still has to read correctly if the asset is
                // ever renamed, so fall back to a glyph rather than the
                // framework's broken-image box.
                errorBuilder: (_, __, ___) => Icon(
                  Icons.system_update_alt_rounded,
                  color: myColor,
                  size: size * 0.4,
                ),
              ),
            ),
            Positioned(
              right: size * 0.04,
              bottom: size * 0.04,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: myColor,
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: myColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: myColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 13, color: myColor),
            const SizedBox(width: 6),
            Text(
              'Required update',
              style: TextStyle(
                color: myColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.installed, required this.latest});

  final String installed;
  final String latest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _VersionSlot(
              label: 'Installed',
              value: installed,
              valueColor: kTextSecondary,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: kTextMuted,
            ),
          ),
          Expanded(
            child: _VersionSlot(
              label: 'Latest',
              value: latest,
              valueColor: myColor,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionSlot extends StatelessWidget {
  const _VersionSlot({
    required this.label,
    required this.value,
    required this.valueColor,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: kTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        // A long marketing version must shrink rather than overflow the half
        // of the card it has been given.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// A warning panel. Used both for a store launch that failed and for a
/// platform with no listing configured at all.
class _Notice extends StatelessWidget {
  const _Notice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    const Color warning = Color(0xFFFFB4A2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(kRadiusField),
        border: Border.all(color: warning.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 17, color: warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: warning.withValues(alpha: 0.92),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
