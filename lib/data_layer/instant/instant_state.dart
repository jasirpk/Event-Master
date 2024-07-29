part of 'instant_bloc.dart';

@immutable
sealed class InstantState {}

final class InstantInitial extends InstantState {}

class ContactLoading extends InstantState {}

class ContactLoaded extends InstantState {
  final Iterable<Contact> contacts;
  final List<Contact> filteredContacts;

  ContactLoaded(this.contacts, this.filteredContacts);
}

class GreetingCardSent extends InstantState {}
