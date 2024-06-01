import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController Controller;
  final String hintText;
  final bool obscureText;

  const TextFieldWidget({
    required this.Controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    // return BlocBuilder<ManageBloc, ManageState>(
    //   builder: (context, state) {
    //     String? errorText;
    //     if (state is TextInvalid) {
    //       errorText = state.message;
    //     }
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // onChanged: (text) {
      //   context.read<ManageBloc>().add(
      //         TextFieldTextChanged(
      //           text: text,
      //         ),
      //       );
      // },
      controller: Controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400)),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        // errorText: errorText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      // validator: (_) {
      //   if (state is TextInvalid) {
      //     return errorText;
      //   }
      //   return null;
      // },
    );
    // },
    // );
  }
}
