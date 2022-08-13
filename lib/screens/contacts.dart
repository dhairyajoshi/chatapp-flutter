// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:chatapp/screens/chatscreen.dart';
import 'package:chatapp/services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ContactsPage extends StatefulWidget {
  String usrph;
  ContactsPage({Key? key,required this.usrph}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // BackendService backendService=BackendService();
  // late Socket socket;
  // late List<Map<String,dynamic>> contacts=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // socket=backendService.initSocket();
    // contacts=backendService.getUsers();
    // socket.on('refresh', (data) => {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              width: double.infinity,
              color: Color.fromRGBO(34, 45, 54, 1),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WhatsApp',
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          )
                        ],
                      )
                    ],
                  ), //
                ],
              ),
            ),
            Flexible(
                child: Container(
              color: Color.fromRGBO(10, 26, 35, 1),
              child: FutureBuilder(
                future: BackendService().getUsers(),
                builder: (context,AsyncSnapshot snap){
                  if(snap.hasData){
                    return ListView.builder(
                    itemCount: snap.data.length,
                    itemBuilder: (context, index) {
                      return ContactCard(contact:snap.data[index],usrph:widget.usrph);
                    });
                  }
                  else {
                    return Center(child: CircularProgressIndicator(),);
                  }
                },
              ),
            ))
          ]),
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  Map<String,dynamic> contact;
  String usrph;
  ContactCard({Key? key,required this.contact,required this.usrph}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatScreen(contact: contact,usrph:usrph))),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        width: double.infinity,
        color:Colors.transparent, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact['name'], 
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      contact['last_message']?? ' ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  contact['last_message_time']?? '   ',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
