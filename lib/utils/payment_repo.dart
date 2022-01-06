import 'dart:typed_data';

import 'package:flutter_hdfc_payu_payment_gateway_sample/models/item.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/models/payment_request.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/utils/payment_provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentRepo {
  final _provider = PaymentProvider();
  Future<PaymentRequest> saveRequestData(List<Item> products) =>
      _provider.saveRequest(products);

  Uint8List paymentRequestBody(PaymentRequest request) =>
      _provider.paymentRequestBody(request);

  Future handlePaymentResponse(
    InAppWebViewController ctrl,
    PaymentRequest request,
    List<Item> products,
  ) =>
      _provider.handlePaymentResponse(ctrl, request, products);
}
