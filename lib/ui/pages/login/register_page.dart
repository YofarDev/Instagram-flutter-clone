import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/authentication_services.dart';
import 'package:instagram_clone/ui/common_elements/profile_picture_picker/profile_picture_picker_page.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _emptyEmail;
  bool _emptyUsername;
  bool _incorrectPassword;
  bool _obscureText;

  String _image;

  @override
  void initState() {
    super.initState();
    _emptyEmail = false;
    _emptyUsername = false;
    _incorrectPassword = false;
    _obscureText = true;
    _image = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: ListView(
        children: [
          _profilePictureField(),
          _emailField(),
          _usernameField(),
          _passwordField(),
          _confirmButton(),
        ],
      ),
    );
  }

  Widget _appBar() => AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.close,
          size: 40,
          color: Colors.black87,
        ),
        onPressed: () => {Navigator.of(context).pop()},
      ),
      title: SizedBox(
        height: 35,
        child: Text(
          AppStrings.createNewAccount,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
        ),
      ));

  Widget _profilePictureField() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              size: 30,
              color: (_image.isNotEmpty) ? Colors.black : Colors.grey,
            ),
            onPressed: (_image.isNotEmpty)
                ? () {
                    setState(() {
                      _image = "";
                    });
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
            child: SizedBox(
              height: 200,
              width: 200,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (_image.isNotEmpty)
                    ? FileImage(File(_image))
                    : AssetImage("assets/images/default-profile.png"),
              ),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(20),
              //   child: (_image.isNotEmpty)
              //       ? Image.file(File(_image))
              //       : Image.asset(
              //           "assets/images/default-profile.png",
              //         ),
              // ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              size: 30,
              color: Colors.black,
            ),
            onPressed: _getImage,
          ),
        ],
      );

  Widget _emailField() => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 40),
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

  Widget _usernameField() => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: TextField(
          controller: _usernameController,
          autocorrect: false,
          inputFormatters: [
            LengthLimitingTextInputFormatter(12),
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z-0-9]")),
          ],
          decoration: InputDecoration(
            errorText: _emptyUsername ? AppStrings.errorUsername : null,
            filled: true,
            fillColor: AppColors.lightGrey,
            hintText: AppStrings.username,
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

  Widget _confirmButton() => Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: FlatButton(
            color: Colors.blue,
            height: 55,
            onPressed: () => _onConfirmPressed(),
            child: Text(
              AppStrings.confirm,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

  void checkFields() {
    setState(() {
      _emptyEmail = _emailController.text.isEmpty;
      _emptyUsername = _usernameController.text.length < 3;
      _incorrectPassword = _passwordController.text.length < 6;
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onConfirmPressed() async {
    FocusScope.of(context).unfocus();
    setState(() => checkFields());

    if (!_emptyEmail && !_incorrectPassword && !_emptyUsername) {
      await context.read<AuthenticationService>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
            context: context,
          );

      Navigator.of(context).pop(_image);
    }
  }

  void _getImage() {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => ProfilePicturePickerPage(),
    ))
        .then((value) {
      if (value != null)
        setState(() {
          _image = value;
        });
    });
  }
}
