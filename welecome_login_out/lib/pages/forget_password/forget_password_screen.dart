import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/pages/forget_password/component/forget_form_screen.dart';
import 'package:welecome_login_out/pages/forget_password/component/forget_img_screen.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userId;

  const ResetPasswordPage({
    required this.userId,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              width: constraints.maxWidth, // Adjusts width based on available space
              child: Padding(
                padding: const EdgeInsets.all(Approved.defaultPadding / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResetPasswordImage(),
                    SizedBox(height: 20),
                    ForgetPasswordForm(
                      userId: widget.userId,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
