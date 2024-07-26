import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/notes.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_all_subcategories.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/notes_create.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    NotesMethods notesMethods = NotesMethods();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: myColor,
        onPressed: () {
          Get.to(() => CreateNotes());
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: CustomAppBarWithDivider(title: 'Notes'),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesMethods.getNotes(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerSubCategoryItem(
                screenHeight: screenHeight, screenWidth: screenWidth);
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Lottie.asset(
                'assets/images/Animation - 1721975522807.json',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,
              ),
            );
          }

          var documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              String noteId = document.id;
              var data = document.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.teal,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: FutureBuilder<DocumentSnapshot?>(
                      future: notesMethods.getNOtesById(uid, noteId),
                      builder: (context, noteSnapshot) {
                        if (noteSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ShimmerAllSubcategories(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          );
                        }

                        if (!noteSnapshot.hasData ||
                            noteSnapshot.data == null ||
                            noteSnapshot.data!.data() == null) {
                          return Center(
                            child: Text(
                              'Details not found for $noteId',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return Container(
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    child: Row(
                                  children: [
                                    Text(
                                      data['title'],
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.022,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      data['date'],
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.014,
                                        color: myCustomColor,
                                      ),
                                    ),
                                  ],
                                )),
                                PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                  ),
                                  color: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      notesMethods.deletenote(uid, noteId);
                                    } else if (value == 'update') {
                                      Get.to(() => CreateNotes(
                                            title: data['title'],
                                            date: data['date'],
                                            description: data['description'],
                                            isUpdate: true,
                                            noteId: noteId,
                                          ));
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: Text('Delete'),
                                        value: 'delete',
                                      ),
                                      PopupMenuItem(
                                        child: Text('Update'),
                                        value: 'update',
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                            subtitle: Text(
                              data['description'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
