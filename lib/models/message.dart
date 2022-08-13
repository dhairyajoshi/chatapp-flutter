import 'package:objectbox/objectbox.dart';

@Entity()
class MessageModel{
  int id;
  String contact;
  String message;
  String time;
  String sentBy;

  MessageModel(this.contact,this.message,this.time,this.sentBy,{this.id=0});

  factory MessageModel.fromJson(Map<String,dynamic> json){
    return MessageModel(json['contact'], json['message'], json['time'], json['sentBy']);
  }
  
  Map<String,dynamic> toJson(){
    return {
      'message':message,
      "sender":sentBy,
      'time':time
    };
  }
}