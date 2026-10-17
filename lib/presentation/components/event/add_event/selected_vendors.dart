import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/models/vendor_document.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
import 'package:event_master/presentation/pages/dashboard/create_event.dart';
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
                        // imagePathUrl is an R2 object key since the
                        // migration, so it has to be signed before it can be
                        // displayed. startsWith('http') sent every key down
                        // the AssetImage branch, which asked Flutter for a
                        // bundled asset named "vendor_images/..." and threw
                        // "Unable to load asset". MediaImage tells a key from
                        // a legacy URL and handles both.
                        MediaImage(
                          imagePath: vendorText(vendor['imagePathUrl']),
                          placeholder: kMediaPlaceholderImage,
                          builder: (context, image) => CircleAvatar(
                            maxRadius: 20,
                            backgroundColor: myColor,
                            backgroundImage: image,
                          ),
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
