import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/user_services.dart';

class ScreenInput extends StatefulWidget {
  final String title;
  final String inputText;

  ScreenInput(this.title, this.inputText);

  _ScreenInputState createState() => _ScreenInputState();
}

class _ScreenInputState extends State<ScreenInput> {
  TextEditingController _textController;
  String _textChanged;
  bool _usernameExists;
  int _maxLength;
  bool _filterName;
  bool _filterUsername;

  @override
  void initState() {
    super.initState();
    _textChanged = widget.inputText;
    _textController = TextEditingController(text: _textChanged);
    _usernameExists = false;
    _filterName = false;
    _filterUsername = false;
    _initValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _appBar(widget.title),
          _textField(),
        ],
      ),
    );
  }

  Widget _appBar(String title) => SliverAppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        pinned: true,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: 40,
            color: Colors.black87,
          ),
          onPressed: () => {Navigator.of(context).pop(widget.inputText)},
        ),
        title: SizedBox(
          height: 35,
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(
              right: 30,
            ),
            icon: Icon(
              Icons.check,
              size: 40,
              color:
                  (_textChanged.isNotEmpty) ? Colors.blue : AppColors.blue200,
            ),
            onPressed: () => (widget.title == AppStrings.bio)
                ? _onConfirmTap()
                : (_textChanged.isNotEmpty)
                    ? _onConfirmTap()
                    : null,
          ),
        ],
      );

  Widget _textField() => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(
            top: 35,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: TextStyle(color: Colors.grey),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                autocorrect: false,
                maxLines: null,
                textCapitalization: (_filterUsername)
                    ? TextCapitalization.none
                    : (_filterName)
                        ? TextCapitalization.words
                        : TextCapitalization.sentences,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxLength),
                  (_filterName)
                      ? FilteringTextInputFormatter.allow(
                          RegExp("[a-zA-Z+0-9+\.+ ]"))
                      : (_filterUsername)
                          ? FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z-0-9]"))
                          : FilteringTextInputFormatter.deny("")
                ],
                controller: _textController,
                onChanged: (value) => setState(() {
                  _textChanged = value;
                }),
                cursorColor: AppColors.darkGreen,
                cursorWidth: 2,
                decoration: InputDecoration(
                  errorText:
                      (_usernameExists) ? AppStrings.usernameExists : null,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.grey50),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.grey50),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
      );

  void _onConfirmTap() async {
    print("true");
    // Username
    if (widget.title == AppStrings.username) {
      _usernameExists = await _usernameAlreadyExists();
      if (!_usernameExists && _textChanged.isNotEmpty)
        Navigator.of(context).pop(_textChanged);
    }
    // Name & Bio
    else
      Navigator.of(context).pop(_textChanged);
  }

  Future<bool> _usernameAlreadyExists() async {
    List<User> users = await UserServices.getUsers();
    User current = await UserServices.getCurrentUser();
    List<String> usernames = [];
    for (User user in users)
      if (user.username != current.username) usernames.add(user.username);
    return (usernames.contains(_textChanged));
  }

  void _initValues() {
    switch (widget.title) {
      case (AppStrings.username):
        {
          _maxLength = 12;
          _filterUsername = true;
        }
        break;
      case (AppStrings.name):
        {
          _maxLength = 20;
          _filterName = true;
        }
        break;
      case (AppStrings.bio):
        {
          _maxLength = 200;
        }
        break;
    }
  }
}
