import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart'; // Import your generated localization file
import 'package:flutter/material.dart';

class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final Function? press;
  const AlreadyHaveAnAccountCheck({
    Key? key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? S.of(context).NoAccount : S.of(context).HaveAccount,
          style:  TextStyle(
            color: Approved.PrimaryColor,
          fontSize: isDesktop ? 20 : 16,
          
          ),
        ),
        GestureDetector(
          onTap: press as void Function()?,
          child: Text(
            login ? S.of(context).signUp : S.of(context).signIn,
            style:  TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 20 : 16,
            ),
          ),
        )
      ],
    );
  }
}
