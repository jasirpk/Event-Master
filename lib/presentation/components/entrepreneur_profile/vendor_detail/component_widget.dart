import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class componentsWidget extends StatelessWidget {
  const componentsWidget({
    super.key,
    required this.images,
    required this.screenWidth,
  });

  final List<Map<String, dynamic>> images;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white38,
      child: Column(
        children: List.generate(
          images.length,
          (index) {
            var data = images[index];
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right, color: Colors.white),
                        sizedBoxWidth,
                        Text(
                          data['text'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.038,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    maxRadius: 14,
                    backgroundColor: Colors.blue,
                    backgroundImage: data['imageUrl'].startsWith('http')
                        ? NetworkImage(data['imageUrl'])
                        : AssetImage(data['imageUrl']) as ImageProvider,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
