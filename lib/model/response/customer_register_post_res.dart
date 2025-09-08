import 'dart:convert';

CustommerRegisterPostRes custommerRegisterPostResFromJson(String str) =>
    CustommerRegisterPostRes.fromJson(json.decode(str));

String custommerRegisterPostResToJson(CustommerRegisterPostRes data) =>
    json.encode(data.toJson());

class CustommerRegisterPostRes {
  String message;
  int id;

  CustommerRegisterPostRes({required this.message, required this.id});

  factory CustommerRegisterPostRes.fromJson(Map<String, dynamic> json) =>
      CustommerRegisterPostRes(message: json["message"], id: json["id"]);
  Map<String, dynamic> toJson() => {"message": message, "id": id};
}
