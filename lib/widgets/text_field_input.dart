import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final bool? autocorrect;
  final TextInputType? textInputType;
  final TextCapitalization? autoCapitalize;
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;

  const TextFieldInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.autoCapitalize,
    this.autocorrect,
    this.textInputType,
  });

  @override
  TextFieldInputState createState() => TextFieldInputState();
}

class TextFieldInputState extends State<TextFieldInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autocorrect: widget.autocorrect ?? false,
      keyboardType: widget.textInputType ?? TextInputType.text,
      textCapitalization: widget.autoCapitalize ?? TextCapitalization.sentences,
      obscureText: widget.isPassword,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
