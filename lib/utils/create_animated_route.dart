import 'package:flutter/material.dart';

class AnimatedRoute {
  final BuildContext context;
  final Widget page;

  AnimatedRoute({
    required this.context,
    required this.page,
  });

  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, innerChild) {
        var curve = Curves.easeInOutCubic;
        var curveTween = CurveTween(curve: curve);

        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(
          curveTween,
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: innerChild,
        );
      },
    );
  }
}
