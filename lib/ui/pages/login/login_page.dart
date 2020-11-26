import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/authentification_services.dart';
import 'package:instagram_clone/services/media_services.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/pages/login/register_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _emptyEmail = false;
  bool _incorrectPassword = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _logo(),
          _emailField(),
          _passwordField(),
          _loginButton(),
          _separator(),
          _emailButton(),
        ],
      ),
    );
  }

  Widget _logo() => Padding(
        padding: EdgeInsets.fromLTRB(100, 0, 100, 40),
        // Click on logo to login with test account
        child: GestureDetector(
          onTap: () => {
            context.read<AuthenticationService>().signIn(
                  key: scaffoldKey,
                  email: "admin@mail.com",
                  password: "pass1234",
                )
          },
          child: Image.asset(
            "assets/images/insta_logo.png",
            fit: BoxFit.contain,
          ),
        ),
      );

  Widget _emailField() => Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: TextField(
          controller: _emailController,
          autocorrect: false,
          decoration: InputDecoration(
            errorText: _emptyEmail ? AppStrings.errorEmail : null,
            filled: true,
            fillColor: AppColors.lightGrey,
            hintText: AppStrings.email,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
          ),
        ),
      );

  Widget _passwordField() => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: TextField(
          controller: _passwordController,
          obscureText: _obscureText,
          autocorrect: false,
          decoration: InputDecoration(
            errorText: _incorrectPassword ? AppStrings.errorPassword : null,
            filled: true,
            fillColor: AppColors.lightGrey,
            hintText: AppStrings.password,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
            suffixIcon: InkWell(
              onTap: _toggle,
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );

  Widget _loginButton() => Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: FlatButton(
            color: Colors.blue,
            height: 55,
            onPressed: () => _onLoginPressed(),
            child: Text(
              AppStrings.login,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

  Widget _separator() => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: 150,
              color: AppColors.grey50,
            ),
            Text(
              AppStrings.or,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.grey50,
              ),
            ),
            Container(
              height: 1,
              width: 150,
              color: AppColors.grey50,
            ),
          ],
        ),
      );

  Widget _emailButton() => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 55,
            child: SignInButton(
              Buttons.Email,
              onPressed: () => _onEmailButtonPressed(),
            ),
          ),
        ),
      );

  void checkFields() {
    _emailController.text.isEmpty ? _emptyEmail = true : _emptyEmail = false;

    _passwordController.text.length < 6
        ? _incorrectPassword = true
        : _incorrectPassword = false;
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();
    setState(() => checkFields());
    if (!_emptyEmail && !_incorrectPassword)
      context.read<AuthenticationService>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            key: scaffoldKey,
          );
  }

  void _onEmailButtonPressed() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RegisterPage()))
        .then((value) => _uploadPicture(
            value)); // Need to upload the image from there to get the uid of the new user
  }

  void _uploadPicture(File file) => (file != null)
      ? MediaServices.uploadProfilePicture(file, UserServices.currentUserId)
      : print("no picture");
}
