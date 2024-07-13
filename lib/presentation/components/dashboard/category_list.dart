import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/category.dart';
import 'package:event_master/data_layer/services/subcategory.dart';
import 'package:event_master/presentation/components/dashboard/subcategory.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_templates.dart';
import 'package:event_master/presentation/components/ui/custom_text.dart';
import 'package:event_master/presentation/pages/dashboard/sub_templates.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final DatabaseMethods databaseMethods = DatabaseMethods();
    final subDatabaseMethods subdatabaseMethods = subDatabaseMethods();
    String selectedCategory = 'Client';
    return SliverToBoxAdapter(
      child: StreamBuilder<QuerySnapshot>(
        stream: databaseMethods.geCategoryDetail(selectedCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerAllTemplates(
                screenHeight: screenHeight, screenWidth: screenWidth);
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
            physics: NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              String documentId = documents[index].id;
              return FutureBuilder<DocumentSnapshot>(
                future: databaseMethods.getCategoryDetailById(documentId),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerAllTemplates(
                        screenHeight: screenHeight, screenWidth: screenWidth);
                  }
                  if (detailSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${detailSnapshot.error}'),
                    );
                  }
                  if (!detailSnapshot.hasData || detailSnapshot.data == null) {
                    return Center(child: Text('Details not found'));
                  }
                  var detailData =
                      detailSnapshot.data!.data() as Map<String, dynamic>;
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: Container(
                        height: screenHeight * 0.32,
                        width: screenWidth * 0.90,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          detailData['categoryName'],
                                          style: TextStyle(
                                            letterSpacing: 1,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CustomText(
                                          screenHeight: screenHeight,
                                          onpressed: () {
                                            Get.to(
                                              () => SubEventTemplatesScreen(
                                                categoryId: documentId,
                                                categoryName:
                                                    detailData['categoryName'],
                                              ),
                                            );
                                          },
                                          text: 'View All',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SubCategoryList(
                                      subdatabaseMethods: subdatabaseMethods,
                                      documentId: documentId,
                                      screenHeight: screenHeight,
                                      screenWidth: screenWidth),
                                ],
                              ),
                            ],
                          ),
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
