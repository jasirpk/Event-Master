import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/event/add_event/custom_headline.dart';
import 'package:event_master/presentation/components/event/detail/date_and_time.dart';
import 'package:event_master/presentation/components/event/detail/guest_and_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventDetailScreen extends StatelessWidget {
  final String clientName;
  final String clientEmail;
  final String phoneNumber;
  final String location;
  final String eventType;
  final String description;
  final String imagePath;
  final String guests;
  final String amount;
  final String date;
  final String time;
  final List<Map<String, dynamic>> selectedVendors;

  const EventDetailScreen(
      {super.key,
      required this.clientName,
      required this.clientEmail,
      required this.phoneNumber,
      required this.location,
      required this.eventType,
      required this.description,
      required this.imagePath,
      required this.guests,
      required this.amount,
      required this.date,
      required this.time,
      required this.selectedVendors});
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                Assigns.eventDetail,
                style: TextStyle(
                    color: Colors.white, fontSize: screenHeight * 0.018),
              ),
            )),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Card(
                  color: Colors.white12,
                  child: Container(
                    width: screenWidth * double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventType,
                            style: TextStyle(
                                fontSize: screenHeight * 0.026,
                                fontWeight: FontWeight.w500),
                          ),
                          sizedbox,
                          Text(
                            description,
                            maxLines: 4,
                          ),
                          sizedbox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DateAndTimeWidget(
                                TypeText: Assigns.date,
                                value: date,
                              ),
                              DateAndTimeWidget(
                                TypeText: Assigns.time,
                                value: time,
                              ),
                            ],
                          ),
                          sizedbox,
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 30,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  location,
                                  style: TextStyle(
                                      color: myColor, letterSpacing: 2),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              sizedbox,
              CircleAvatar(
                backgroundColor: Colors.white,
                maxRadius: 20,
                child: Icon(Icons.collections_bookmark),
              ),
              SizedBox(height: 10),
              Card(
                color: Colors.white12,
                child: Container(
                  height: screenHeight * 0.2,
                  width: screenWidth * double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imagePath.startsWith('http')
                          ? NetworkImage(imagePath)
                          : AssetImage(imagePath) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              sizedbox,
              CustomHeadLineTextWidget(
                  screenHeight: screenHeight, text: Assigns.guestAndTheme),
              sizedbox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GuestAndThemeWidget(
                    screenWidth: screenWidth,
                    headText: Assigns.guestCount,
                    value: guests,
                  ),
                  GuestAndThemeWidget(
                    screenWidth: screenWidth,
                    headText: Assigns.totalAmount,
                    value: '$amount ₹',
                  ),
                ],
              ),
              sizedbox,
              CustomHeadLineTextWidget(
                  screenHeight: screenHeight, text: Assigns.selectedVendors),
              SizedBox(height: 10),
              SizedBox(
                height: screenHeight * 0.2,
                child: ListView.builder(
                  itemCount: selectedVendors.length,
                  itemBuilder: (context, index) {
                    var vendor = selectedVendors[index];

                    return Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Container(
                        height: screenHeight * 0.062,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white30,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    maxRadius: 20,
                                    backgroundColor: myColor,
                                    backgroundImage: vendor['imagePathUrl']
                                            .startsWith('http')
                                        ? NetworkImage(vendor['imagePathUrl'])
                                        : AssetImage(vendor['imagePathUrl'])
                                            as ImageProvider,
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: screenWidth * 0.3),
                                    child: Text(
                                      vendor['categoryName'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Text(
                                  '\₹${vendor['budget']['to']}',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              sizedBoxWidth,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              sizedbox,
              CustomHeadLineTextWidget(
                  screenHeight: screenHeight, text: Assigns.clientInformation),
              sizedbox,
              Card(
                color: Colors.white12,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(children: [
                          DateAndTimeWidget(
                              TypeText: Assigns.name, value: clientName)
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          DateAndTimeWidget(
                              TypeText: Assigns.email, value: clientEmail)
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          DateAndTimeWidget(
                              TypeText: Assigns.phoneNumberdot,
                              value: phoneNumber)
                        ]),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
