import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/subcategory.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:flutter/material.dart';

class SubCategoryList extends StatelessWidget {
  const SubCategoryList({
    super.key,
    required this.subdatabaseMethods,
    required this.documentId,
    required this.screenHeight,
    required this.screenWidth,
  });

  final subDatabaseMethods subdatabaseMethods;
  final String documentId;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: subdatabaseMethods.getSubcategories(documentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerSubCategoryItem(
              screenHeight: screenHeight, screenWidth: screenWidth);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No Templates Found for $documentId',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var documents = snapshot.data!.docs;
        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              var data = document.data() as Map<String, dynamic>;
              String subimagePath = data['imagePath'];
              String subCategoryId = document.id;
              return FutureBuilder<DocumentSnapshot>(
                future: subdatabaseMethods.getSubCategoryId(
                    documentId, subCategoryId),
                builder: (context, subdetailSnapshot) {
                  if (subdetailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerSubCategoryItem(
                        screenHeight: screenHeight, screenWidth: screenWidth);
                  }

                  if (!subdetailSnapshot.hasData ||
                      subdetailSnapshot.data == null ||
                      subdetailSnapshot.data!.data() == null) {
                    return Center(
                      child: Text(
                        'Details not found for $subCategoryId',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  var subDetailData =
                      subdetailSnapshot.data!.data() as Map<String, dynamic>;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 18),
                    height: screenHeight * 0.12,
                    width: screenWidth * 0.46,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: subimagePath.startsWith('http')
                              ? NetworkImage(subimagePath)
                              : AssetImage(subimagePath) as ImageProvider,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3), BlendMode.color)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          height: screenHeight * 0.04,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                subDetailData['subCategoryName'] ?? 'No Name',
                                style: TextStyle(
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ),
                        )
                      ],
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
