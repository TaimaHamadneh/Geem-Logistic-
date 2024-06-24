import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/pages/signin/signin_screen.dart';
import 'package:welecome_login_out/pages/signup/signup_screen.dart';
import 'package:welecome_login_out/generated/l10n.dart'; 

class WelcomeButtons extends StatelessWidget {
  const WelcomeButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SignInPage();
                },
              ),
            );
          },
          child: Text(
            S.of(context).signIn,
            style: TextStyle(fontSize: isDesktop ? 24 : 20,), 
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const SignUpPage();
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Approved.LightColor,
            elevation: 0,
          ),
          child: Text(
            S.of(context).signUp, 
            style:  TextStyle(
              color: Approved.TextColor,
              fontFamily: 'Montserrat',
              fontSize: isDesktop ? 24 : 20,
            ),
          ),
        ),
      ],
    );
  }
}
