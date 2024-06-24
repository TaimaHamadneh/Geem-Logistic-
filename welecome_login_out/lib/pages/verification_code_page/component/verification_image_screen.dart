import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';

class VerificationImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: Approved.defaultPadding),
        SkeletonAnimation(
          child: Text(
            S.of(context).VerificationCode,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Approved.TextColor,
              fontSize: 24.0,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        Image.asset(
          'assets/images/Secure-login.png',
          height: 250,
          width: 250,
        ),
      ],
    );
  }
}
