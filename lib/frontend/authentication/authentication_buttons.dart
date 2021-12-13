import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_note/backend/auth_methods.dart';

Widget authTextField({
  required String labelText,
  required String? Function(String?)? validator,
  required TextEditingController textEditingController,
  Widget? suffixIcon,
  bool showPassword = false,
}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
    child: TextFormField(
      controller: textEditingController,
      style: TextStyle(color: Colors.black),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
      obscureText: showPassword,
    ),
  );
}

Widget authWiteEmailButton({
  required String buttonRole,
  required void Function()? onPressed,
}) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: 100,
      maxHeight: 50,
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonRole),
      style: ElevatedButton.styleFrom(elevation: 10.0),
    ),
  );
}

Widget authWiteGoogleButton({
  required void Function()? onPressed,
  required BuildContext context,
}) {
  return SizedBox(
    height: 50.0,
    width: 100.0,
    child: ElevatedButton(
      child: Image.asset('assets/images/google_icon.png'),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(primary: Colors.white, elevation: 10.0),
    ),
  );
}
