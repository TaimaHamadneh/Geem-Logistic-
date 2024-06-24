import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/reset_code/component/reset_code_form.dart';
import 'package:welecome_login_out/pages/reset_code/component/reset_code_img.dart';
import 'package:welecome_login_out/responsive.dart';

class ResetCodePage extends StatelessWidget {
  final String email;
  final String userId;

  ResetCodePage({
    Key? key,
    required this.email,
    required this.userId,
  }) : super(key: key);

  final List<TextEditingController> _codeControllers =
      List.generate(6, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Responsive(
          mobile: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Approved.defaultPadding),
              ResetCodeImage(),
              SizedBox(height: Approved.defaultPadding),
              ResetCodeForm(
                codeControllers: _codeControllers,
                email: email,
                userId: userId,
              ),
            ],
          ),
          desktop: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).VerificationCode,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Approved.TextColor,
                  fontSize: 40.0,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: Approved.defaultPadding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: Approved.defaultPadding ),
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/Secure-login.png',
                    ),
                  ),
                  const SizedBox(width: Approved.defaultPadding ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Approved.defaultPadding),
                      child: ResetCodeForm(
                        codeControllers: _codeControllers,
                        email: email,
                        userId: userId,
                      ),
                    ),
                  ),
                  const SizedBox(width: Approved.defaultPadding ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
