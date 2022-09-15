import 'package:bvvm/bvvm.dart';
import 'package:flutter/material.dart';

class StoreFrontPage extends StatefulWidget {

  static const String route = "store_front";

  const StoreFrontPage({Key? key}) : super(key: key);

  @override
  State<StoreFrontPage> createState() => _StoreFrontPageState();
}

class _StoreFrontPageState extends BVVMState<StoreFrontPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }

}
