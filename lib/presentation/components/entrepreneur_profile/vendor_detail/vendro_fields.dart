import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/selected_vendor.dart';
import 'package:event_master/presentation/pages/dashboard/vendor_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorFieldsWidget extends StatelessWidget {
  const VendorFieldsWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.imagePath,
    required this.vendorDetail,
    required this.budget,
    required this.documentId,
  });

  final double screenWidth;
  final double screenHeight;
  final String imagePath;
  final Map<String, dynamic> vendorDetail;
  final Map<String, dynamic> budget;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
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
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vendorDetail['categoryName'],
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          '\$${budget['from']} - \$${budget['to']}',
                          style: TextStyle(fontSize: 12.0, color: myColor),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: myColor,
                              size: 10,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              vendorDetail['location'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenHeight * 0.010,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 'View Detail') {
                          Get.to(() => ReadVendorScreen(
                                vendorName: vendorDetail['categoryName'],
                                vendorImage: imagePath,
                                location: vendorDetail['location'],
                                description: vendorDetail['description'],
                                images: List<Map<String, dynamic>>.from(
                                    vendorDetail['images']),
                                budget: Map<String, double>.from(
                                    vendorDetail['budget']),
                              ));
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'View Detail',
                          child: Text('View Detail'),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                    SelectedVendorWidget(
                        documentId: documentId, vendorDetail: vendorDetail),
                  ],
                ),
              ],
            )));
  }
}
