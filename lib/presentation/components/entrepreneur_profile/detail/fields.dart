import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Detail_FieldsWidget extends StatelessWidget {
  const Detail_FieldsWidget({
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              maxRadius: 60,
              backgroundColor: myColor,
              backgroundImage: imagePath.startsWith('http')
                  ? NetworkImage(imagePath)
                  : AssetImage(imagePath) as ImageProvider,
            ),
            sizedBoxWidth,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: TextStyle(
                      fontSize: screenHeight * 0.026,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    SizedBox(width: 4),
                    Icon(Icons.star_half, color: Colors.yellow, size: 20),
                  ],
                ),
              ],
            ),
          ],
        ),
        sizedbox,
        Text(
          Assigns.aboutUs,
          style: TextStyle(
              fontSize: screenHeight * 0.022, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          about,
          style: TextStyle(
              fontSize: screenHeight * 0.018, fontWeight: FontWeight.w300),
        ),
        sizedbox,
        Text(
          Assigns.moreDetail,
          style: TextStyle(
              fontSize: screenHeight * 0.022, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Text(
          Assigns.phoneNumber,
          style: TextStyle(
              fontSize: screenHeight * 0.020, fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 10),
        Text(
          phoneNumber,
          style: TextStyle(
              color: Colors.blue,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: '@',
                  style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold)),
              TextSpan(text: ' '),
              TextSpan(
                text: bussinessEmail,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: screenHeight * 0.018,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: Assigns.website,
                  style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.w500)),
              TextSpan(text: ' '),
              TextSpan(
                text: website,
                style: TextStyle(
                    fontSize: screenHeight * 0.018,
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
              fontSize: screenHeight * 0.020, fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 10),
        Container(
            height: screenHeight * 0.1,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: links.length,
                itemBuilder: (context, index) {
                  var data = links[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.forward,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(data['link'],
                                style: TextStyle(
                                    fontSize: screenHeight * 0.018,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                })),
        sizedbox,
        Text(
          Assigns.media,
          style: TextStyle(
              fontSize: screenHeight * 0.022, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 130,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            var image = images[index];
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: image['image'].startsWith('http')
                      ? NetworkImage(image['image'])
                      : AssetImage(image['image']) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
