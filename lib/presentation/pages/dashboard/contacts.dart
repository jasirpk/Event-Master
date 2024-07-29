import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/instant/instant_bloc.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SelectContactsView extends StatefulWidget {
  final String message;

  const SelectContactsView({super.key, required this.message});
  @override
  State<SelectContactsView> createState() => _SelectContactsViewState();
}

class _SelectContactsViewState extends State<SelectContactsView> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    context.read<InstantBloc>().add(FetchContacts());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          Assigns.contacts,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<InstantBloc, InstantState>(
        builder: (context, state) {
          if (state is ContactLoading) {
            return Center(
                child: Lottie.asset(Assigns.lottieImage,
                    fit: BoxFit.cover, height: 100));
          } else if (state is ContactLoaded) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(18.0),
                  child: CustomTextFieldWidget(
                    controller: searchController,
                    labelText: 'Search',
                    prefixIcon: Icons.search,
                    readOnly: false,
                    onChanged: (query) {
                      context.read<InstantBloc>().add(SearchQuery(query));
                    },
                  ),
                ),
                state.filteredContacts.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Lottie.asset(Assigns.searchEmptyImage,
                              fit: BoxFit.cover),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: state.filteredContacts.length,
                          itemBuilder: (context, index) {
                            Contact contact = state.filteredContacts[index];
                            return ListTile(
                              title: Text(
                                contact.displayName ?? '',
                                style: TextStyle(color: Colors.white),
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage(Assigns.personImage),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  context.read<InstantBloc>().add(
                                      SendGreetingCard(
                                          contact, widget.message));
                                },
                                child: Text('Invite'),
                              ),
                              onTap: () {
                                context.read<InstantBloc>().add(
                                    SendGreetingCard(contact, widget.message));
                              },
                            );
                          },
                        ),
                      ),
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
