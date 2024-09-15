import 'package:flutter/material.dart';
import 'package:firebase_setup/auth/authform.dart';
import '/screens/appbar.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //widget chính
      appBar: CustomAppBar(
        appName: 'TO DO APP',
        slogan: 'All in one!',
      ),
      body: Center(child: AuthForm()), // Đưa Form vào giữa màn hình
    );
  }
}
