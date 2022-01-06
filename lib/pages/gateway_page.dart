import 'package:flutter/material.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/models/item.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/models/payment_request.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/utils/payment_bloc.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/utils/payment_provider.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/utils/snackbar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class GatewayPage extends StatelessWidget {
  const GatewayPage({Key? key, required this.items}) : super(key: key);

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    var bloc = PaymentBloc();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: Get.size.width,
              child: FutureBuilder<PaymentRequest>(
                  future: bloc.saveRequestData(items),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'init',
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                    PaymentRequest req = snapshot.data!;
                    return InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: Uri.parse(req.reqUrl!),
                        method: 'POST',
                        body: bloc.paymentRequestBody(req),
                        headers: {
                          'Content-Type': 'application/x-www-form-urlencoded'
                        },
                      ),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          preferredContentMode: UserPreferredContentMode.MOBILE,
                        ),
                      ),
                      onLoadHttpError: (ctrl, uri, status, err) {
                        snackBar('Error status: $status', err.toString(),
                            SnackBarType.error);
                      },
                      onConsoleMessage: (_, msg) {
                        print('console: ${msg.message}');
                      },
                      onLoadStart: (ctrl, uri) {
                        loading.value = true;
                      },
                      onLoadStop: (ctrl, uri) async {
                        if (uri.toString() == req.surl) {
                          /// user events finished. Now start handling responses from the gateway

                          bloc.handlePaymentResponse(ctrl, req, items);
                        } else {
                          /// hide loader for user events
                          loading.value = false;
                        }
                      },
                    );
                  }),
            ),
            ValueListenableBuilder<bool>(
                valueListenable: loading,
                builder: (context, loading, child) {
                  print('loading $loading');
                  return loading
                      ? Positioned(
                          child: Container(
                          width: Get.size.width,
                          height: Get.size.height,
                          color: Colors.white,
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ))
                      : const SizedBox();
                }),
          ],
        ),
      ),
    );
  }
}
