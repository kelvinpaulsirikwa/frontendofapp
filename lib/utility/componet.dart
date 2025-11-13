
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';

class KivuliAppBar extends AppBar {
  KivuliAppBar({super.key})
    : super(
        leading: null,
        toolbarHeight: 0,
        elevation: 10,
        backgroundColor: MyColors.primaryColor.withValues(alpha: 0.6),
      );
}

