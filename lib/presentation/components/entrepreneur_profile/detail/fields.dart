import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/linkds.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/medaia.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/rich_text.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  final double screenHeight;
  final String about;
  final String phoneNumber;
  final String bussinessEmail;
  final String website;
  final List<Map<String, dynamic>> links;
  final List<Map<String, dynamic>> images;

  /// Returns true when the rating was actually persisted by the backend.
  final Future<bool> Function(double) onRatingSubmit;

  /// Loads this user's existing rating, or null if they have not rated.
  final Future<double?> Function() onLoadUserRating;

  /// Removes this user's rating. Returns true when the backend confirmed it.
  final Future<bool> Function() onRatingRemove;

  @override
  _DetailFieldsWidgetState createState() => _DetailFieldsWidgetState();
}

class _DetailFieldsWidgetState extends State<DetailFieldsWidget> {
  // null means "this consumer has not rated yet" — no rating is ever
  // fabricated for display. Loaded once from the user's own rating document.
  double? _userRating;

  // Distinguishes "still loading" from "not rated", so the screen does not
  // claim the user has no rating before the answer has arrived.
  bool _loadingUserRating = true;

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
    });

    final removed = await widget.onRatingRemove();

    if (!removed && mounted) {
      setState(() {
        _userRating = previous;
      });
    }
  }

  void _showRatingDialog(BuildContext context, double initialRating) {
    showDialog(
      context: context,
      builder: (context) {
        double _dialogRating = initialRating;
        return AlertDialog(
          title: Text('Rate ${widget.companyName}'),
          content: RatingBar.builder(
            initialRating: initialRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            unratedColor: Colors.grey,
            onRatingUpdate: (rating) {
              _dialogRating = rating;
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
                child: Text(
                  'Remove rating',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final previous = _userRating;

                // Show the new rating immediately, then roll back if the
                // backend rejected it — leaving a star lit for a write that
                // never persisted would misreport the outcome.
                setState(() {
                  _userRating = _dialogRating;
                });
                Navigator.of(context).pop();

                final persisted = await widget.onRatingSubmit(_dialogRating);

                if (!persisted && mounted) {
                  setState(() {
                    _userRating = previous;
                  });
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  maxRadius: 60,
                  backgroundColor: myColor,
                  backgroundImage: widget.imagePath.startsWith('http')
                      ? NetworkImage(widget.imagePath)
                      : AssetImage(widget.imagePath) as ImageProvider,
                ),
                sizedBoxWidth,
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.companyName,
                        style: TextStyle(
                            fontSize: widget.screenHeight * 0.026,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1),
                      ),
                      SizedBox(height: 10),
                      RatingBar.builder(
                        initialRating: _userRating ?? 0,
                        minRating: 1,
                        itemSize: 20,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        unratedColor: Colors.white38,
                        onRatingUpdate: (rating) {
                          _showRatingDialog(context, rating);
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        _loadingUserRating
                            ? 'Rating: …'
                            : _userRating == null
                                ? 'Rating: Not rated yet'
                                : 'Rating: $_userRating',
                        style: TextStyle(
                            fontSize: widget.screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            sizedbox,
            Text(
              Assigns.aboutUs,
              style: TextStyle(
                  fontSize: widget.screenHeight * 0.022,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.about,
              style: TextStyle(
                  fontSize: widget.screenHeight * 0.018,
                  fontWeight: FontWeight.w300),
            ),
            sizedbox,
            Text(
              Assigns.moreDetail,
              style: TextStyle(
                  fontSize: widget.screenHeight * 0.022,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              Assigns.phoneNumber,
              style: TextStyle(
                  fontSize: widget.screenHeight * 0.020,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 10),
            Text(
              widget.phoneNumber,
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: widget.screenHeight * 0.018,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 10),
            RichTextEmailWidget(widget: widget),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: Assigns.website,
                      style: TextStyle(
                          fontSize: widget.screenHeight * 0.022,
                          fontWeight: FontWeight.w500)),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: widget.website,
                    style: TextStyle(
                        fontSize: widget.screenHeight * 0.018,
                        fontWeight: FontWeight.w300,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              Assigns.otherLinks,
              style: TextStyle(
                  fontSize: widget.screenHeight * 0.020,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 10),
            LinksWidget(widget: widget),
            sizedbox,
            Text(
              Assigns.media,
              style: TextStyle(
                  fontSize: widget.screenHeight * 0.022,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            MediaWidget(widget: widget),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: PushableButton_Widget(
            buttonText: 'Book Now',
            onpressed: () {},
          ),
        ),
      ],
    );
  }
}
