// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:chatapp/services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  Map<String, dynamic> contact;
  String usrph;
  ChatScreen({Key? key, required this.contact, required this.usrph})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Socket socket;
  final myController = TextEditingController();
  BackendService backendService = BackendService();

  final ScrollController _controller = ScrollController();
  List<Map<String, dynamic>> messages = [];
  @override
  void initState() {
    super.initState();
    socket = backendService.initSocket();

    socket.on('message', (data) {
      if (data['rec'] == widget.usrph &&
          data['sen'] == widget.contact['phoneNo']) {
        Timer(Duration(seconds: 2), () => setState(() {}));
      }
    });

    socket.on('refresh', (data) {
      if (data['rec'] == widget.contact['phoneNo'] &&
          data['sen'] == widget.usrph) {
        Timer(Duration(seconds: 2), () => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    backendService.disconnectSocket();
    socket.dispose();
    backendService.closeStore();
    myController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(10, 26, 35, 1),
      body: Container(
        child: SafeArea(
          child: Column(
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
                              color: Color.fromARGB(255, 255, 254, 254)),
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
                          widget.contact['name'],
                          style: TextStyle(color: Colors.white, fontSize: 19),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                  color: Color.fromRGBO(10, 26, 35, 1),
                  child: StreamBuilder(
                    stream:
                        backendService.getMessages(widget.contact['phoneNo']),
                    builder: (context, AsyncSnapshot snap) {
                      if (snap.hasData) {
                        // messages = snap.data;
                        return ListView.builder(
                          reverse: true,
                          controller: _controller,
                          itemCount: snap.data.length,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment:
                                  snap.data[index]['sender'] != widget.usrph
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.8),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    decoration: BoxDecoration(
                                        color: snap.data[index]['sender'] !=
                                                widget.usrph
                                            ? Color.fromRGBO(34, 47, 54, 1)
                                            : Color.fromRGBO(4, 71, 64, 1),
                                        borderRadius: snap.data[index]
                                                    ['sender'] !=
                                                widget.usrph
                                            ? BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20))
                                            : BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            snap.data[index]['message'],
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            snap.data[index]['time'],
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
                        );
                      }
                      // print(snap.error);
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: myController,
                          decoration: InputDecoration(
                              hintText: 'Message',
                              filled: true,
                              fillColor: Color.fromARGB(255, 255, 254, 254)),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (myController.text.trim() != "") {
                          var now = DateTime.now();
                          String msg = myController.text.trim().length > 3
                              ? myController.text.trim()
                              : "${myController.text}  ";
                          // socket.emit('message', {'text':msg,'time':DateFormat('HH:mm').format(now).toString()},);
                          backendService.sendMessage(
                              socket, widget.contact['phoneNo'], msg);

                          setState(() {
                            myController.text = "";
                            _controller
                                .jumpTo(_controller.position.maxScrollExtent);
                          });
                        }
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
          ),
        ),
      ),
    );
  }
}
