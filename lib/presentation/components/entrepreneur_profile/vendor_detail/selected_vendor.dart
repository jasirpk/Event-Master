import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedVendorWidget extends StatelessWidget {
  const SelectedVendorWidget({
    super.key,
    required this.documentId,
    required this.vendorDetail,
  });

  final String documentId;
  final Map<String, dynamic> vendorDetail;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isSelected = state is VendorSelectionState &&
            state.selectedVendors.any((vendor) => vendor['uid'] == documentId);
        return Checkbox(
          value: isSelected,
          onChanged: (value) {
            if (value == true) {
              context.read<DashboardBloc>().add(SelectedVendor(vendorDetail));
            } else {
              context.read<DashboardBloc>().add(DeselectVendor(documentId));
            }
          },
        );
      },
    );
  }
}
