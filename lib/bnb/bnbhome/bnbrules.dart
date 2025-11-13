import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:flutter/material.dart';

class BnBRules extends StatefulWidget {
  final int motelid;
  final SimpleMotel moteldetails;
  const BnBRules({
    super.key,
    required this.motelid,
    required this.moteldetails,
  });

  @override
  State<BnBRules> createState() => _BnBRulesState();
}

class _BnBRulesState extends State<BnBRules> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SingleMGAppBar("Rule of the House", context: context),
    );
  }
}
 