import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/list/fields.dart';
import 'package:event_master/presentation/components/search/entrepreneur_empty.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:flutter/material.dart';

class ListOfStreamWidget extends StatelessWidget {
  const ListOfStreamWidget({
    super.key,
    required this.userProfile,
    required this.screenHeight,
    required this.screenWidth,
    required this.vendorRequest,
    required this.searchTerm,
    this.subImagePath,
    this.subCategoryName,
    this.subdescripion,
  });

  final UserProfile userProfile;
  final double screenHeight;
  final double screenWidth;
  final VendorRequest vendorRequest;
  final String searchTerm;
  final String? subImagePath;
  final String? subCategoryName;
  final String? subdescripion;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: userProfile.searchEntrepreneurs(searchTerm),
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
          return EmptyEntrepreneurListWidget(
            userProfile: userProfile,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            vendorRequest: vendorRequest,
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
                      return SizedBox();
                    }
                    var vendorDetail = vendorSnapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                    return FieldsWidget(
                      documentId: documentId,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      imagePath: imagePath!,
                      userDetail: userDetail,
                      vendorDetail: vendorDetail,
                      subImagePath: subImagePath,
                      subCategoryName: subCategoryName,
                      subdescripion: subdescripion,
                    );
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
