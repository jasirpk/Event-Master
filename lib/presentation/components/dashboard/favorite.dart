import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/favorites.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneurs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('User not logged in'));
    }

    final FavoritesMethods favoritesMethods = FavoritesMethods();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Favorites',
        actions: [],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoritesMethods.getFavorites(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerAllSubcategories(
                screenHeight: screenHeight, screenWidth: screenWidth);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Favorites Found',
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
              return InkWell(
                onTap: () {
                  Get.to(() => EntrepreneursListScreen());
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                                data['subCategoryName'] ?? 'No Name',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                data['about'],
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
                                          data['categoryId'], subCategoryId, {
                                        'categoryId': data['categoryId'],
                                        'subCategoryId': subCategoryId,
                                        'subCategoryName':
                                            data['subCategoryName'],
                                        'imagePath': subimagePath,
                                        'about': data['about'],
                                      });
                                    }
                                  },
                                  icon: Icon(isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border),
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
      ),
    );
  }
}
