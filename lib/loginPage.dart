import 'package:flutter/material.dart';
import 'userData.dart';
import 'homePage.dart';

class LoginScreen extends StatelessWidget {
  final int boolMode;

  const LoginScreen({Key? key, required this.boolMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = boolMode == 1 ? myBlue : myRed;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Acolyte !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            LoginButton(
              text: 'Sign in with Google',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Facebook',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Twitter',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Email',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Apple',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () => _navigateToPlaceholder(context, boolMode),
              child: const Text(
                "Don't have an account? Sign up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToPlaceholder(BuildContext context, int boolMode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomePage(boolMode: boolMode),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const LoginButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        minimumSize: const Size(280, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(text),
    );
  }
}

