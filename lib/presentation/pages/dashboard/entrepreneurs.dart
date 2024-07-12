import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/vendor_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntrepreneursListScreen extends StatelessWidget {
  const EntrepreneursListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfile userProfile = UserProfile();
    final VendorRequest vendorRequest = VendorRequest();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Entrepreneurs',
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.source),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Assigns.selectOne,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: screenHeight * 0.03,
                letterSpacing: 1,
              ),
            ),
            Text(
              Assigns.selecteDetail,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 10.0),
            StreamBuilder<QuerySnapshot>(
              stream: userProfile.getUserProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerAllSubcategories(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No Templates Found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                var documents = snapshot.data!.docs;
                return Expanded(
                  child: ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      var document = documents[index];
                      var data = document.data() as Map<String, dynamic>;
                      String imagePath = data['profileImage'];
                      String documentId = documents[index].id;

                      return FutureBuilder<DocumentSnapshot>(
                        future: userProfile.getUserDetailById(documentId),
                        builder: (context, detailSnapshot) {
                          if (detailSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ShimmerAllSubcategories(
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
                            );
                          }

                          if (!detailSnapshot.hasData ||
                              detailSnapshot.data == null ||
                              detailSnapshot.data!.data() == null) {
                            return Center(
                              child: Text(
                                'Details not found',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          var userDetail = detailSnapshot.data!.data()
                              as Map<String, dynamic>;
                          return StreamBuilder<QuerySnapshot>(
                            stream:
                                vendorRequest.getAcceptedVendorList(documentId),
                            builder: (context, vendorSnapshot) {
                              if (vendorSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ShimmerAllSubcategories(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                );
                              }
                              if (vendorSnapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error: ${vendorSnapshot.error}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                              if (!vendorSnapshot.hasData ||
                                  vendorSnapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Vendor Details not found',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                              var vendorDetail = vendorSnapshot.data!.docs.first
                                  .data() as Map<String, dynamic>;
                              return InkWell(
                                onTap: () {
                                  Get.to(
                                      () => VendorListScreen(uid: documentId));
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.30,
                                        height: screenHeight * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: imagePath.startsWith('http')
                                                ? NetworkImage(imagePath)
                                                : AssetImage(imagePath)
                                                    as ImageProvider,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userDetail['companyName'],
                                                style: TextStyle(
                                                  fontSize:
                                                      screenHeight * 0.022,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                userDetail['description'],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 4,
                                                style: TextStyle(
                                                    fontSize:
                                                        screenHeight * 0.018),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: screenHeight *
                                                            0.014),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          PopupMenuButton(
                                            onSelected: (value) async {
                                              if (value == 'View Detail') {}
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
                                            onPressed: () {},
                                            icon: Icon(CupertinoIcons.forward),
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ],
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
