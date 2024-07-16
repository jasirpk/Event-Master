import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/pages/dashboard/submit_details.dart';
import 'package:flutter/material.dart';

class SelectedVendorsWidget extends StatelessWidget {
  const SelectedVendorsWidget({
    super.key,
    required this.screenHeight,
    required this.widget,
    required this.screenWidth,
  });

  final double screenHeight;
  final SubmitDetailsScreen widget;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.2,
      child: ListView.builder(
        itemCount: widget.selectedVendors.length,
        itemBuilder: (context, index) {
          var vendor = widget.selectedVendors[index];

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
                          backgroundImage:
                              vendor['imagePathUrl'].startsWith('http')
                                  ? NetworkImage(vendor['imagePathUrl'])
                                  : AssetImage(vendor['imagePathUrl'])
                                      as ImageProvider,
                        ),
                        SizedBox(width: 8),
                        Container(
                          constraints:
                              BoxConstraints(maxWidth: screenWidth * 0.3),
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
    );
  }
}
