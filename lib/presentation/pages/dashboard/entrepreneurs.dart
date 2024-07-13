import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/list/list_stream.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';

class EntrepreneursListScreen extends StatelessWidget {
  const EntrepreneursListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfile userProfile = UserProfile();
    final VendorRequest vendorRequest = VendorRequest();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Entrepreneurs',
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.source),
            onPressed: () {},
          ),
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
            ListOfStreamWidget(
                userProfile: userProfile,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                vendorRequest: vendorRequest),
          ],
        ),
      ),
    );
  }
}
