import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/list/fields.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:flutter/material.dart';

class EmptyEntrepreneurListWidget extends StatelessWidget {
  const EmptyEntrepreneurListWidget({
    super.key,
    required this.userProfile,
    required this.screenHeight,
    required this.screenWidth,
    required this.vendorRequest,
  });

  final UserProfile userProfile;
  final double screenHeight;
  final double screenWidth;
  final VendorRequest vendorRequest;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var document = documents[index];
            var data = document.data() as Map<String, dynamic>;
            String? imagePath = data['profileImage'] ?? '';
            String documentId = documents[index].id;

            return FutureBuilder<DocumentSnapshot>(
              future: userProfile.getUserDetailById(documentId),
              builder: (context, detailSnapshot) {
                if (detailSnapshot.connectionState == ConnectionState.waiting) {
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
                var userDetail =
                    detailSnapshot.data!.data() as Map<String, dynamic>;
                return StreamBuilder<QuerySnapshot>(
                  stream: vendorRequest.getAcceptedVendorList(documentId),
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
                    var vendorDetail = vendorSnapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                    return FieldsWidget(
                        documentId: documentId,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        imagePath: imagePath!,
                        userDetail: userDetail,
                        vendorDetail: vendorDetail);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
