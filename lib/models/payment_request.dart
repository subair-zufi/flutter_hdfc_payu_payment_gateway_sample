class PaymentRequest {
  String? key;
  String? txnid;
  double? amount;
  String? productinfo;
  String? firstname;
  String? email;
  String? phone;
  String? lastname;
  String? surl;
  String? furl;
  String? hash;
  String? status;
  String? salt;
  String? reqUrl;
  String? verUrl;
  String? resUrl;
  String? paymentResponse;
  String? verResponse;
  int? createdAt;
  Map? clientData;

  PaymentRequest({
    this.key,
    this.txnid,
    this.amount,
    this.productinfo,
    this.firstname,
    this.email,
    this.phone,
    this.lastname,
    this.surl,
    this.furl,
    this.hash,
    this.status,
    this.salt,
    this.reqUrl,
    this.verUrl,
    this.resUrl,
    this.paymentResponse,
    this.verResponse,
    this.createdAt,
    this.clientData,
  });

  

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'txnid': txnid,
      'amount': amount,
      'productinfo': productinfo,
      'firstname': firstname,
      'email': email,
      'phone': phone,
      'lastname': lastname,
      'surl': surl,
      'furl': furl,
      'hash': hash,
      'status': status,
      'salt': salt,
      'reqUrl': reqUrl,
      'verUrl': verUrl,
      'resUrl': resUrl,
      'paymentResponse': paymentResponse,
      'verResponse': verResponse,
      'createdAt': createdAt,
      'clientData': clientData,
    };
  }

  factory PaymentRequest.fromMap(Map<String, dynamic> map) {
    return PaymentRequest(
      key: map['key'],
      txnid: map['txnid'],
      amount: map['amount']?.toDouble(),
      productinfo: map['productinfo'],
      firstname: map['firstname'],
      email: map['email'],
      phone: map['phone'],
      lastname: map['lastname'],
      surl: map['surl'],
      furl: map['furl'],
      hash: map['hash'],
      status: map['status'],
      salt: map['salt'],
      reqUrl: map['reqUrl'],
      verUrl: map['verUrl'],
      resUrl: map['resUrl'],
      paymentResponse: map['paymentResponse'],
      verResponse: map['verResponse'],
      createdAt: map['createdAt']?.toInt(),
      clientData: map['clientData'],
    );
  }
}
