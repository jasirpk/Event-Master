// import 'dart:async';
// import 'dart:developer';
//
// import 'package:bloc/bloc.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:meta/meta.dart';
// import 'package:share_plus/share_plus.dart';
//
// part 'instant_event.dart';
// part 'instant_state.dart';
//
// class InstantBloc extends Bloc<InstantEvent, InstantState> {
//   List<Contact> contacts = [];
//
//   InstantBloc() : super(InstantInitial()) {
//     on<FetchContacts>(fetchEvent);
//     on<SendGreetingCard>(sendGreetingsCard);
//     on<SearchQuery>(searchQuery);
//   }
//
//   FutureOr<void> fetchEvent(
//       FetchContacts event,
//       Emitter<InstantState> emit,
//       ) async {
//     emit(ContactLoading());
//
//     try {
//       final granted = await FlutterContacts.requestPermission();
//
//       if (granted) {
//         contacts = await FlutterContacts.getContacts(
//           withProperties: true, // include phones, emails, etc.
//         );
//
//         emit(ContactLoaded(contacts, contacts));
//       } else {
//         log("Contacts permission denied");
//       }
//     } catch (e, stackTrace) {
//       log(
//         "Error fetching contacts",
//         error: e,
//         stackTrace: stackTrace,
//       );
//     }
//   }
//   FutureOr<void> sendGreetingsCard(
//       SendGreetingCard event,
//       Emitter<InstantState> emit,
//       ) {
//     try {
//       Share.share(event.messsage);
//
//       emit(GreetingCardSent());
//     } catch (e) {
//       log("Can't send greeting card: $e");
//     }
//   }
//
//   FutureOr<void> searchQuery(
//       SearchQuery event,
//       Emitter<InstantState> emit,
//       ) {
//     final filteredContacts = contacts.where((contact) {
//       return contact.displayName
//           .toLowerCase()
//           .contains(event.query.toLowerCase());
//     }).toList();
//
//     emit(ContactLoaded(contacts, filteredContacts));
//   }
// }