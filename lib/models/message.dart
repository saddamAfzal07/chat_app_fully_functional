class Message {
  String? toId;
  String? formId;
  String? msg;
  String? read;

  String? sent;
  Type? type;

  Message({
    this.toId,
    this.formId,
    this.msg,
    this.read,
    this.type,
    this.sent,
  });

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    formId = json['formId'].toString();
    ;
    msg = json['msg'].toString();
    ;
    read = json['read'].toString();
    ;
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
    ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['toId'] = this.toId;
    data['formId'] = this.formId;
    data['msg'] = this.msg;
    data['read'] = this.read;
    data['type'] = this.type!.name;
    data['sent'] = this.sent;
    return data;
  }
}

enum Type { text, image }
