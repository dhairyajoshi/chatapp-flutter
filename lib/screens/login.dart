// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:chatapp/screens/otpverify.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose(); 
    phoneController.dispose();
    passwordController.dispose();
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
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'ChatApp',
                      style: TextStyle(
                          color: Color.fromARGB(255, 3, 190, 9),
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Phone number',
                        prefix: Text('+91')),
                  ),
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Get OTP'),
                      onPressed: () async {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        await auth.verifyPhoneNumber(
                            phoneNumber: '+91${phoneController.text.trim()}',
                            verificationCompleted:
                                (PhoneAuthCredential credential) async {
                              final user =
                                  await auth.signInWithCredential(credential);

                              print('signed in');
                            },
                            verificationFailed: (FirebaseAuthException e) {
                              if (e.code == 'invalid-phone-number') {
                                print(
                                    'The provided phone number is not valid.');
                              }
                              // Handle other errors
                            },
                            codeSent: (String verificationId,
                                int? resendToken) async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OtpPage(
                                          verificationId: verificationId
                                          ,ph: phoneController.text.trim(),)));
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {
                              // Auto-resolution timed out...
                            },
                            timeout: Duration(seconds: 120)); 
                      },
                    )),
              ],
            )),
      ),
    );
  }
}
