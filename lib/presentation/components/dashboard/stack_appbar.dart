import 'package:event_master/bussiness_layer.dart/fullscreen_snackbar.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/pages/dashboard/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StackAppBar extends StatelessWidget {
  const StackAppBar({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    FullscreenSnackbar fullscreenSnackbar = FullscreenSnackbar();
    return Stack(
      children: <Widget>[
        // Background image container
        Container(
          height: 160,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/cover_img_2.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
        ),

        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Transform.rotate(
              angle: 5.5,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.send_sharp),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
            ),
            SizedBox(width: 8),
          ],
        ),

        Positioned(
          top: 28,
          left: 0,
          right: 0,
          child: ListTile(
            leading: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: myColor,
                  width: 2.0,
                ),
              ),
              child: InkWell(
                onTap: () {
                  Get.to(() => ProfileScreen());
                },
                child: CircleAvatar(
                  maxRadius: 30,
                  backgroundImage: AssetImage('assets/images/download.jpeg'),
                ),
              ),
            ),
            title: Container(
              child: Text(
                'Hey! PK Events',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'JacquesFracois',
                  color: Colors.white,
                ),
              ),
            ),
            subtitle: Container(
              child: Text(
                'Welcome to Admin Master',
                style: TextStyle(
                  fontSize: screenHeight * 0.016,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'JacquesFracois',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(
            top: 118,
          ),
          child: Container(
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              border: Border.all(width: 1.5, color: Colors.white60),
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create event',
                        style: TextStyle(
                            fontSize: screenHeight * 0.020,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                      sizedBoxWidth,
                      Text(
                        'Bring your party to the Next Level',
                        style: TextStyle(letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.lerp(
                          BorderRadius.circular(4),
                          BorderRadius.circular(4),
                          0.5,
                        ),
                        color: myColor),
                    child: IconButton(
                        onPressed: () {
                          fullscreenSnackbar.showFullScreenSnackbar(context);
                        },
                        icon: Icon(
                          CupertinoIcons.forward,
                          color: Colors.black,
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
