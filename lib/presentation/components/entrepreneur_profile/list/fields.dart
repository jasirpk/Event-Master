import 'dart:developer' as developer;
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneur_detail.dart';
import 'package:event_master/presentation/pages/dashboard/vendor_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
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
    return FutureBuilder<double?>(
      future: UserProfile().fetchRating(documentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerAllSubcategories(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          );
        }

        // A rating is one line on this card, not the reason it exists.
        // Returning an error widget here replaced the whole entrepreneur —
        // name, photo, the tap target into their listings — because one
        // secondary read failed. The card is now built either way and the
        // rating line degrades on its own.
        if (snapshot.hasError) {
          developer.log(
            'Rating unavailable for entrepreneur $documentId: '
            '${snapshot.error.runtimeType}',
            name: 'EntrepreneurCard',
          );
        }

        // null means "no rating to show": either none has been given yet, or
        // the read failed. Neither is the same as a rating of zero, so the
        // card says so rather than inventing one.
        final double? rating = snapshot.hasError ? null : snapshot.data;

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
                      // profileImage is an R2 object key since the profile
                      // migration. startsWith('http') sent it to Image.asset,
                      // which asked Flutter for a bundled asset named
                      // "profile_images/..." and threw. MediaImage signs the
                      // key and falls back to the placeholder instead.
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MediaImage(
                          imagePath: imagePath,
                          placeholder: AssetImage(Assigns.placeHolderImage),
                          builder: (context, image) => Image(
                            image: image ??
                                AssetImage(Assigns.placeHolderImage)
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
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
                              // A long company name would otherwise push the
                              // column past its share of the row.
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                                  rating?.toStringAsFixed(1) ?? '—',
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
                                // Expanded is what makes the ellipsis work.
                                // Inside a Row an unconstrained Text takes its
                                // full intrinsic width, so maxLines and
                                // overflow had nothing to clip against and the
                                // row ran past its bounds — the "RIGHT
                                // OVERFLOWED BY 6.8 PIXELS" banner. Giving the
                                // text the leftover width lets it truncate.
                                Expanded(
                                  child: Text(
                                    vendorDetail['location'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: screenHeight * 0.014),
                                  ),
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
