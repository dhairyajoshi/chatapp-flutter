import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'AppBloc.dart';
import '../objectbox.g.dart';
import '../services/backend_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

class ContactFetchState extends AppState {}

class ContactFetchedState extends AppState {
  String usrph;
  List<Map<String, dynamic>> contacts;

  ContactFetchedState(this.usrph, this.contacts);

  @override
  // TODO: implement props
  List<Object?> get props => [contacts];
}

class FetchContactEvent extends AppEvent {}

class OpenChatEvent extends AppEvent {}

class ContactBloc extends Bloc<AppEvent, AppState> {
  @override
  Future<void> close() {
    // TODO: implement close
    store.close();
    return super.close();
  }

  BackendService backendService;
  late Store store;
  String usrph = '';

  List<Map<String, dynamic>> contactlist = [];
  ContactBloc(this.backendService) : super(ContactFetchState()) {
    on<FetchContactEvent>(
      (event, emit) async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        usrph = sharedPreferences.getString('phoneNo')!;
        store = await openStore();
        final contactbox = store.box<ContactModel>();
        List<ContactModel> contacts = contactbox.getAll();
        List<Map<String, dynamic>> data = [];

        for (int i = 0; i < contacts.length; i++) {
          data.add(contacts[i].toJson());
        }

        contactlist = data;
        emit(ContactFetchedState(usrph, contactlist));

        final PermissionStatus permission = await Permission.contacts.status;

        if (permission == PermissionStatus.granted) {
          final Iterable<Contact> contacts =
              await ContactsService.getContacts();
          List<String> chkcnt = [];

          for (int i = 0; i < contacts.length; i++) {
            String contact = contacts
                .elementAt(i)
                .phones!
                .first
                .value!
                .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
            contact = contact
                .split("")
                .reversed
                .join("")
                .substring(0, 10)
                .split("")
                .reversed
                .join("").toString();
            chkcnt.add(contact);
          }
          List<Map<String, dynamic>> newdata =
              await backendService.getUsers(chkcnt);


          if (newdata != data) {
            contactlist = newdata;
            emit(ContactFetchedState(usrph, contactlist));
            final contactbox = store.box<ContactModel>();
            List<ContactModel> contacts = contactbox.getAll();
            for (int i = 0; i < contacts.length; i++) {
              contactbox.remove(contacts[i].id);
            }
            for (int i = 0; i < newdata.length; i++) {
              contactbox.put(
                  ContactModel(newdata[i]['phoneNo'], newdata[i]['name'], ''));
            }
          }

          store.close();
        } else {
          final Map<Permission, PermissionStatus> permissionStatus =
              await [Permission.contacts].request();
          store.close();
          if (permissionStatus[Permission.contacts] ==
              PermissionStatus.denied) {
            SystemNavigator.pop();
          } else {
            if (!store.isClosed()) {
              store.close();
            }
            add(FetchContactEvent());
          }
        }

        store.close();
      },
    );

    on<OpenChatEvent>(
      (event, emit) {
        store.close();
      },
    );
  }
}
