// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import '../bloc/appbloc.dart';
import '../bloc/contactbloc.dart';
import '../screens/chatscreen.dart';
import '../services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class ContactsPage extends StatelessWidget {
  const ContactsPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactBloc(BackendService())..add(FetchContactEvent()),
      child: Scaffold(
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
                child: BlocBuilder<ContactBloc,AppState>(
                  builder: (context, state) {
                    if(state is ContactFetchedState){
                      return ListView.builder(
                    itemCount: state.contacts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          BlocProvider.of<ContactBloc>(context).add(OpenChatEvent());
                           Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatScreen(contact: state.contacts[index],usrph:state.usrph)));
                        },
                        child: ContactCard(contact:state.contacts[index],usrph:state.usrph));
                    });
                    }

                    return Center(child: CircularProgressIndicator(),);
                  },
                ),
              ))
            ]),
          ),
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
    return Container(
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
    );
  }
}
