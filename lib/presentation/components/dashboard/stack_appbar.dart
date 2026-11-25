import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/bussiness_layer.dart/repos/fullscreen_snackbar.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/prifile.dart';
import 'package:event_master/presentation/pages/dashboard/chat_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
import 'package:get/get.dart';

class StackAppBar extends StatelessWidget {
  const StackAppBar({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    FullscreenSnackbar fullscreenSnackbar = FullscreenSnackbar();
    return FutureBuilder<DocumentSnapshot>(
      future: ClientProfile().getUserProfile(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // Neither an absent profile nor a failed read takes the header down
        // with it. Everything below is the screen's navigation chrome — the
        // cover image, the chat button and the Create event card — and the
        // only thing the profile actually supplies is an avatar and a name,
        // both of which have defaults. Returning a bare error Text here used
        // to replace the whole Stack, so a user who had not filled in a
        // profile, or who was briefly offline, lost Create event entirely.
        if (snapshot.hasError) {
          debugPrint('Home profile header: ${snapshot.error}');
        }
        // .data() is null both for a document that does not exist and for a
        // snapshot that never arrived, so one null-guard covers both.
        final userData =
            snapshot.data?.data() as Map<String, dynamic>? ??
                const <String, dynamic>{};
        String imagePath = userData['imagePath'] ?? '';
        return Stack(
          children: <Widget>[
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
                  // The user's own avatar is an R2 object key since the
                  // migration; NetworkImage was handed the raw key.
                  child: MediaImage(
                      imagePath: imagePath,
                      placeholder: AssetImage(Assigns.personImage),
                      builder: (context, image) => CircleAvatar(
                            maxRadius: 30,
                            backgroundImage: image,
                          )),
                ),
                title: Container(
                  child: Text(
                    'Hey! ${userData['userName'] ?? 'user'}',
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
                    'Welcome to Event Master',
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
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Transform.rotate(
                  angle: 5.5,
                  child: IconButton(
                    onPressed: () {
                      Get.to(() => MessageListScreen());
                    },
                    icon: Icon(
                      Icons.send_sharp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
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
                              fullscreenSnackbar
                                  .showFullScreenSnackbar(context);
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
      },
    );
  }
}
