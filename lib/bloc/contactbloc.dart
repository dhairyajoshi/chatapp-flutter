import 'package:chatapp/bloc/appbloc.dart';
import 'package:chatapp/objectbox.g.dart';
import 'package:chatapp/services/backend_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:objectbox/objectbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

class ContactFetchState extends AppState{}

class ContactFetchedState extends AppState{
  String usrph;
  List<Map<String,dynamic>> contacts;

  ContactFetchedState(this.usrph,this.contacts);
}

class FetchContactEvent extends AppEvent{}

class OpenChatEvent extends AppEvent{}

class ContactBloc extends Bloc<AppEvent,AppState>{

  @override
  Future<void> close() {
    // TODO: implement close
    store.close();
    return super.close();
  }

  BackendService backendService;
  late Store store;
  String usrph='';

  List<Map<String,dynamic>> contactlist=[];
  ContactBloc(this.backendService):super(ContactFetchState()){
    on<FetchContactEvent>((event, emit) async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    usrph=sharedPreferences.getString('phoneNo')!;
    store = await openStore();
    final contactbox = store.box<ContactModel>();
    List<ContactModel> contacts = contactbox.getAll();
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < contacts.length; i++) {
      data.add(contacts[i].toJson());
    }

    contactlist=data;
    emit(ContactFetchedState(usrph,contactlist));

    List<Map<String, dynamic>> newdata =
            await backendService.getUsers();

        if (newdata != data) {
          contactlist=newdata;
          emit(ContactFetchedState(usrph,contactlist));
          for (int i = 0; i < contacts.length; i++) {
            contactbox.remove(contacts[i].id);
          }
          for (int i = 0; i < newdata.length; i++) {
            contactbox.put(ContactModel(newdata[i]['phoneNo'], newdata[i]['name'], '')); 
          }
        }

    store.close();
    },);

    on<OpenChatEvent>((event, emit) {
      store.close();
    },);
  }

}