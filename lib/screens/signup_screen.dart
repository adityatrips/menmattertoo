import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/screens/login_screen.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:men_matter_too/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  LoignScreenState createState() => LoignScreenState();
}

class LoignScreenState extends State<SignupScreen> {
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> signInUser() async {
    log("Form Valid?: ${_formKey.currentState!.validate()}");
    if (_formKey.currentState!.validate()) {
      String? response = await AuthMethods().signUpUser(
        bio: bioController.text,
        email: emailController.text,
        name: nameController.text,
        password: passwordController.text,
        role: "USER",
        username: usernameController.text,
      );

      if (response == "success") {
        showSnackbar(
          context,
          "Thank you for showing support. Welcome aboard!",
        );
        return;
      }

      showSnackbar(
        context,
        response,
        type: TypeOfSnackbar.error,
      );
    } else {}
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            width: double.infinity,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  SvgPicture.asset(
                    'assets/logo_extended.svg',
                    // ignore: deprecated_member_use
                    color: Theme.of(context).colorScheme.primary,
                    height: 100,
                    width: double.infinity,
                    placeholderBuilder: (context) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFieldInput(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your name";
                            }
                            return null;
                          },
                          controller: nameController,
                          hintText: "Enter your name",
                          autoCapitalize: TextCapitalization.words,
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          controller: usernameController,
                          hintText: "Enter your username",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an username";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an email address";
                            } else if (!value.isEmail) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                          controller: emailController,
                          hintText: "Enter your email",
                          textInputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password";
                            }
                            if (value.length <= 6 || value.length >= 20) {
                              return "Passwords should be of 6-20 characters";
                            }
                            return null;
                          },
                          controller: passwordController,
                          hintText: "Enter your password",
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          validator: (value) {
                            if (value != passwordController.text) {
                              return "Both passwords do not match";
                            }

                            return null;
                          },
                          controller: confirmPasswordController,
                          hintText: "Re-enter your password",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    onTap: signInUser,
                    buttonText: "Signup",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already an account holder? ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.maybePop(context);
                          await Navigator.push(
                            context,
                            AnimatedRoute(
                              context: context,
                              page: const LoginScreen(),
                            ).createRoute(),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
