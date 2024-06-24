import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import '../components/background.dart';
import '../responsive.dart';
import 'components/welcome_form_screen.dart';
import 'components/welcome_image_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Responsive(
            desktop: desktopWelcomePage(),
            mobile: MobileWelcomePage(),
          ),
        ),
      ),
    );
  }
}

class MobileWelcomePage extends StatelessWidget {
  const MobileWelcomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const WelcomeDesign(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: WelcomeButtons(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}



class desktopWelcomePage extends StatelessWidget {
  const desktopWelcomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: Approved.defaultPadding * 6),
        Text(
          S.of(context).welcomeMessage,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Approved.TextColor,
            fontFamily: 'Montserrat',
            fontSize: 40,
          ),
          textAlign: TextAlign.center,
        ),
     //   const SizedBox(height: Approved.defaultPadding * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Image.asset(
                "assets/images/MainPage.png",
              ),
            ),
            const SizedBox(width: Approved.defaultPadding * 2),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  SizedBox(
                    width: 600, 
                    child: WelcomeButtons(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Approved.defaultPadding * 2),
          ],
        ),
      ],
    );
  }
}