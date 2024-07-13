import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/category.dart';
import 'package:event_master/presentation/components/search/search_results.dart';
import 'package:event_master/presentation/components/search/serch_empty_list.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot>? searchResults;
  String categoryId = '';
  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseMethods databaseMethods = DatabaseMethods();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: screenWidth * double.infinity,
            height: screenHeight * (250 / screenHeight),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/cover_img_1.png'),
                    fit: BoxFit.cover)),
            child: Padding(
              padding: EdgeInsets.only(top: 90, right: 40, left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: 'Search\n',
                            style: TextStyle(
                                fontSize: screenHeight * 0.030,
                                fontFamily: 'JacquesFracois')),
                        TextSpan(
                            text: 'for events',
                            style: TextStyle(
                                fontSize: screenHeight * 0.028,
                                fontFamily: 'JacquesFracois'))
                      ])),
                    ],
                  ),
                  sizedbox,
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Search',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                          floatingLabelBehavior: FloatingLabelBehavior.never),
                      onFieldSubmitted: (_) {
                        initiateSearch();
                      },
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  Assigns.popular,
                  style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          searchController.text.isNotEmpty
              ? SearchResultsWidget(
                  searchResults: searchResults,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  databaseMethods: databaseMethods)
              : SearchEmptyListWidget(
                  databaseMethods: databaseMethods,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth)
        ],
      ),
    );
  }

  void initiateSearch() {
    setState(() {
      searchResults = DatabaseMethods()
          .searchcategories(categoryId, searchController.text.trim());
    });
  }
}
