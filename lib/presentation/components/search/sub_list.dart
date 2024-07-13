import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/subcategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  final subDatabaseMethods databaseMethods = subDatabaseMethods();
  final String categoryId;

  DataSearch(
      {super.searchFieldLabel,
      super.searchFieldStyle,
      super.searchFieldDecorationTheme,
      super.keyboardType,
      super.textInputAction,
      required this.categoryId});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        CupertinoIcons.back,
        color: Colors.black,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.searchSubcategories(categoryId, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No results found for "$query"',
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
            String imagePath = data['imagePath'];
            return Card(
              color: Colors.black,
              child: Container(
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: imagePath.startsWith('http')
                                ? NetworkImage(imagePath)
                                : AssetImage(imagePath) as ImageProvider,
                            fit: BoxFit.cover)),
                  ),
                  title: Text(
                    data['subCategoryName'],
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['about'],
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AddVendorsScreen(
                    //       categoryName: data['subCategoryName'],
                    //       categoryDescription: data['about'],
                    //       imagePath: data['imagePath'],
                    //     ),
                    //   ),
                    // );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text(
        'Searching...',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
