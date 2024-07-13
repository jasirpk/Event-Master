import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/all_templates.dart';
import 'package:event_master/presentation/pages/dashboard/vendor_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorListScreen extends StatefulWidget {
  final String uid;

  const VendorListScreen({super.key, required this.uid});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  @override
  Widget build(BuildContext context) {
    final VendorRequest vendorRequest = VendorRequest();
    Map<String, bool> selectedVendors = {};
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Available Vendors',
        actions: [
          IconButton(
            icon: Icon(
              Icons.source,
              color: Colors.white,
            ),
            onPressed: () {
              Get.to(() => AllTemplatesScreen());
            },
          ),
          sizedBoxWidth,
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: vendorRequest.getAcceptedVendorList(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerSubCategoryItem(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Templates Found'),
            );
          }

          final documents = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;
              String imagePath = data['imagePathUrl'];
              String documentId = documents[index].id;

              return FutureBuilder<DocumentSnapshot?>(
                future:
                    vendorRequest.getCategoryDetailById(widget.uid, documentId),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerSubCategoryItem(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                    );
                  }
                  if (detailSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${detailSnapshot.error}'),
                    );
                  }
                  if (!detailSnapshot.hasData || detailSnapshot.data == null) {
                    return Center(child: Text('Details not found'));
                  }

                  var vendorDetail =
                      detailSnapshot.data!.data() as Map<String, dynamic>;
                  Map<String, dynamic> budget = vendorDetail['budget'];

                  return InkWell(
                    onTap: () {
                      Get.to(() => ReadVendorScreen(
                          vendorName: vendorDetail['categoryName'],
                          vendorImage: imagePath,
                          location: vendorDetail['location'],
                          description: vendorDetail['description'],
                          images: List<Map<String, dynamic>>.from(
                              vendorDetail['images']),
                          budget: Map<String, double>.from(
                              vendorDetail['budget'])));
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.26,
                              height: screenHeight * 0.10,
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
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
                                      style: TextStyle(
                                          fontSize: 12.0, color: myColor),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                          vendorName:
                                              vendorDetail['categoryName'],
                                          vendorImage: imagePath,
                                          location: vendorDetail['location'],
                                          description:
                                              vendorDetail['description'],
                                          images:
                                              List<Map<String, dynamic>>.from(
                                                  vendorDetail['images']),
                                          budget: Map<String, double>.from(
                                              vendorDetail['budget'])));
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
                                Checkbox(
                                    value: selectedVendors[documentId] ?? false,
                                    onChanged: (bool? value) {})
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
