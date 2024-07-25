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
  final Function(double) onRatingSubmit;

  @override
  _DetailFieldsWidgetState createState() => _DetailFieldsWidgetState();
}

class _DetailFieldsWidgetState extends State<DetailFieldsWidget> {
  double _userRating = 3.5;

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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userRating = _dialogRating;
                });
                widget.onRatingSubmit(_dialogRating);
                print('User Rating: $_dialogRating');
                Navigator.of(context).pop();
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
                        initialRating: _userRating,
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
                        'Rating: $_userRating',
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
