import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/budget.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/component_widget.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/description.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/location.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/vendor_image.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/vendor_detail/vendor_name.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';

class ReadVendorScreen extends StatelessWidget {
  final String vendorName;
  final String vendorImage;
  final String location;
  final String description;
  final List<Map<String, dynamic>> images;
  final Map<String, double> budget;

  const ReadVendorScreen({
    super.key,
    required this.vendorName,
    required this.vendorImage,
    required this.location,
    required this.description,
    required this.images,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Vendor Details',
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
          sizedBoxWidth,
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VendorImageWidget(vendorImage: vendorImage),
              SizedBox(height: 10),
              VendorNameWidget(
                  screenWidth: screenWidth, vendorName: vendorName),
              sizedbox,
              Text(Assigns.component),
              SizedBox(height: 10),
              componentsWidget(images: images, screenWidth: screenWidth),
              sizedbox,
              Row(
                children: [
                  Text(
                    Assigns.location,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.038,
                    ),
                  ),
                  Icon(Icons.location_on, color: Colors.white),
                ],
              ),
              SizedBox(height: 10),
              LocationWidget(screenHeight: screenHeight, location: location),
              sizedbox,
              Text(Assigns.aboutUs),
              SizedBox(height: 10),
              DescriptionWidget(description: description),
              sizedbox,
              Text(
                Assigns.budget,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.038,
                ),
              ),
              SizedBox(height: 10),
              BudgetWidget(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  vendorImage: vendorImage,
                  budget: budget),
            ],
          ),
        ),
      ),
    );
  }
}
