import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class ToolsListWidget extends StatelessWidget {
  const ToolsListWidget({
    super.key,
    required this.screenHeight,
    required this.items,
    required this.screenWidth,
  });

  final double screenHeight;
  final List<Map<String, dynamic>> items;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.14,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          var data = items[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: screenWidth * 0.32,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: myColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 4, left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: myColor,
                        ),
                        child: Center(
                          child: Icon(
                            data['icon'],
                            color: Colors.black, // Optional: set icon color
                            size: 24, // Optional: set icon size
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        data['text'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
