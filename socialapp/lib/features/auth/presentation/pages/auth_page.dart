/*

Auth page - This page determines whether to show the login or register page

*/

import 'package:flutter/material.dart';
import 'package:socialapp/features/auth/presentation/pages/login_page.dart';
import 'package:socialapp/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Inicialmente mostra a página de login
  bool showLoginPage = true;

  // Alterna entre as páginas de login e registro
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        togglePages: togglePages,
      );
    }else{
      return RegisterPage(
        togglePages: togglePages,
      );
    }
  }
}
