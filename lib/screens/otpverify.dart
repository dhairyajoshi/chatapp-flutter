// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:chatapp/screens/contacts.dart';
import 'package:chatapp/services/backend_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpPage extends StatefulWidget {
  String ph;
  String verificationId;
  String otp;
  OtpPage({Key? key, required this.verificationId,required this.ph,this.otp=''}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  TextEditingController otpController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    otpController.text=widget.otp;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter name',
                    
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter OTP',
                      
                  ),
                  
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: const Text('Verify'),
                    onPressed: () async {
                      try {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        final AuthCredential credential =
                            PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: otpController.text,
                        );

                        final User? user =
                            (await auth.signInWithCredential(credential)).user;

                        if (user != null) {
                          if(await BackendService().loginUser(nameController.text.trim(),widget.ph)) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactsPage()),
                              (Route<dynamic> route) => false);
                          }
                          else{
                            throw('Some error occured');
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }, 
                  )),
            ],
          )),
    ));
  }
}
