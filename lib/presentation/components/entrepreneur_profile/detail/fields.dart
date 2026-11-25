import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/linkds.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/medaia.dart';
import 'package:flutter/material.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// The scrolling body of the entrepreneur detail screen.
///
/// This widget is content only. The Book Now button used to live here as a
/// `Positioned` child of a `Stack` wrapped around the column — but a Stack
/// sizes to its largest *non-positioned* child, so `bottom: 16` measured from
/// the end of the content rather than the bottom of the screen. The column
/// reserved no space for it, so it was painted over whatever occupied the last
/// stretch of content — the phone number, on a short profile — and because the
/// whole stack sat inside the page's scroll view it scrolled away instead of
/// floating. The button is now the screen's `bottomNavigationBar`, which makes
/// overlap impossible by construction rather than by tuning an offset.
class DetailFieldsWidget extends StatefulWidget {
  const DetailFieldsWidget({
    super.key,
    required this.imagePath,
    required this.companyName,
    required this.screenHeight,
    required this.about,
    required this.phoneNumber,
    required this.bussinessEmail,
    required this.website,
    required this.links,
    required this.images,
    required this.onRatingSubmit,
    required this.onLoadUserRating,
    required this.onRatingRemove,
  });

  final String imagePath;
  final String companyName;

  /// Retained for the sections that still scale with the viewport (the media
  /// grid). Type sizes no longer derive from it: `screenHeight * 0.026` put
  /// the company name at ~25pt on a 17 Pro Max and ~16pt on an SE, so the
  /// screen read as a different design on each device.
  final double screenHeight;

  final String about;

  /// Null when the entrepreneur has not stored one. Each of these three is an
  /// optional field on the profile document, so null is an ordinary value
  /// here, not a fault — the row it belongs to is left out.
  final String? phoneNumber;
  final String? bussinessEmail;
  final String? website;

  /// Empty when the entrepreneur has added none.
  final List<Map<String, dynamic>> links;
  final List<Map<String, dynamic>> images;

  /// True when there is at least one contact detail to show. With none, the
  /// "More Details" heading stood over nothing.
  bool get hasContactDetails =>
      phoneNumber != null || bussinessEmail != null || website != null;

  /// Returns true when the rating was actually persisted by the backend.
  final Future<bool> Function(double) onRatingSubmit;

  /// Loads this user's existing rating, or null if they have not rated.
  final Future<double?> Function() onLoadUserRating;

  /// Removes this user's rating. Returns true when the backend confirmed it.
  final Future<bool> Function() onRatingRemove;

  @override
  State<DetailFieldsWidget> createState() => _DetailFieldsWidgetState();
}

class _DetailFieldsWidgetState extends State<DetailFieldsWidget> {
  // null means "this consumer has not rated yet" — no rating is ever
  // fabricated for display. Loaded once from the user's own rating document.
  double? _userRating;

  // Distinguishes "still loading" from "not rated", so the screen does not
  // claim the user has no rating before the answer has arrived.
  bool _loadingUserRating = true;

  // RatingBar.builder only reads `initialRating` when its State is created, so
  // the stars kept whatever position the user dragged them to — including
  // after cancelling the dialog, which left them showing a rating that was
  // never submitted. Bumping this rebuilds the bar from the stored value every
  // time the dialog closes.
  int _starsGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final rating = await widget.onLoadUserRating();
    if (!mounted) return;
    setState(() {
      _userRating = rating;
      _loadingUserRating = false;
    });
  }

  Future<void> _removeRating() async {
    final previous = _userRating;

    // Clear immediately, then restore if the backend refused — the same
    // optimistic pattern the submit path uses.
    setState(() {
      _userRating = null;
      _starsGeneration++;
    });

    final removed = await widget.onRatingRemove();

    if (!removed && mounted) {
      setState(() {
        _userRating = previous;
        _starsGeneration++;
      });
    }
  }

  void _showRatingDialog(BuildContext context, double initialRating) {
    showDialog(
      context: context,
      builder: (context) {
        double dialogRating = initialRating;
        return AlertDialog(
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusCard),
          ),
          title: Text(
            'Rate ${widget.companyName}',
            style: const TextStyle(
                color: kTextPrimary, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          content: RatingBar.builder(
            initialRating: initialRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            unratedColor: Colors.grey,
            onRatingUpdate: (rating) {
              dialogRating = rating;
            },
          ),
          actions: [
            // Only offered once a rating exists — there is nothing to remove
            // otherwise.
            if (_userRating != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _removeRating();
                },
                child: const Text(
                  'Remove rating',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Put the stars back where the stored rating says they belong.
                if (mounted) setState(() => _starsGeneration++);
              },
              child:
                  const Text('Cancel', style: TextStyle(color: kTextSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final previous = _userRating;

                // Show the new rating immediately, then roll back if the
                // backend rejected it — leaving a star lit for a write that
                // never persisted would misreport the outcome.
                setState(() {
                  _userRating = dialogRating;
                  _starsGeneration++;
                });
                Navigator.of(context).pop();

                final persisted = await widget.onRatingSubmit(dialogRating);

                if (!persisted && mounted) {
                  setState(() {
                    _userRating = previous;
                    _starsGeneration++;
                  });
                }
              },
              child: Text('Submit', style: TextStyle(color: myColor)),
            ),
          ],
        );
      },
    );
  }

  /// Opens a contact target in whatever app handles it.
  ///
  /// Silent on failure by design: a simulator or a device with no mail client
  /// is not a fault worth interrupting the user for, and the row stays
  /// readable either way.
  Future<void> _open(Uri uri) async {
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final about = widget.about.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileHeader(
          imagePath: widget.imagePath,
          companyName: widget.companyName,
          rating: _userRating,
          loading: _loadingUserRating,
          starsKey: ValueKey('$_userRating-$_starsGeneration'),
          onRatingUpdate: (rating) => _showRatingDialog(context, rating),
        ),

        // Every section below is drawn only when it has something in it. The
        // fields are optional on the stored document, and a heading over a
        // blank line — "Website:" with a bare blue underline, say — reads as a
        // loading failure rather than as "none given".
        if (about.isNotEmpty)
          _SectionCard(
            title: Assigns.aboutUs,
            child: Text(
              about,
              // No maxLines: a long description wraps and the page scrolls.
              // 1.55 line height is what makes a paragraph of this width
              // readable; at the default it set as a solid block.
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: kTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

        if (widget.hasContactDetails)
          _SectionCard(
            title: Assigns.moreDetail,
            padded: false,
            child: Column(
              children: [
                if (widget.phoneNumber case final phoneNumber?)
                  _ContactRow(
                    icon: Icons.call_outlined,
                    label: Assigns.phoneNumber,
                    value: phoneNumber,
                    // The number was already styled as a blue link but was not
                    // tappable. url_launcher is already a dependency.
                    onTap: () => _open(Uri(
                      scheme: 'tel',
                      path: phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
                    )),
                  ),
                if (widget.bussinessEmail case final email?)
                  _ContactRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: email,
                    onTap: () => _open(Uri(scheme: 'mailto', path: email)),
                  ),
                if (widget.website case final website?)
                  _ContactRow(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    value: website,
                    onTap: () => _open(_websiteUri(website)),
                  ),
              ],
            ),
          ),

        if (widget.links.isNotEmpty)
          _SectionCard(
            title: Assigns.otherLinks,
            padded: false,
            child: LinksWidget(widget: widget, onOpen: _open),
          ),

        if (widget.images.isNotEmpty)
          _SectionCard(
            title: Assigns.media,
            child: MediaWidget(widget: widget),
          ),
      ],
    );
  }
}

/// A stored website may or may not carry a scheme — the profile form accepts
/// "tathkarah.example" as readily as "https://tathkarah.example". Without one,
/// `Uri.parse` yields a relative reference that no browser will open.
Uri _websiteUri(String website) {
  final trimmed = website.trim();
  final hasScheme =
      trimmed.startsWith('http://') || trimmed.startsWith('https://');

  return Uri.parse(hasScheme ? trimmed : 'https://$trimmed');
}

/// Avatar, company name and rating, on one card.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.imagePath,
    required this.companyName,
    required this.rating,
    required this.loading,
    required this.starsKey,
    required this.onRatingUpdate,
  });

  final String imagePath;
  final String companyName;
  final double? rating;
  final bool loading;
  final Key starsKey;
  final ValueChanged<double> onRatingUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Was maxRadius 60 — a 120pt circle that took a third of the width
          // and pushed the name into a two-line column beside it.
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: myColor, width: 1.5),
            ),
            // An R2 object key needs signing; AssetImage asked for a bundled
            // "profile_images/..." asset and threw.
            child: MediaImage(
              imagePath: imagePath,
              placeholder: kMediaPlaceholderImage,
              builder: (context, image) => CircleAvatar(
                radius: 34,
                backgroundColor: kSurfaceAlt,
                backgroundImage: image,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  companyName,
                  // A long company name wraps to a second line rather than
                  // overflowing the row.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // RatingBar.builder reads `initialRating` only when its
                // State is created, and takes no key of its own. KeyedSubtree
                // gives it one, so a changed key remounts it from the stored
                // value and the stars cannot be left showing an unsubmitted
                // drag.
                KeyedSubtree(
                  key: starsKey,
                  child: RatingBar.builder(
                    initialRating: rating ?? 0,
                    minRating: 1,
                    itemSize: 18,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.only(right: 3),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    unratedColor: kBorder,
                    onRatingUpdate: onRatingUpdate,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loading
                      ? 'Loading your rating…'
                      : rating == null
                          ? 'Tap a star to rate'
                          : 'Your rating · ${rating!.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled card. One surface, one radius, one gap above — so the sections
/// stack consistently however many of them a profile happens to have.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.padded = true,
  });

  final String title;
  final Widget child;

  /// False for cards whose children draw their own full-width rows, so a
  /// divider or a tap highlight reaches the card edge.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, padded ? 10 : 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Padding(
            padding: padded
                ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
                : const EdgeInsets.only(bottom: 6),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// One contact detail: an icon tile, the label above the value, and a chevron
/// to say the whole row is the tap target.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // container + excludeSemantics so the row is one node to a screen
      // reader — "Phone Number 9876543210, button" — rather than an unlabelled
      // tap target next to two loose strings.
      container: true,
      excludeSemantics: true,
      label: '$label $value',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusField),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kSurfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Icon(icon, size: 18, color: myColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: kTextMuted,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      // A long URL or address truncates instead of wrapping
                      // the row onto three lines.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
                          color: kTextPrimary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_outward_rounded,
                  size: 16, color: kTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}
