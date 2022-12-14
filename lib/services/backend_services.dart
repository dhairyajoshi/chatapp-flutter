import 'package:contacts_service/contacts_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:intl/intl.dart';
import '../objectbox.g.dart';

class BackendService {
  String baseUrl = 'https://whatsapp-backnd.herokuapp.com';
  static final BackendService _backendService = BackendService._internal();
  late Socket socket;
  late Store store;
  late SharedPreferences pref;

  factory BackendService() {
    return _backendService;
  }

  BackendService._internal();

  Socket initSocket() {
    socket = io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    return socket;
  }

  disconnectSocket() {
    socket.disconnect();
  }

  sendMessage(String rec, String msg) async {

    final pref = await SharedPreferences.getInstance();
    String sen = pref.getString('phoneNo')!;
    String token = pref.getString('token')!;
    String time = DateFormat('HH:mm').format(DateTime.now()).toString();
    http.post(Uri.parse('$baseUrl/messages/send'),
        body: {'receiver': rec, 'sender': sen, 'message': msg, 'time': time},
        headers: {'Authorization': 'Bearer $token'});

  }

  Future<List<Map<String, dynamic>>> getMessages(String c2) async {
    final pref = await SharedPreferences.getInstance();
    String c1 = pref.getString('phoneNo')!;
    String token = pref.getString('token')!;
    List<Map<String, dynamic>> data=[];

    final response = await http.post(Uri.parse('$baseUrl/messages/get'),
        body: {'c1': c1, 'c2': c2},
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final tdata = json.decode(response.body);
      for(int i=0;i<tdata.length;i++)
      data.add(tdata[i]);

      return data;
    }

    return [];
  }

  closeStore(){
    store.close();
  }

  Future<List<Map<String, dynamic>>> getUsers(List<String> contacts) async {
    
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('token');
    final response = await http.post(Uri.parse('$baseUrl/user/get'),
        headers: {'Authorization': 'Bearer $token','content-type': 'application/json'},body: jsonEncode({'users':contacts}));
    List<Map<String,dynamic>> data=[];
    if (response.statusCode == 200) {
        final tdata=json.decode(response.body);
        
        for (int i = 0; i < tdata.length; i++) {
          final Iterable<Contact> contacts = await ContactsService.getContacts();
        for (int j = 0; j < contacts.length; j++) {
            List phones=contacts.elementAt(j).phones!.toList();
            if(phones.isEmpty) {
              continue;
            }
            String contact = phones.first.value.toString();
            if (contact == null) {
              continue;
            }

            contact=contact.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
            if(contact.length<10) {
              continue;
            }
            
            contact = contact
                .split("")
                .reversed
                .join("")
                .substring(0, 10)
                .split("")
                .reversed
                .join("")
                .toString();
            if(contact==tdata[i]['phoneNo']) {
              tdata[i]['name']=contacts.elementAt(j).displayName;
            }
          }
          data.add(tdata[i]);
        }
        return data;
      }
    
    return [];
  }

  Future<bool> loginUser(String name, String ph) async {
    final response = await http
        .post(Uri.parse('$baseUrl/user'), body: {'name': name, 'phoneNo': ph});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pref = await SharedPreferences.getInstance();
      await pref.setString('token', data['token']);
      await pref.setString('phoneNo', ph);
      // socket.emit('refresh');
      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>> checkLogin() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('token');
    final usrph = pref.getString('phoneNo');

    if (token != null) {
      return {'status': true, 'usrph': usrph};
    }

    return {'status': false};
  }
}
