import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:provider/provider.dart';

PreferredSizeWidget myAppBar(BuildContext context) {
  return AppBar(
    centerTitle: true,
    title: SvgPicture.asset(
      'assets/logo_extended.svg',
      color: Theme.of(context).colorScheme.primary,
      height: 40,
      placeholderBuilder: (context) {
        return const LoadingIndicator();
      },
    ),
    actions: [
      Consumer<UserProvider>(
        builder: (context, user, _) {
          return IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.blue.shade700,
            ),
            onPressed: () => user.logoutUser(),
          );
        },
      )
    ],
  );
}
