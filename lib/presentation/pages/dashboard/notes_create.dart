import 'package:event_master/bussiness_layer.dart/addnote.dart';
import 'package:event_master/bussiness_layer.dart/update_note.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateNotes extends StatefulWidget {
  final String? title;
  final String? date;
  final String? description;
  final String? noteId;
  final bool? isUpdate;

  CreateNotes(
      {super.key,
      this.title,
      this.date,
      this.description,
      this.isUpdate,
      this.noteId});

  @override
  State<CreateNotes> createState() => _CreateNotesState();
}

class _CreateNotesState extends State<CreateNotes> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionContrller = TextEditingController();
  @override
  void initState() {
    dateController.text = widget.date ?? '';
    titleController.text = widget.title ?? '';
    descriptionContrller.text = widget.description ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'New Note'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Assigns.createOne,
                  style: TextStyle(
                    letterSpacing: 1,
                    fontSize: screenHeight * 0.036,
                  ),
                ),
                sizedbox,
                Text(
                  Assigns.noteContent,
                  style: TextStyle(fontSize: screenHeight * 0.018),
                ),
                SizedBox(height: 40),
                CustomTextFieldWidget(
                  controller: dateController,
                  prefixIcon: Icons.calendar_month,
                  labelText: 'Choose a date',
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(200),
                        lastDate: DateTime(2101));
                    if (pickedDate != null) {
                      dateController.text =
                          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                    }
                  },
                ),
                sizedbox,
                CustomTextFieldWidget(
                    controller: titleController,
                    prefixIcon: Icons.note,
                    labelText: 'Your title',
                    readOnly: false),
                sizedbox,
                CustomTextFieldWidget(
                    controller: descriptionContrller,
                    labelText: 'Description',
                    maxLines: 4,
                    readOnly: false),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: PushableButton_Widget(
                      buttonText: 'Save',
                      onpressed: () async {
                        var uid = FirebaseAuth.instance.currentUser!.uid;
                        if (widget.isUpdate != true) {
                          saveNote(uid, titleController, dateController,
                              descriptionContrller);
                        } else {
                          updateNote(uid, widget.noteId!, titleController,
                              dateController, descriptionContrller);
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
