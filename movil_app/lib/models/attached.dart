import 'dart:convert';

Attached attachedFromJson(String str) => Attached.fromJson(json.decode(str));

String attachedToJson(Attached data) => json.encode(data.toJson());

class Attached {
  String name;
  String mime;
  String data;

  Attached({
    required this.name,
    required this.mime,
    required this.data,
  });

  factory Attached.fromJson(Map<String, dynamic> json) => Attached(
    name: json["name"],
    mime: json["mime"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "mime": mime,
    "data": data,
  };
}
