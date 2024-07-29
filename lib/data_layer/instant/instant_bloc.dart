import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

part 'instant_event.dart';
part 'instant_state.dart';

class InstantBloc extends Bloc<InstantEvent, InstantState> {
  List<Contact> contacts = [];
  InstantBloc() : super(InstantInitial()) {
    on<FetchContacts>(fetchEvent);
    on<SendGreetingCard>(SendGreetingsCard);
    on<SearchQuery>(searchQuery);
  }

  FutureOr<void> fetchEvent(
      FetchContacts event, Emitter<InstantState> emit) async {
    emit(ContactLoading());
    try {
      if (await Permission.contacts.request().isGranted) {
        contacts = await ContactsService.getContacts();
        emit(ContactLoaded(contacts, contacts));
      } else {
        print('Somthing error to fetch contacts');
      }
    } catch (e) {
      print('Error encountered to fetch contacts $e');
    }
  }

  FutureOr<void> SendGreetingsCard(
      SendGreetingCard event, Emitter<InstantState> emit) {
    try {
      Share.share(event.messsage);
      emit(GreetingCardSent());
    } catch (e) {
      print('Can\'t send greetings card $e');
    }
  }

  FutureOr<void> searchQuery(SearchQuery event, Emitter<InstantState> emit) {
    final filteredContacts = contacts
        .where((contact) => (contact.displayName ?? '')
            .toLowerCase()
            .contains(event.query.toLowerCase()))
        .toList();
    emit(ContactLoaded(contacts, filteredContacts));
  }
}
