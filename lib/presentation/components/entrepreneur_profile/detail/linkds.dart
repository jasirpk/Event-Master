import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/models/entrepreneur_document.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/material.dart';

/// The entrepreneur's other links, one tappable row each.
///
/// Was a `ListView` inside a `Container(height: screenHeight * 0.1)` — a
/// ~95pt scroll area nested inside the page's own scroll view, so a profile
/// with three links hid the third behind a scroll gesture that fought the
/// page. The rows are a plain column now and the page scrolls as one.
class LinksWidget extends StatelessWidget {
  const LinksWidget({
    super.key,
    required this.widget,
    required this.onOpen,
  });

  final DetailFieldsWidget widget;

  /// Opens the link. Supplied by the parent so there is one launch path on
  /// this screen, shared with the contact rows.
  final Future<void> Function(Uri) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in widget.links)
          // An entry without a 'link' key threw the same failed cast the
          // screen as a whole used to.
          if (profileText(entry['link']).trim().isNotEmpty)
            _LinkRow(link: profileText(entry['link']).trim(), onOpen: onOpen),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link, required this.onOpen});

  final String link;
  final Future<void> Function(Uri) onOpen;

  @override
  Widget build(BuildContext context) {
    final hasScheme = link.startsWith('http://') || link.startsWith('https://');

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Open $link',
      button: true,
      child: InkWell(
        onTap: () => onOpen(Uri.parse(hasScheme ? link : 'https://$link')),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: [
              Icon(Icons.link_rounded, size: 17, color: myColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  link,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: kTextSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_outward_rounded,
                  size: 15, color: kTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}
