import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/entrepreneurs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => EntrepreneursListScreen());
          },
          label: Text(
            '+Add Events',
          )),
      appBar: CustomAppBarWithDivider(title: 'Events'),
    );
  }
}
