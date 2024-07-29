part of 'instant_bloc.dart';

@immutable
sealed class InstantEvent {}

class FetchContacts extends InstantEvent {}

class SendGreetingCard extends InstantEvent {
  final Contact contact;
  final String messsage;

  SendGreetingCard(this.contact, this.messsage);
}

class SearchQuery extends InstantEvent {
  final String query;

  SearchQuery(this.query);
}
