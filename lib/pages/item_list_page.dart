import 'package:flutter/material.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/constants.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/models/item.dart';
import 'package:flutter_hdfc_payu_payment_gateway_sample/pages/gateway_page.dart';
import 'package:get/get.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({Key? key}) : super(key: key);

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  /// selected items is stored in
  List<Item> paymentItems = [];
  double get paymentTotal => paymentItems
      .map((element) => element.price!)
      .toList()
      .reduce((a, b) => a + b);

  ///TODO: create a file Constants.dart and add list of item with [Item]
  ///like:
  ///
  ///static List<Item> dummyItems = [
  ///   Item(id: 'id1',title: 'Item 1',price: 1200.0),
  ///   Item(id: 'id2',title: 'Item 2',price: 765.0),
  ///   Item(id: 'id3',title: 'Item 3',price: 3499.0),
  ///   Item(id: 'id4',title: 'Item 4',price: 240.0),
  ///   Item(id: 'id5',title: 'Item 5',price: 12300.0),
  ///   Item(id: 'id6',title: 'Item 6',price: 12.0),
  ///   Item(id: 'id7',title: 'Item 7',price: 11.0),
  ///   Item(id: 'id8',title: 'Item 8',price: 500.0),
  /// ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
      ),
      floatingActionButton: paymentItems.isEmpty
          ? const SizedBox()
          : FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => GatewayPage(items: paymentItems));
              },
              icon: const Icon(Icons.payment),
              label: Text('Pay ${paymentTotal.toStringAsFixed(2)}'),
            ),
      body: ListView.separated(
          itemBuilder: (_, index) {
            Item item = Constants.dummyItems[index];
            return CheckboxListTile(
              value: paymentItems.contains(item),
              onChanged: (bool? selected) {
                /// udpate [paymentItems]
                if (selected!) {
                  paymentItems.add(item);
                } else {
                  paymentItems.remove(item);
                }

                /// update ui according to [paymentItems]
                setState(() {});
              },
              title: Text(item.title!),
              subtitle: Text(item.price!.toStringAsFixed(2)),
            );
          },
          separatorBuilder: (_, index) {
            return const Divider();
          },
          itemCount: Constants.dummyItems.length),
    );
  }
}
