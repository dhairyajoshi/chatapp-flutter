import 'package:chatapp/bloc/AppBloc.dart';
import 'package:chatapp/models/message.dart';
import 'package:chatapp/objectbox.g.dart';
import 'package:chatapp/services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatFetchState extends AppState {}

class ChatFetchedState extends AppState {
  List<Map<String, dynamic>> _data;
  ChatFetchedState(this._data);

  @override
  // TODO: implement props
  List<Object?> get props => [_data];

  get data => _data;
}

class FetchChatEvent extends AppEvent {
  String c2;

  FetchChatEvent(this.c2);
}

class SendMessageEvent extends AppEvent{

}

class ChatBloc extends Bloc<AppEvent, AppState> {
  @override
  Future<void> close() {
    // TODO: implement close
    socket.disconnect();
    socket.dispose();
    store.close();
    textControl.dispose();
    scrlcont.dispose();
    return super.close();
    
  }
  
  BackendService backendService;
  late Socket socket;
  late Store store;
  String contact = "";
  String message="";
  TextEditingController textControl = TextEditingController();
  final ScrollController scrlcont = ScrollController();

  List<Map<String,dynamic>> texts=[];
  ChatBloc(this.backendService) : super(ChatFetchState()) {
    socket = backendService.initSocket();
        socket.on('message', ((data) {
          add(FetchChatEvent(contact));
        }));
    on<FetchChatEvent>(
      (event, emit) async {
        
        store = await openStore();
        final messagebox = store.box<MessageModel>();
        contact = event.c2;
        List<MessageModel> messages = messagebox
            .query(MessageModel_.contact.equals(event.c2))
            .build()
            .find();
        List<Map<String, dynamic>> data = [];
        for (int i = 0; i < messages.length; i++) {
          data.add(messages[i].toJson());
        }
        texts=data;
        emit(ChatFetchedState(texts));

        List<Map<String, dynamic>> newdata =
            await backendService.getMessages(event.c2);

        if (newdata != data) {
          texts=newdata;
          emit(ChatFetchedState(texts));
          for (int i = 0; i < messages.length; i++) {
            messagebox.remove(messages[i].id);
          }
          for (int i = 0; i < newdata.length; i++) {
            messagebox.put(MessageModel(event.c2, newdata[i]['message'],
                newdata[i]['time'], newdata[i]['sender']));
          }
        }

        scrlcont.jumpTo(scrlcont.position.maxScrollExtent);
        store.close();
      },
    );

    on<SendMessageEvent>((event, emit) async{
      store.close();
      message=message.trim();
      if(message!=""){
        if(message.length<2){
          message+="  ";
        }
        SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
        final usr=sharedPreferences.getString('phoneNo')!;
        String time = DateFormat('HH:mm').format(DateTime.now()).toString();
        final newtext= {'receiver': contact, 'sender': usr, 'message': message, 'time': time};
        texts.add(newtext);
        socket.emit(
        'message', {'message': message, 'rec': contact, 'sen': usr, 'time': time});
        Store store= await openStore();
        final messages=store.box<MessageModel>();
        messages.put(MessageModel(contact,message,time,usr));
        backendService.sendMessage(contact, message);
        store.close();
        textControl.text="";
        // scrlcont.jumpTo(scrlcont.position.maxScrollExtent);
        add(FetchChatEvent(contact));
      }
    },);
  }

  setMessage(val) => message=val;
}
