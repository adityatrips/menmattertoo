import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final bool? autocorrect;
  final TextInputType? textInputType;
  final TextCapitalization autoCapitalize;
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final bool multiline;
  final int? maxLength;
  final String? Function(String?)? validator;
  final Function()? toggleViewPassword;

  const TextFieldInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.autoCapitalize = TextCapitalization.none,
    this.autocorrect,
    this.textInputType,
    this.multiline = false,
    this.maxLength,
    this.validator,
    this.toggleViewPassword,
  });

  @override
  TextFieldInputState createState() => TextFieldInputState();
}

class TextFieldInputState extends State<TextFieldInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      minLines: 1,
      maxLines: widget.multiline ? 5 : 1,
      maxLength: widget.maxLength,
      controller: widget.controller,
      autocorrect: widget.autocorrect ?? false,
      keyboardType: widget.textInputType ?? TextInputType.text,
      textCapitalization: widget.autoCapitalize,
      obscureText: widget.isPassword,
      decoration: InputDecoration(
        suffixIcon: widget.toggleViewPassword != null
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    if (widget.toggleViewPassword != null) {
                      widget.toggleViewPassword!();
                    }
                  });
                },
                child: Icon(
                  widget.isPassword ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
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
