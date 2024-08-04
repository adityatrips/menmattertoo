import 'package:flutter/material.dart';

class ResponsiveLayoutScreen extends StatefulWidget {
  final Widget mobileLayout;
  final Widget webLayout;

  const ResponsiveLayoutScreen({
    super.key,
    required this.webLayout,
    required this.mobileLayout,
  });

  @override
  ResponsiveLayoutScreenState createState() => ResponsiveLayoutScreenState();
}

class ResponsiveLayoutScreenState extends State<ResponsiveLayoutScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return widget.mobileLayout;
      }
      return widget.webLayout;
    });
  }
}
