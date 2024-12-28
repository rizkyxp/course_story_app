import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/util/colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 70,
            ),
            Image.asset(
              'assets/welcome_screen_image.png',
              width: MediaQuery.of(context).size.width - 100,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Hello',
              style: TextStyle(fontSize: 36),
            ),
            const Opacity(
              opacity: 0.5,
              child: Text(
                'Welcome to Story App, where\nyou will see various stories',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () {
                  context.goNamed('login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () {
                  context.goNamed('register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
