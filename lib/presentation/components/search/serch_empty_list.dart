import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/services/category.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:event_master/presentation/pages/dashboard/sub_templates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchEmptyListWidget extends StatelessWidget {
  const SearchEmptyListWidget({
    super.key,
    required this.databaseMethods,
    required this.screenHeight,
    required this.screenWidth,
  });

  final DatabaseMethods databaseMethods;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.geCategoryDetail(Assigns.selectedValue),
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

        return Container(
          height: screenHeight * 0.6,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              var data = document.data() as Map<String, dynamic>;
              String imagePath = data['imagePath'];
              String? documentId = document.id;

              return FutureBuilder<DocumentSnapshot?>(
                future: databaseMethods.getCategoryDetailById(documentId),
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
                        'Details not found for $documentId',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  var detailData =
                      subdetailSnapshot.data!.data() as Map<String, dynamic>;

                  return InkWell(
                    onTap: () {
                      Get.to(
                        () => SubEventTemplatesScreen(
                          categoryId: documentId,
                          categoryName: detailData['categoryName'],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detailData['categoryName'] ?? 'No Name',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      detailData['description'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40,
                                ),
                                IconButton(
                                  onPressed: () {
                                    Get.to(
                                      () => SubEventTemplatesScreen(
                                        categoryId: documentId,
                                        categoryName:
                                            detailData['categoryName'],
                                      ),
                                    );
                                  },
                                  icon: Icon(CupertinoIcons.forward),
                                  color: Colors.grey,
                                ),
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
          ),
        );
      },
    );
  }
}
