import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/signup_screen.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:men_matter_too/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoignScreenState createState() => LoignScreenState();
}

class LoignScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPassword = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<UserProvider>(builder: (context, user, _) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
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
                      return const LoadingIndicator();
                    },
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFieldInput(
                          controller: emailController,
                          hintText: "Enter your email",
                          textInputType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an email address";
                            }
                            if (!value.isEmail) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          controller: passwordController,
                          hintText: "Enter your password",
                          isPassword: isPassword,
                          toggleViewPassword: () => setState(() {
                            isPassword = !isPassword;
                          }),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            user.resetPassword(emailController.text),
                        child: const Text(
                          "Forgot Password? Click here!",
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                  CustomButton(
                    onTap: () {
                      user.loginUser(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
                    buttonText: "Login",
                  ),

                  // CustomButton(
                  //   onTap: () => user.loginWithGoogle(),
                  //   buttonText: "Continue with Google",
                  // ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dont have an account? ",
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
                              page: const SignupScreen(),
                            ).createRoute(),
                          );
                        },
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
