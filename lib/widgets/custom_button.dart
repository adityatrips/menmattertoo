import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String buttonText;
  final void Function() onTap;
  final double height;
  final String fontFamily;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.height = 35,
    this.fontFamily = "BN",
  });

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size(double.infinity, widget.height),
      ),
      onPressed: widget.onTap,
      child: Text(widget.buttonText),
    );
  }
}
