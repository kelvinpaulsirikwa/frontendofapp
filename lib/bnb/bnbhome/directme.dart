import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:flutter/material.dart';

class DirectMe extends StatefulWidget {
  final String latitude;
  final String longtude;
  const DirectMe({super.key, required this.latitude, required this.longtude});

  @override
  State<DirectMe> createState() => _DirectMeState();
}

class _DirectMeState extends State<DirectMe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: SingleMGAppBar("Direct Me", context: context));
  }
}
