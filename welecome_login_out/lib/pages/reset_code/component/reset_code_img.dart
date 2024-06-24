import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';

class ResetCodeImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600; // Adjust threshold as needed

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: Approved.defaultPadding),
        SkeletonAnimation(
          child: Text(
            S.of(context).VerificationCode,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Approved.TextColor,
              fontSize: isDesktop ? 32.0 : 24.0, // Increase font size for desktop
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
