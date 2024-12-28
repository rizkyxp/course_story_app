import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/ui/login_screen.dart';
import 'package:story_app/util/colors.dart';

final _formkey = GlobalKey<FormState>();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void dispose() {
    _controllerUsername.dispose();
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
                        'Create Account',
                        style: TextStyle(fontSize: 36),
                      ),
                      const SizedBox(
                        height: 110,
                      ),
                      TextFormField(
                        controller: _controllerUsername,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a name to sign up';
                          } else {
                            return null;
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Name'),
                      ),
                      const SizedBox(
                        height: 15,
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
                        autovalidateMode: AutovalidateMode.onUnfocus,
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
                          } else if (value.length < 8) {
                            return 'must be at least 8 characters';
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
                        child: Consumer<RegisterProvider>(
                          builder: (context, value, child) {
                            return ElevatedButton(
                              onPressed: !value.isLoading
                                  ? () async {
                                      if (_formkey.currentState!.validate()) {
                                        await value.registerAccount(
                                            _controllerUsername.text, _controllerEmail.text, _controllerPassword.text);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            if (value.state == AuthState.error) {
                                              return AlertDialog(
                                                title: const Text('Registration Failed'),
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
                                            } else {
                                              return AlertDialog(
                                                title: const Text('Registration Success'),
                                                content: Text(value.response.message),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      context.pop();
                                                      context.goNamed('login');
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        );
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
                              child:
                                  !value.isLoading ? const Text('Create Account') : const CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 150,
                      ),
                      const Center(
                        child: Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            context.goNamed('login');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
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
