import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:men_matter_too/screens/login_screen.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:men_matter_too/widgets/text_field_input.dart';
import 'package:men_matter_too/resources/auth_methods.dart';

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

  Future<void> signInUser() async {
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
                  TextFieldInput(
                    controller: nameController,
                    hintText: "Enter your name",
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: usernameController,
                    hintText: "Enter your username",
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: emailController,
                    hintText: "Enter your email",
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: passwordController,
                    hintText: "Enter your password",
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: confirmPasswordController,
                    hintText: "Re-enter your password",
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
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
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
