import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import '../../../approved.dart';
import 'package:welecome_login_out/generated/l10n.dart'; 

class SignUpDesign extends StatelessWidget {
  const SignUpDesign({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        SkeletonAnimation(
          child: Text(
            S.of(context).signupMsg,
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              color: Approved.TextColor,
              fontSize:  isDesktop ? 40 : 24,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
       /* Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 1,
              child: Image.asset("assets/images/signup.png"),
            ),
            const Spacer(),
          ],
        ),*/
        const SizedBox(height: Approved.defaultPadding*2),
        
      ],
    );
  }
}
