import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';

class SignInImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: Approved.defaultPadding * 2,
        ),
        SkeletonAnimation(
          child: Text(
            S.of(context).signIn,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Approved.TextColor,
              fontSize: 24.0,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        Image.asset(
          'assets/images/Login.png',
          height: 250,
          width: 250,
        ),
     //   const SizedBox(height: Approved.defaultPadding),
      ],
    );
  }
}
