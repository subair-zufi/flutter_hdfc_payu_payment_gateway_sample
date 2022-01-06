import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/constants.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/models/item.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/models/payment_request.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/utils/snackbar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PaymentProvider {
  final _storage = GetStorage();
  final _dio = Dio();

  Future<PaymentRequest> saveRequest(List<Item> paymentItems) async {
    try{
    print(paymentItems.length);
      /// get total of item price
    double amount = paymentItems
        .map((element) => element.price!)
        .toList()
        .reduce((a, b) => a + b);

    /// extract item ids
    List<String> itemIds = paymentItems.map((e) => e.id!).toList();

    /// generate unique transaction id
    String txnId = DateTime.now().millisecondsSinceEpoch.toString();

    /// prepare hash string value that will be encrypted
    String hashString =
        "${Constants.key}|$txnId|${double.parse(amount.toStringAsFixed(2))}|${itemIds.toString()}|${Constants.firstName}|${Constants.email}|||||||||||${Constants.salt}";
    var cksHashBytes = utf8.encode(hashString);

    /// Encrypt shash string and generate sha512 output
    var cksHash = sha512.convert(cksHashBytes);

    /// before initializing the payment we store payment request data
    /// to the database, that later, will be verified
    /// for this demo purpose, I store it in GetStorage as database
    final _requestData = PaymentRequest(
      amount: amount,
      clientData: {},
      createdAt: DateTime.now().millisecondsSinceEpoch,
      email: Constants.email,
      firstname: Constants.firstName,
      furl: Constants.furl,
      hash: cksHash.toString(),
      key: Constants.key,
      lastname: Constants.lastName,
      paymentResponse: '',
      phone: Constants.phone,
      productinfo: itemIds.toString(),
      reqUrl: Constants.reqUrl,
      resUrl: Constants.resUrl,
      salt: Constants.salt,
      status: 'abort',
      surl: Constants.surl,
      txnid: txnId,
      verResponse: '',
      verUrl: Constants.verUrl,
    );

    /// finally store it to the database
    await _storage.write(txnId, _requestData.toMap());
    return _requestData;
    }catch (e){
      rethrow;
    }
  }

  /// on init, the gateway will be redirected to generated url passing following data as params
  Uint8List paymentRequestBody(PaymentRequest request) =>
      Uint8List.fromList(utf8.encode(
        "key=${request.key}&"
        "txnid=${request.txnid}&"
        "amount=${request.amount}&"
        "productinfo=${request.productinfo}&"
        "firstname=${request.firstname}&"
        "email=${request.email}&"
        "phone=${request.phone}&"
        "lastname=${request.lastname}&"
        "surl=${request.surl}&"
        "furl=${request.furl}&"
        "hash=${request.hash}",
      ));

  convertJson(res) {
    return json.decode(res.toString());
  }

  Future updatePaymentResponse(String txnId, String res) async {
    try {
      Map? oldData = _storage.read(txnId);
      if (oldData != null) {
        oldData['paymentResponse'] = res;
        await _storage.write(txnId, oldData);
        return;
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future updateVerificationResponse(
      String txnId, String res, String status) async {
    try {
      Map? oldData = _storage.read(txnId);
      if (oldData != null) {
        oldData['verResponse'] = res;
        oldData['status'] = status;
        await _storage.write(txnId, oldData);

      print(oldData);
        return;
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future verifyPayment(String body) async {
    _dio.options.contentType = Headers.formUrlEncodedContentType;
    var req = await _dio.post(Constants.verUrl,
        data: Uri.splitQueryString(body),
        options: Options(contentType: Headers.formUrlEncodedContentType));
    return req.data;
  }





  Future handlePaymentResponse(
    InAppWebViewController ctrl,
    PaymentRequest request,
    List<Item> items,
  ) async {
    ///1. extract response content from html type text
    String paymentRes = await ctrl.evaluateJavascript(
      source: "window.document.getElementsByTagName('pre')[0].innerHTML;",
    );

    /// 2. convert response to json
    var paymentResMap = convertJson(paymentRes);

    /// 3. update payment response in the database
    updatePaymentResponse(paymentRes, request.txnid!);

    /// 4. prepare sha512 input string for [verify_payment]
    String hashString =
        "${request.key}|verify_payment|${request.txnid}|${request.salt}";
    var cksHashBytes = utf8.encode(hashString);

    /// 5. convert the input to hash digest
    var hash = sha512.convert(cksHashBytes);

    /// 6. prepare params for [verify_payment]
    String body =
        "key=${request.key}&command=verify_payment&var1=${request.txnid}&var2=&var3=&var4=&var5=&var6=&var7=&var8=&var9=&hash=$hash";

    /// 7. verify transaction
    var verRes = await verifyPayment(body);

    /// 8. extract verification details from [verRes]
    var verResMap = convertJson(verRes)['transaction_details'][request.txnid];

    /// 9. check for successful transaction
    if (paymentResMap['status'] == 'success' &&
        verResMap['status'] == 'success' &&
        verResMap['txnid'] == paymentResMap['txnid'] &&
        request.txnid == paymentResMap['txnid']) {
      /// success transaction extra verifications
      /// 1. extract first item from request and check payment response [paymentResMap] contains the same
      String firstProduct = request.productinfo!
          .split(',')[0]
          .replaceAll('[', '')
          .replaceAll(']', '');

      bool itemIdVerified =
          paymentResMap['productinfo'].toString().contains(firstProduct);

      /// 2. generate reverse sha512 hash string from both ver and payment responses
      ///    and verify the same reverse hash is sent by pg in payment response [paymentResMap]
      var reverseHash = sha512.convert(utf8.encode(
          "${request.salt}|${paymentResMap['status']}|||||||||||${request.email}|${request.firstname}|"
          "${paymentResMap['productinfo']}|${request.amount!.toStringAsFixed(2)}|${request.txnid}|${request.key}"));

      bool reverseHashVerified =
          paymentResMap['hash'] == reverseHash.toString();

      /// 3. if both [1] and [2] are true all checks passed for successful transaction
      ///
      if (itemIdVerified && reverseHashVerified) {
        await updateVerificationResponse(request.txnid!,verRes.toString(),  'success');
        loading.value = false;
        Get.back();
      }

      ///************************************** Handle filed transactions ************************************///
      else {
        /// here handles transaction that
        ///   - succeed on payment
        ///   - succeed on verification
        ///   - failed on [itemIdVerified]
        ///     or
        ///     failed on [reverseHashVerified]

        await updateVerificationResponse(request.txnid!,verRes.toString(),  'failure',);
        loading.value = false;
        Get.back();
        snackBar(
            'Payment failed due to unknown error',
            'If you have lose of money, please contact to the provider.',
            SnackBarType.error);
      }
    } else {
      /// here handles transaction that
      ///   - failed on payment
      ///     or
      ///     failed on verification
      ///

      await updateVerificationResponse(request.txnid!, verRes.toString(), 'failure',);
      loading.value = false;
      Get.back();
      snackBar(
          'Payment failed',
          'If you have lose of money, please contact to the provider.',
          SnackBarType.error);
    }
  }
}




ValueNotifier<bool> loading = ValueNotifier(false);