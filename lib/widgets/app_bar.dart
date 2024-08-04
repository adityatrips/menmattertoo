import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';

PreferredSizeWidget myAppBar(BuildContext context) {
  return AppBar(
    centerTitle: true,
    title: SvgPicture.asset(
      'assets/logo_extended.svg',
      color: Theme.of(context).colorScheme.primary,
      height: 40,
      placeholderBuilder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.logout_rounded,
          color: Colors.blue.shade700,
        ),
        onPressed: () async {
          String logout = await AuthMethods().logout();
          if (logout == "success") {
            showSnackbar(context, "Logout successful");
            return;
          }
          showSnackbar(context, logout, type: TypeOfSnackbar.error);
          return;
        },
      )
    ],
  );
}
