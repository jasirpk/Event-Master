import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/vendro_fields.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:event_master/presentation/pages/dashboard/all_templates.dart';
import 'package:event_master/presentation/pages/dashboard/create_event.dart';
import 'package:event_master/presentation/pages/dashboard/vendor_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class VendorListScreen extends StatefulWidget {
  final String uid;
  final String? subImagePath;
  final String? subCategoryName;
  final String? subdescripion;

  const VendorListScreen({
    super.key,
    required this.uid,
    this.subImagePath,
    this.subCategoryName,
    this.subdescripion,
  });

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  @override
  void initState() {
    super.initState();
    // Clear the selected vendor list when entering the screen
    context.read<DashboardBloc>().add(ClearSelectedVendors());
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> budget = {};
    final VendorRequest vendorRequest = VendorRequest();
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
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
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
                    padding: EdgeInsets.only(bottom: 80),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      var data =
                          documents[index].data() as Map<String, dynamic>;
                      String imagePath = data['imagePathUrl'];
                      String documentId = documents[index].id;

                      return FutureBuilder<DocumentSnapshot?>(
                          future: vendorRequest.getCategoryDetailById(
                              widget.uid, documentId),
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
                            if (!detailSnapshot.hasData ||
                                detailSnapshot.data == null) {
                              return Center(child: Text('Details not found'));
                            }

                            var vendorDetail = detailSnapshot.data!.data()
                                as Map<String, dynamic>;
                            budget = vendorDetail['budget'];
                            vendorDetail['uid'] = documentId;

                            return InkWell(
                                onTap: () {
                                  Get.to(() => ReadVendorScreen(
                                        vendorName:
                                            vendorDetail['categoryName'],
                                        vendorImage: imagePath,
                                        location: vendorDetail['location'],
                                        description:
                                            vendorDetail['description'],
                                        images: List<Map<String, dynamic>>.from(
                                            vendorDetail['images']),
                                        budget: Map<String, double>.from(
                                            vendorDetail['budget']),
                                      ));
                                },
                                child: VendorFieldsWidget(
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                    imagePath: imagePath,
                                    vendorDetail: vendorDetail,
                                    budget: budget,
                                    documentId: documentId));
                          });
                    });
              }),
          Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: PushableButton_Widget(
                  buttonText: 'Next',
                  onpressed: () {
                    final state = context.read<DashboardBloc>().state;
                    if (state is VendorSelectionState) {
                      final selectedVendors = state.selectedVendors;
                      if (selectedVendors.isEmpty) {
                        showCustomSnackBar('Error', 'Please Select Vendors!!');
                      } else {
                        Get.to(() => SubmitDetailsScreen(
                              EntrepreneurId: widget.uid,
                              selectedVendors: selectedVendors,
                              subImagePath: widget.subImagePath,
                              subCategoryName: widget.subCategoryName,
                              subdescripion: widget.subdescripion,
                            ));
                      }
                    }
                  }))
        ],
      ),
    );
  }
}
