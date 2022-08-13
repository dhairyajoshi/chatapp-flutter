import 'package:objectbox/objectbox.dart';

@Entity()
class ContactModel{
  int id;
  String number;
  String name;
  String pfp;

  ContactModel(this.number,this.name,this.pfp,{this.id=0});

  factory ContactModel.fromJson(Map<String,dynamic> json){
    return ContactModel(json['number'], json['name'], json['pfp']);
  }

  Map<String,dynamic> toJson(){
    return {
      'phoneNo':number,
      'pfp':pfp,
      'name':name
    };
  }
}