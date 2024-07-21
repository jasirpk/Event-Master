import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/vendor.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/list/list_stream.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/all_templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EntrepreneursListScreen extends StatelessWidget {
  final String? subImagePath;
  final String? subCategoryName;
  final String? subdescripion;

  const EntrepreneursListScreen({
    super.key,
    this.subImagePath,
    this.subCategoryName,
    this.subdescripion,
  });
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Entrepreneurs',
        actions: [
          IconButton(
            icon: Icon(
              Icons.source,
              color: Colors.white,
            ),
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
              child: TextFormField(
                controller: searchController,
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
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      searchController.clear();
                    },
                  ),
                ),
                onChanged: (value) {
                  context.read<DashboardBloc>().add(SearchTermChanged(value));
                },
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is SearchLoaded) {
                    return ListOfStreamWidget(
                      userProfile: UserProfile(),
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      vendorRequest: VendorRequest(),
                      searchTerm: state.searchTerm,
                    );
                  } else if (state is SearchError) {
                    return Center(child: Text(state.message));
                  }
                  return ListOfStreamWidget(
                    userProfile: UserProfile(),
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    vendorRequest: VendorRequest(),
                    searchTerm: '',
                    subImagePath: subImagePath,
                    subCategoryName: subCategoryName,
                    subdescripion: subdescripion,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
