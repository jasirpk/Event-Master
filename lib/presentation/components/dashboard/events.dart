import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/bussiness_layer.dart/show_diolog.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/create_event.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneurs.dart';
import 'package:event_master/presentation/pages/dashboard/event_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text("User not logged in"),
      );
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    EventBookingMethods eventBookingMethods = EventBookingMethods();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => EntrepreneursListScreen());
          },
          label: Text(
            '+Add Events',
          )),
      appBar: CustomAppBarWithDivider(title: 'Events'),
      body: StreamBuilder<QuerySnapshot?>(
        stream: eventBookingMethods.getGeneratedEventsDetails(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerAllSubcategories(
                screenHeight: screenHeight, screenWidth: screenWidth);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Templates Found for ',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var documents = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var document = documents[index];
                var data = document.data() as Map<String, dynamic>;
                String imagePath = data['imageURL'];
                String documentId = document.id;

                return FutureBuilder<DocumentSnapshot?>(
                  future:
                      eventBookingMethods.getEventsById(user.uid, documentId),
                  builder: (context, subdetailSnapshot) {
                    if (subdetailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ShimmerAllSubcategories(
                          screenHeight: screenHeight, screenWidth: screenWidth);
                    }

                    if (!subdetailSnapshot.hasData ||
                        subdetailSnapshot.data == null ||
                        subdetailSnapshot.data!.data() == null) {
                      return Center(
                        child: Text(
                          'Details not found ',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    var subDetailData =
                        subdetailSnapshot.data!.data() as Map<String, dynamic>;

                    // bool isSubmit = subDetailData['isValid'] ?? false;

                    return InkWell(
                      onTap: () {
                        Get.to(() => EventDetailScreen(
                            clientName: subDetailData['clientName'],
                            clientEmail: subDetailData['email'],
                            phoneNumber: subDetailData['phoneNumber'],
                            location: subDetailData['location'],
                            eventType: subDetailData['eventype'],
                            description: subDetailData['eventAbout'],
                            imagePath: imagePath,
                            guests: subDetailData['guestCount'],
                            amount: subDetailData['sum'],
                            date: subDetailData['date'],
                            time: subDetailData['time'],
                            selectedVendors: List<Map<String, dynamic>>.from(
                                subDetailData['selectedVendors'])));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5), width: 0.5),
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
                                  children: [
                                    Text(
                                      subDetailData['eventype'] ?? 'No Name',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.white54,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          subDetailData['date'] ?? '',
                                          style: TextStyle(
                                              fontSize: 14.0, letterSpacing: 2),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.alarm,
                                          color: Colors.white54,
                                          size: 20,
                                        ),
                                        sizedBoxWidth,
                                        Text(
                                          subDetailData['time'] ?? '',
                                          style: TextStyle(
                                              letterSpacing: 2,
                                              fontSize: screenHeight * 0.014,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    // isSubmit
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: myColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Text(
                                        'submited',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: screenHeight * 0.010),
                                      ),
                                    )
                                    //     : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PopupMenuButton(
                                  color: Colors.white,
                                  iconColor: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'View Detail') {
                                      Get.to(() => EventDetailScreen(
                                          clientName:
                                              subDetailData['clientName'],
                                          clientEmail: subDetailData['email'],
                                          phoneNumber:
                                              subDetailData['phoneNumber'],
                                          location: subDetailData['location'],
                                          eventType: subDetailData['eventype'],
                                          description:
                                              subDetailData['eventAbout'],
                                          imagePath: imagePath,
                                          guests: subDetailData['guestCount'],
                                          amount: subDetailData['sum'],
                                          date: subDetailData['date'],
                                          time: subDetailData['time'],
                                          selectedVendors:
                                              List<Map<String, dynamic>>.from(
                                                  subDetailData[
                                                      'selectedVendors'])));
                                    } else if (value == 'delete') {
                                      showDeleteConfirmationDialog(
                                        uid: user.uid,
                                        documentId: documentId,
                                        eventMethods: eventBookingMethods,
                                      );
                                    } else if (value == 'update') {
                                      // Get.to(() => EditVendorScreen(
                                      //     vendorId: documentId,
                                      //     vendorName:
                                      //         subDetailData['categoryName'],
                                      //     vendorImage: imagePath,
                                      //     location: subDetailData['location'],
                                      //     description:
                                      //         subDetailData['description'],
                                      //     images:
                                      //         List<Map<String, dynamic>>.from(
                                      //             subDetailData['images']),
                                      //     budget: Map<String, double>.from(
                                      //         subDetailData['budget'])));
                                    } else if (value == 'submit') {
                                      // await generatedVendor.updateIsValidField(
                                      //     uid, documentId,
                                      //     isSumbit: true);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: Text('Delete'),
                                        value: 'delete',
                                      ),
                                      PopupMenuItem(
                                        child: Text('View Detail'),
                                        value: 'View Detail',
                                      ),
                                      PopupMenuItem(
                                        child: Text('Update'),
                                        value: 'update',
                                      ),
                                      PopupMenuItem(
                                        child: Text(
                                          'Submit',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: myCustomColor,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        value: 'submit',
                                      ),
                                    ];
                                  },
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
            ),
          );
        },
      ),
    );
  }
}