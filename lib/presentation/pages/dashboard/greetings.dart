import 'package:event_master/bussiness_layer.dart/repos/instant_meet.dart';
import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/instant/instant_bloc.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class GreetingCardView extends StatefulWidget {
  @override
  State<GreetingCardView> createState() => _GreetingCardViewState();
}

class _GreetingCardViewState extends State<GreetingCardView> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  String? selectedItem1;
  String? selectedItem2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'New Instant Meet'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Assigns.invite,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.028),
              ),
              SizedBox(height: 16.0),
              Text(
                Assigns.instantAbout,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018),
              ),
              SizedBox(height: 16.0),
              CustomTextFieldWidget(
                controller: messageController,
                labelText: Assigns.aboutDes,
                readOnly: false,
                maxLines: 4,
              ),
              SizedBox(height: 16.0),
              SizedBox(height: 16.0),
              SizedBox(
                height: 50,
                child: ListView.builder(
                    itemCount: options.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          messageController.text = options[index]['text'];
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white38,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(options[index]['icon'],
                                      color: Colors.black),
                                  SizedBox(width: 8),
                                  Text(options[index]['text'],
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(
                              "Today",
                              style: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.white),
                            value: selectedItem1,
                            iconEnabledColor: Colors.black,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedItem1 = newValue;
                              });
                            },
                            items: dropdownItems.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: DefaultTextStyle(
                                  style: TextStyle(color: Colors.black),
                                  child: Text(item),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  sizedBoxWidth,
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(
                              "Morning",
                              style: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.white),
                            value: selectedItem2,
                            iconEnabledColor: Colors.black,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedItem2 = newValue;
                              });
                            },
                            items: ItemsTime.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: DefaultTextStyle(
                                  style: TextStyle(color: Colors.black),
                                  child: Text(item),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.0),
              CustomTextFieldWidget(
                  onTap: () {
                    if (messageController.text.isNotEmpty) {
                      Get.to(() => SelectContactsView(
                            message: messageController.text,
                          ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content:
                              Text('Please fill all the required fields')));
                    }
                  },
                  prefixIcon: Icons.contact_page,
                  controller: contactController,
                  labelText: '0 friends',
                  suffixIcon: CupertinoIcons.forward,
                  readOnly: true),
              SizedBox(height: 16.0),
              BlocListener<InstantBloc, InstantState>(
                listener: (context, state) {
                  if (state is GreetingCardSent) {
                    showCustomSnackBar(
                        'Success', 'Successfully send invitation message');
                  }
                },
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
