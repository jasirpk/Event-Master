import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/list/list_stream.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/all_templates.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntrepreneursListScreen extends StatefulWidget {
  const EntrepreneursListScreen({super.key});

  @override
  _EntrepreneursListScreenState createState() =>
      _EntrepreneursListScreenState();
}

class _EntrepreneursListScreenState extends State<EntrepreneursListScreen> {
  final UserProfile userProfile = UserProfile();
  final VendorRequest vendorRequest = VendorRequest();
  final TextEditingController _searchController = TextEditingController();
  String searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Entrepreneurs',
        actions: [
          IconButton(
            icon: Icon(Icons.source),
            onPressed: () {
              Get.to(() => AllTemplatesScreen());
            },
          ),
          sizedBoxWidth,
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Assigns.selectOne,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: screenHeight * 0.03,
                letterSpacing: 1,
              ),
            ),
            Text(
              Assigns.selecteDetail,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        searchTerm = '';
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchTerm = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListOfStreamWidget(
                userProfile: userProfile,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                vendorRequest: vendorRequest,
                searchTerm: searchTerm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
