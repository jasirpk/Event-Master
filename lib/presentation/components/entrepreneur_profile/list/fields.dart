import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
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
    this.subImagePath,
    this.subCategoryName,
    this.subdescripion,
  });

  final String documentId;
  final double screenWidth;
  final double screenHeight;
  final String imagePath;
  final Map<String, dynamic> userDetail;
  final Map<String, dynamic> vendorDetail;
  final String? subImagePath;
  final String? subCategoryName;
  final String? subdescripion;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: UserProfile().fetchRating(documentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerAllSubcategories(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          );
        }
        if (snapshot.hasError) {
          return Text('Error loading rating');
        }

        double rating = snapshot.data ?? 0.0;

        return InkWell(
          onTap: () {
            Get.to(() => VendorListScreen(
                  uid: documentId,
                  subImagePath: subImagePath,
                  subCategoryName: subCategoryName,
                  subdescripion: subdescripion,
                ));
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
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.30,
                      height: screenHeight * 0.16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imagePath.startsWith('http')
                            ? FadeInImage.assetNetwork(
                                placeholder: Assigns.placeHolderImage,
                                image: imagePath,
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                    Assigns.placeHolderImage,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
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
                              maxLines: 2,
                              style: TextStyle(fontSize: screenHeight * 0.018),
                            ),
                            SizedBox(height: 4.0),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                Text(
                                  rating
                                      .toStringAsFixed(1), // Display the rating
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.018,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
                                  style:
                                      TextStyle(fontSize: screenHeight * 0.014),
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
                          iconColor: Colors.white,
                          color: Colors.white,
                          onSelected: (value) async {
                            if (value == 'View Detail') {
                              Get.to(() => EntrepreneurDetailScreen(
                                    uid: documentId,
                                    companyName: userDetail['companyName'],
                                    about: userDetail['description'],
                                    phoneNumber: userDetail['phoneNumber'],
                                    bussinessEmail: userDetail['emailAddress'],
                                    website: userDetail['website'],
                                    imagePath: imagePath,
                                    links: List<Map<String, dynamic>>.from(
                                        userDetail['links']),
                                    images: List<Map<String, dynamic>>.from(
                                        userDetail['images']),
                                  ));
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
                            Get.to(() => VendorListScreen(
                                  uid: documentId,
                                ));
                          },
                          icon: Icon(CupertinoIcons.forward),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
