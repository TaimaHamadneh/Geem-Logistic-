import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart'; 

class WelcomeDesign extends StatefulWidget {
  const WelcomeDesign({
    Key? key,
  }) : super(key: key);

  @override
  _WelcomeDesignState createState() => _WelcomeDesignState();
}

class _WelcomeDesignState extends State<WelcomeDesign> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        SkeletonAnimation(
          child: Text(
            S.of(context).welcomeMessage,
           style:  TextStyle(
              fontWeight: FontWeight.bold,
              color: Approved.TextColor,
              fontFamily: 'Montserrat',
              fontSize: isDesktop ? 26 : 24,
            ),
             textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Approved.defaultPadding * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset(
                "assets/images/MainPage.png",
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: Approved.defaultPadding * 2),
      ],
    );
  }
}
