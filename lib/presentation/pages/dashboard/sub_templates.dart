import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/favorites.dart';
import 'package:event_master/data_layer/services/subcategory.dart';
import 'package:event_master/presentation/components/search/sub_list.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneurs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubEventTemplatesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SubEventTemplatesScreen(
      {super.key, required this.categoryId, required this.categoryName});
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('User not logged in'));
    }
    final subDatabaseMethods subdatabaseMethods = subDatabaseMethods();
    final FavoritesMethods favoritesMethods = FavoritesMethods();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: categoryName,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  useRootNavigator: true,
                  delegate: DataSearch(categoryId: categoryId));
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              color: Colors.blue,
              height: 27,
              width: 27,
            ),
          ),
          sizedBoxWidth
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: subdatabaseMethods.getSubcategories(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerAllSubcategories(
                screenHeight: screenHeight, screenWidth: screenWidth);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Templates Found for $categoryId',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var documents = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              var data = document.data() as Map<String, dynamic>;
              String subimagePath = data['imagePath'];
              String subCategoryId = document.id;
              return FutureBuilder<DocumentSnapshot>(
                future: subdatabaseMethods.getSubCategoryId(
                    categoryId, subCategoryId),
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
                        'Details not found for $subCategoryId',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  var subDetailData =
                      subdetailSnapshot.data!.data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () {
                      Get.to(() => EntrepreneursListScreen());
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                            height: screenHeight * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: subimagePath.startsWith('http')
                                    ? NetworkImage(subimagePath)
                                    : AssetImage(subimagePath) as ImageProvider,
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
                                    subDetailData['subCategoryName'] ??
                                        'No Name',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    subDetailData['about'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StreamBuilder<DocumentSnapshot?>(
                                  stream: favoritesMethods.getFavoritesStatus(
                                      user.uid, subCategoryId),
                                  builder: (context, snapshot) {
                                    bool isFavorite =
                                        snapshot.data?.exists ?? false;
                                    return IconButton(
                                      onPressed: () {
                                        if (isFavorite) {
                                          favoritesMethods.removeFavorite(
                                              user.uid, subCategoryId);
                                        } else {
                                          favoritesMethods.addFavorite(user.uid,
                                              categoryId, subCategoryId, {
                                            'categoryId': categoryId,
                                            'subCategoryId': subCategoryId,
                                            'subCategoryName': subDetailData[
                                                'subCategoryName'],
                                            'imagePath': subimagePath,
                                            'about': subDetailData['about'],
                                          });
                                        }
                                      },
                                      icon: Icon(isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite),
                                      color: isFavorite ? myColor : Colors.grey,
                                    );
                                  }),
                              IconButton(
                                onPressed: () {
                                  Get.to(() => EntrepreneursListScreen());
                                },
                                icon: Icon(CupertinoIcons.forward),
                                color: Colors.white,
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
  }
}
