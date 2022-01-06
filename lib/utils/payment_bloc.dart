import 'package:flutter_hdfc_payu_payment_gateway_sample/utils/payment_repo.dart';

import 'dart:typed_data';

import 'package:flutter_hdfc_payu_payment_gateway_sample/models/item.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/models/payment_request.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentBloc {
  final _repo = PaymentRepo();

  Future<PaymentRequest> saveRequestData(List<Item> products) =>
      _repo.saveRequestData(products);

  Uint8List paymentRequestBody(PaymentRequest request) =>
      _repo.paymentRequestBody(request);

  Future handlePaymentResponse(InAppWebViewController ctrl,
          PaymentRequest request, List<Item> products) =>
      _repo.handlePaymentResponse(ctrl, request, products);
}
