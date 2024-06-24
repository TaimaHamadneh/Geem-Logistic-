import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/signin/component/signin_form_screen.dart';
import 'package:welecome_login_out/pages/signin/component/signin_img_screen.dart';
import 'package:welecome_login_out/responsive.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Responsive(
            mobile: Column(
              children: [
                const SizedBox(height: Approved.defaultPadding),
                SignInImage(),
                const SizedBox(height: Approved.defaultPadding),
                SignInForm(
                  emailController: emailController,
                  passwordController: passwordController,
                ),
              ],
            ),
            desktop: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: Approved.defaultPadding * 3,
                ),
                Text(
                  S.of(context).signIn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor,
                    fontSize: 40,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(
                  height: Approved.defaultPadding * 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const SizedBox(width: Approved.defaultPadding * 2),
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        'assets/images/Login.png',
                      ),
                    ),
                    const SizedBox(width: Approved.defaultPadding * 2),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 600,
                            child: SignInForm(
                              emailController: emailController,
                              passwordController: passwordController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
