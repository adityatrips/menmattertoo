import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/screens/signup_screen.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:men_matter_too/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoignScreenState createState() => LoignScreenState();
}

class LoignScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signInUser() async {
    String? response = await AuthMethods().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (response == "success") {
      showSnackbar(
        context,
        "Welcome back cap'n. We awaited your arrival.",
        type: TypeOfSnackbar.success,
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
                  controller: emailController,
                  hintText: "Enter your email",
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextFieldInput(
                  controller: passwordController,
                  hintText: "Enter your password",
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  onTap: signInUser,
                  buttonText: "Login",
                ),
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
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
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
        ),
      ),
    );
  }
}
