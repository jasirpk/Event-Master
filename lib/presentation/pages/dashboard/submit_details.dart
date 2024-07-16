// ignore_for_file: unnecessary_null_comparison
import 'dart:io';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/create_event/event+fields.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubmitDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedVendors;
  final String? subImagePath;
  final String? subCategoryName;
  final String? subdescripion;

  SubmitDetailsScreen(
      {super.key,
      required this.selectedVendors,
      this.subImagePath,
      this.subCategoryName,
      this.subdescripion});

  @override
  State<SubmitDetailsScreen> createState() => _SubmitDetailsScreenState();
}

class _SubmitDetailsScreenState extends State<SubmitDetailsScreen> {
  TextEditingController clientNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController eventTypeController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController guestCountController = TextEditingController();
  String? imagePath = '';
  File? image;
  @override
  void initState() {
    eventTypeController.text = widget.subCategoryName ?? '';
    aboutController.text = widget.subdescripion ?? '';
    imagePath = widget.subImagePath ?? '';
    super.initState();
  }

  DashboardBloc? generatedBloc;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    generatedBloc = context.read<DashboardBloc>();
  }

  @override
  void dispose() {
    generatedBloc?.add(ClearImage());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double sum = 0;
    for (var vendor in widget.selectedVendors) {
      sum += vendor['budget']['to'];
    }

    return Scaffold(
      appBar: CustomAppBarWithDivider(title: Assigns.submitDetails),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is LocationFetchLoading) {
            showDialog(
                context: context,
                builder: (context) => Center(
                      child: CircularProgressIndicator(),
                    ));
          }
        },
        builder: (context, state) {
          Color selectedColor =
              (state is ColorThemeChanged) ? state.newColor : Colors.blue;
          if (state is DashboardInitial) {
            image = state.pickImage;
            locationController.text = state.pickLocation;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: EventFieldsWidget(
                screenHeight: screenHeight,
                clientNameController: clientNameController,
                emailController: emailController,
                phoneNumberController: phoneNumberController,
                locationController: locationController,
                dateController: dateController,
                timeController: timeController,
                eventTypeController: eventTypeController,
                aboutController: aboutController,
                imagePath: imagePath,
                image: image,
                screenWidth: screenWidth,
                selectedColor: selectedColor,
                guestCountController: guestCountController,
                widget: widget,
                sum: sum),
          );
        },
      ),
    );
  }
}
