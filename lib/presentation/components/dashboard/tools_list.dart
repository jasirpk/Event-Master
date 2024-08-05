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
          return InkWell(
            onTap: data['onTap'],
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: screenWidth * 0.32,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(data['image']),
                  fit: BoxFit.cover,
                  // colorFilter: ColorFilter.mode(
                  //   Colors.black.withOpacity(0.1),
                  //   BlendMode.color,
                  // ),
                ),

                borderRadius: BorderRadius.circular(10),
                // gradient: LinearGradient(
                //   colors: [
                //     Colors.grey,
                //     Colors.white12,
                //   ],
                //   begin: Alignment.centerLeft,
                //   end: Alignment.centerRight,
                // ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
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
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            data['text'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'JacquesFracois',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
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
