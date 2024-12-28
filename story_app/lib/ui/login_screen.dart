import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/util/colors.dart';

final _formkey = GlobalKey<FormState>();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: [
              ClipPath(
                clipper: TopClipper(),
                child: Container(color: secondaryColor, height: 250, width: MediaQuery.of(context).size.width),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 90,
                      ),
                      const Text(
                        'Login',
                        style: TextStyle(fontSize: 36),
                      ),
                      const SizedBox(
                        height: 110,
                      ),
                      TextFormField(
                        controller: _controllerEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Email Address'),
                        validator: (value) {
                          String pattern =
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+(.[a-zA-Z]+)?$";
                          RegExp regExp = RegExp(pattern);
                          if (!regExp.hasMatch(value!)) {
                            return 'Enter a valid email';
                          } else {
                            return null;
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUnfocus,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _controllerPassword,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a password to sign up';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Consumer<LoginProvider>(
                            builder: (context, value, child) {
                              return ElevatedButton(
                                onPressed: !value.isLoading
                                    ? () async {
                                        if (_formkey.currentState!.validate()) {
                                          await value.loginAccount(_controllerEmail.text, _controllerPassword.text);
                                          if (value.state == AuthState.error) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text('Login Failed'),
                                                  content: Text(value.meesage),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        context.pop();
                                                      },
                                                      child: const Text('Close'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                                            await prefs.setString('token', value.response.loginResult.token);
                                            context.goNamed('story');
                                          }
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: !value.isLoading ? const Text('Login') : const CircularProgressIndicator(),
                              );
                            },
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 180,
                      ),
                      const Center(
                        child: Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            context.goNamed('register');
                          },
                          child: Text(
                            'Create account',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();

    path.lineTo(0, h * 0.6);
    path.quadraticBezierTo(w * 0.25, h * 0.8, w * 0.5, h * 0.75);
    path.quadraticBezierTo(w * 0.75, h * 0.70, w, h);
    path.lineTo(w, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
