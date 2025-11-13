import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:flutter/material.dart';

class SingleMGAppBar extends AppBar {
  final String apptitle;
  final bool isTitleCentered;
  final bool showActions;

  SingleMGAppBar(
    this.apptitle, {
    this.isTitleCentered = true,
    this.showActions = true,
    List<Widget>? actions,
    required BuildContext context,
    super.key,
  }) : super(
         backgroundColor: richBrown,
         elevation: 0,
         titleSpacing: 0,
         automaticallyImplyLeading: false,
         centerTitle: isTitleCentered,
         title: Row(
           children: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: IconContainer(
                 icon: Icons.arrow_back,
                 backgroundColor: softCream,
                 iconColor: richBrown,
                 onTap: () {
                   NavigationUtil.pop(context);
                 },
               ),
             ),
             Expanded(
               child: Text(
                 apptitle,
                 style: const TextStyle(
                   color: softCream,
                   fontSize: 18,
                   fontWeight: FontWeight.w700,
                 ),
               ),
             ),
           ],
         ),

         actions: showActions ? actions : null,
       );
}
