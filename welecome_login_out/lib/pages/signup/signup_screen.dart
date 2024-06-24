import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import '../../../responsive.dart';
import 'components/signup_image_screen.dart';
import 'components/signup_form_screen.dart';



class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body:  SingleChildScrollView(
        child: Responsive(
          mobile: MobileSignUpPage(),
          desktop: Column(
            children: [ 
              Text(
            S.of(context).signupMsg,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Approved.TextColor,
              fontSize: 40.0,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: Approved.defaultPadding * 2,),
              Row(

            children: [
              Expanded(
              flex: 1,
              child: Image.asset("assets/images/signup.png"),
            ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 600,
                      child: Column(children: [ 
                        SizedBox(height: Approved.defaultPadding ),
                        SignUpForm(),
                      ],)
                    ),
                    SizedBox(height: Approved.defaultPadding / 2),
                    // SocalSignUp()
                  ],
                ),
              )
            ],
          ),
            ],
          )
        ),
      ),
    );
  }
}

class MobileSignUpPage extends StatelessWidget {
  const MobileSignUpPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpDesign(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer(),
          ],
        ),
        // const SocalSignUp()
      ],
    );
  }
}
