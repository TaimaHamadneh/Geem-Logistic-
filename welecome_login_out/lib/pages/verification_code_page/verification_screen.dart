import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/responsive.dart';
import 'package:welecome_login_out/pages/verification_code_page/component/verification_form_screen.dart';
import 'package:welecome_login_out/pages/verification_code_page/component/verification_image_screen.dart';

class VerificationCodePage extends StatelessWidget {
  final String code;
  VerificationCodePage({
    Key? key,
    required this.code,
  }) : super(key: key);

  final List<TextEditingController> _codeControllers =
      List.generate(6, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Responsive(
          mobile: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: Approved.defaultPadding),
              VerificationImage(),
              const SizedBox(height: Approved.defaultPadding),
              VerificationForm(codeControllers: _codeControllers, email: code),
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
                  const SizedBox(width: Approved.defaultPadding),
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/Secure-login.png',
                    ),
                  ),
                  const SizedBox(width: Approved.defaultPadding),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Approved.defaultPadding),
                      child: VerificationForm(
                          codeControllers: _codeControllers, email: code),
                    ),
                  ),
                  const SizedBox(width: Approved.defaultPadding),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
