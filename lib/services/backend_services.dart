import 'package:chatapp/environment.dart';
import 'package:chatapp/models/contact.dart';
import 'package:chatapp/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:intl/intl.dart';
import 'package:chatapp/objectbox.g.dart';

class BackendService {
  String baseUrl = Variables.baseUrl;
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

  sendMessage(Socket socket, String rec, String msg) async {
    if (!store.isClosed()) {
      store.close();
    }
    final pref = await SharedPreferences.getInstance();
    String sen = pref.getString('phoneNo')!;
    String token = pref.getString('token')!;
    String time = DateFormat('HH:mm').format(DateTime.now()).toString();
    socket.emit(
        'message', {'message': msg, 'rec': rec, 'sen': sen, 'time': time});
    http.post(Uri.parse('$baseUrl/messages/send'),
        body: {'receiver': rec, 'sender': sen, 'message': msg, 'time': time},
        headers: {'Authorization': 'Bearer $token'});
    socket.emit('refresh', {
      'rec': rec,
      'sen': sen,
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String c2) async* {
    store = await openStore();
    final messagebox = store.box<MessageModel>();
    List<MessageModel> messages =
        messagebox.query(MessageModel_.contact.equals(c2)).build().find();
    final pref = await SharedPreferences.getInstance();
    String c1 = pref.getString('phoneNo')!;
    String token = pref.getString('token')!;
    List<Map<String, dynamic>> data = [];
    for (int i = 0; i < messages.length; i++) {
      data.add(messages[i].toJson());
    }

    yield data;

    final response = await http.post(Uri.parse('$baseUrl/messages/get'),
        body: {'c1': c1, 'c2': c2},
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode >= 400) {
      yield data;
    } else if (response.statusCode == 200) {
      final tdata = json.decode(response.body);
      if (tdata.length != data.length) {
        for (int i = 0; i < messages.length; i++) {
          messagebox.remove(messages[i].id);
        }
        data = [];
        for (int i = 0; i < tdata.length; i++) {
          data.add(tdata[i]);
          messagebox.put(MessageModel(
              c2, tdata[i]['message'], tdata[i]['time'], tdata[i]['sender']));
        }
        yield data;
      }
    } else {
      yield [];
    }
    store.close();
  }

  closeStore() {
    store.close();
  }

  getUsers() async* {
    store = await openStore();
    final contactbox = store.box<ContactModel>();
    List<ContactModel> contacts = contactbox.getAll();
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < contacts.length; i++) {
      data.add(contacts[i].toJson());
    }
    yield data;

    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('token');
    final response = await http.get(Uri.parse('$baseUrl/user'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final tdata = json.decode(response.body);
      if (tdata.length != data.length) {
        for (int i = 0; i < contacts.length; i++) {
          contactbox.remove(contacts[i].id);
        }
        data = [];
        for (int i = 0; i < tdata.length; i++) {
          data.add(tdata[i]);
          contactbox.put(ContactModel(tdata['phoneNo'], tdata['name'], ''));
        }
        yield data;
      }
    }

    yield <Map<String, dynamic>>[];
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
