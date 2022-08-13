// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:chatapp/screens/chatscreen.dart';
import 'package:chatapp/screens/contacts.dart';
import 'package:chatapp/screens/login.dart';
import 'package:chatapp/screens/otpverify.dart';
import 'package:chatapp/services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: BackendService().checkLogin(),
        builder:(context,AsyncSnapshot snap){
          if(snap.hasData){
            if(snap.data['status']==true){
              return ContactsPage(usrph: snap.data['usrph']);
            }
            return LoginPage();
          }
          return Center(child: CircularProgressIndicator(),);
        } ,
      ));
  }
}
