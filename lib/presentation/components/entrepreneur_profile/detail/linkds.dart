import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LinksWidget extends StatelessWidget {
  const LinksWidget({
    super.key,
    required this.widget,
  });

  final DetailFieldsWidget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.screenHeight * 0.1,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.links.length,
            itemBuilder: (context, index) {
              var data = widget.links[index];
              return Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.forward,
                        color: Colors.white,
                        size: 10,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(data['link'],
                            style: TextStyle(
                                fontSize: widget.screenHeight * 0.018,
                                fontWeight: FontWeight.w300,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              );
            }));
  }
}
