// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';

class ResetPasswordImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     final isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SkeletonAnimation(
          child: Text(
            S.of(context).ResetPassword,
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              color: Approved.TextColor,
               fontSize: isDesktop ? 24 : 20,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        Image.asset(
          'assets/images/Forgot-password.png',
          height: isDesktop ? 350 : 250,
          width: isDesktop ? 350 : 250,
        ),
      ],
    );
  }
}
