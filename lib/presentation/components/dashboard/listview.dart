import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/category.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_home_list.dart';
import 'package:event_master/presentation/pages/dashboard/sub_templates.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListViewWidget extends StatelessWidget {
  ListViewWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  final double screenHeight;
  final double screenWidth;
  final DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    String selectedCategory = 'Client';
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.geCategoryDetail(selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Stream error: ${snapshot.error}');
          return ShimmerHomeList(
              screenHeight: screenHeight, screenWidth: screenWidth);
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No data available or no documents found');
          return Center(
            child: Text('No Templates Found'),
          );
        }
        var documents = snapshot.data!.docs;
        documents.forEach((doc) {
          print('Document: ${doc.data()}');
        });
        return SizedBox(
          height: screenHeight * 0.24,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;
              String imagePath =
                  data['imagePath'] ?? 'assets/images/venue_decoration_img.jpg';
              String documentId = documents[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: databaseMethods.getCategoryDetailById(documentId),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerHomeList(
                        screenHeight: screenHeight, screenWidth: screenWidth);
                  }
                  if (detailSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${detailSnapshot.error}'),
                    );
                  }
                  if (!detailSnapshot.hasData) {
                    return Center(
                      child: Text('Details Not Found'),
                    );
                  }
                  var detailData =
                      detailSnapshot.data!.data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () {
                      Get.to(() => SubEventTemplatesScreen(
                          categoryId: documentId,
                          categoryName: detailData['categoryName']));
                    },
                    child: InkWell(
                      onTap: () {
                        Get.to(() => SubEventTemplatesScreen(
                            categoryId: documentId,
                            categoryName: detailData['categoryName']));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: screenWidth * 0.50,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: myColor, width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: imagePath.startsWith('http')
                                    ? NetworkImage(imagePath)
                                    : AssetImage(imagePath) as ImageProvider,
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.2),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    detailData['categoryName'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
