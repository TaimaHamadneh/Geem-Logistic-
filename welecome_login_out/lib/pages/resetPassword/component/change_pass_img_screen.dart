// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';

class ChangePasswordImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        const SizedBox(height: Approved.defaultPadding * 2),
        SkeletonAnimation(
          child: Text(
            S.of(context).ConfirmPassword,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Approved.TextColor,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        const SizedBox(height: Approved.defaultPadding),
        Text(
          S.of(context).ResetMsg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Approved.TextColor,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        Image.asset(
          'assets/images/reset.png',
          height: 250,
          width: 250,
        ),
      ],
    );
  }
}
