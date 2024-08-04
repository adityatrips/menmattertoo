import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String buttonText;
  final void Function() onTap;
  final double fontSize;
  final double height;
  final double borderRadius;
  final String fontFamily;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.backgroundColor,
    this.fontSize = 25,
    this.height = 50,
    this.borderRadius = 15,
    this.fontFamily = "BN",
  });

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      splashColor: Theme.of(context).colorScheme.primary.withAlpha(100),
      splashFactory: InkRipple.splashFactory,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox.fromSize(
        size: Size(double.infinity, widget.height),
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          height: widget.height,
          child: Center(
            child: Center(
              child: Text(
                widget.buttonText,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
