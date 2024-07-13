import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneur_detail.dart';
import 'package:event_master/presentation/pages/dashboard/vendor_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FieldsWidget extends StatelessWidget {
  const FieldsWidget({
    super.key,
    required this.documentId,
    required this.screenWidth,
    required this.screenHeight,
    required this.imagePath,
    required this.userDetail,
    required this.vendorDetail,
  });

  final String documentId;
  final double screenWidth;
  final double screenHeight;
  final String imagePath;
  final Map<String, dynamic> userDetail;
  final Map<String, dynamic> vendorDetail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => VendorListScreen(uid: documentId));
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.30,
                  height: screenHeight * 0.20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imagePath.startsWith('http')
                          ? NetworkImage(imagePath)
                          : AssetImage(imagePath) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userDetail['companyName'],
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          userDetail['description'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          style: TextStyle(fontSize: screenHeight * 0.018),
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: myColor,
                              size: 20,
                            ),
                            Text(
                              vendorDetail['location'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: screenHeight * 0.014),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 'View Detail') {
                          Get.to(() => EntrepreneurDetailScreen(
                              companyName: userDetail['companyName'],
                              about: userDetail['description'],
                              phoneNumber: userDetail['phoneNumber'],
                              bussinessEmail: userDetail['emailAddress'],
                              website: userDetail['website'],
                              imagePath: imagePath,
                              links: List<Map<String, dynamic>>.from(
                                  userDetail['links']),
                              images: List<Map<String, dynamic>>.from(
                                  userDetail['images'])));
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text('View Detail'),
                            value: 'View Detail',
                          ),
                        ];
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        Get.to(() => VendorListScreen(uid: documentId));
                      },
                      icon: Icon(CupertinoIcons.forward),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}