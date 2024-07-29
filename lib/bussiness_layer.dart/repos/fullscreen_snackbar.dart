import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/pages/dashboard/all_templates.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneurs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullscreenSnackbar {
  void showFullScreenSnackbar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            backgroundBlendMode: BlendMode.darken,
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(() => AllTemplatesScreen());
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height *
                              (140 / MediaQuery.of(context).size.height),
                          width: MediaQuery.of(context).size.width *
                              double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: ListTile(
                              leading: CircleAvatar(
                                maxRadius: 30,
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.explore,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                Assigns.useTemplate,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                Assigns.templateDes,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                              trailing: Icon(
                                CupertinoIcons.forward,
                              ),
                            ),
                          ),
                        ),
                      ),
                      sizedbox,
                      InkWell(
                        onTap: () {
                          Get.to(() => EntrepreneursListScreen());
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height *
                              (140 / MediaQuery.of(context).size.height),
                          width: MediaQuery.of(context).size.width *
                              double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: ListTile(
                              leading: CircleAvatar(
                                maxRadius: 30,
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                Assigns.createEvent,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                Assigns.createDes,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                              trailing: Icon(
                                CupertinoIcons.forward,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 220),
                CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: myColor,
                  child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
