import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_screen.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final UserProfile userProfile = UserProfile();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          'Event Master',
          style: TextStyle(
              color: Colors.white,
              fontSize: screenHeight * 0.028,
              letterSpacing: 1,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userProfile.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Templates Found'),
            );
          }
          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index];
              var userUid = documents[index].id;
              return FutureBuilder<DocumentSnapshot>(
                future: userProfile.getUserDetailById(userUid),
                builder: (context, detailSnapshot) {
                  String currentUserUid =
                      FirebaseAuth.instance.currentUser!.uid;
                  String chatId = _getChatId(currentUserUid, userUid);
                  if (detailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerSubCategoryItem(
                        screenHeight: screenHeight, screenWidth: screenWidth);
                  }
                  if (detailSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${detailSnapshot.error}'),
                    );
                  }
                  if (!detailSnapshot.hasData || detailSnapshot.data == null) {
                    return Center(child: Text('Details not found'));
                  }
                  var userDetails = detailSnapshot.data!;
                  return InkWell(
                    onTap: () {
                      Get.to(() => ChatScreen(
                            chatId: chatId,
                            recipientId: userUid,
                            companyName: data['companyName'],
                            imageUrl: userDetails['profileImage'],
                          ));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          leading: CircleAvatar(
                            maxRadius: 30,
                            backgroundImage: userDetails['profileImage'] != null
                                ? NetworkImage(userDetails['profileImage'])
                                : AssetImage(
                                        'assets/images/Circle-icons-profile.svg.png')
                                    as ImageProvider,
                          ),
                          title: Text(
                            data['companyName'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.024,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            userDetails['emailAddress'] ?? 'No email',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                Get.to(() => ChatScreen(
                                    companyName: data['companyName'],
                                    imageUrl: userDetails['profileImage'],
                                    chatId: chatId,
                                    recipientId: userUid));
                              },
                              icon: Icon(
                                CupertinoIcons.forward,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }
}
