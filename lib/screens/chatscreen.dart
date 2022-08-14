// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:chatapp/bloc/AppBloc.dart';
import 'package:chatapp/bloc/ChatBloc.dart';
import 'package:chatapp/services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  final myController = TextEditingController();
  Map<String, dynamic> contact;
  String usrph;

  ChatScreen({Key? key, required this.contact, required this.usrph})
      : super(key: key);

  List<Map<String, dynamic>> messages = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            ChatBloc(BackendService())..add(FetchChatEvent(contact['phoneNo'])),
        child: Scaffold(
            backgroundColor: Color.fromRGBO(10, 26, 35, 1),
            body: SafeArea(
              child:
                  BlocBuilder<ChatBloc, AppState>(builder: ((context, state) {
                if (state is ChatFetchedState) {
                  return Column(
                    children: [
                      Container(
                        color: Color.fromRGBO(34, 45, 54, 1),
                        height: 55,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back,
                                      color:
                                          Color.fromARGB(255, 255, 254, 254)),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                CircleAvatar(
                                  radius: 17,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  contact['name'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 19),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                            padding:
                                EdgeInsets.only(top: 10, left: 5, right: 5),
                            color: Color.fromRGBO(10, 26, 35, 1),
                            child: ListView.builder(
                              controller: BlocProvider.of<ChatBloc>(context).scrlcont,
                              itemCount: state.data.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      state.data[index]['sender'] != usrph
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                        decoration: BoxDecoration(
                                            color: state.data[index]
                                                        ['sender'] !=
                                                    usrph
                                                ? Color.fromRGBO(34, 47, 54, 1)
                                                : Color.fromRGBO(4, 71, 64, 1),
                                            borderRadius: state.data[index]
                                                        ['sender'] !=
                                                    usrph
                                                ? BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(20),
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(20))
                                                : BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                state.data[index]['message'],
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                state.data[index]['time'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            )),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: BlocProvider.of<ChatBloc>(context).textControl,
                                  onChanged: (val) =>
                                      BlocProvider.of<ChatBloc>(context)
                                          .setMessage(val),
                                  decoration: InputDecoration(
                                  
                                      hintText: 'Message',
                                      filled: true,
                                      fillColor:
                                          Color.fromARGB(255, 255, 254, 254)),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                BlocProvider.of<ChatBloc>(context)
                                    .add(SendMessageEvent());
                              },
                              icon: Icon(
                                Icons.send,
                                color: Color.fromARGB(255, 255, 254, 254),
                              ),
                              color: Color.fromARGB(255, 255, 254, 254),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              })),
            )));
  }
}
