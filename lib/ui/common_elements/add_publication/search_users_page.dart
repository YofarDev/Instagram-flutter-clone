import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/ui/common_elements/list_users/users_list.dart';
import 'package:instagram_clone/ui/pages/tab2_search/debouncer.dart';

class SearchUsersPage extends StatefulWidget {
  final List<User> allUsers;

  SearchUsersPage(this.allUsers);

  @override
  _SearchUsersPageState createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  TextEditingController _textEditingController;
  final _debouncer = Debouncer();
  List<User> _searchOutput;
  bool _isSearching;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _searchOutput = [];
    _isSearching = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _searchField(),
            (_isSearching) ? Expanded(child: _resultsField()) : Container(),
          ],
        ),
      ),
    );
  }

  Widget _searchField() => Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TextField(
            autofocus: true,
            controller: _textEditingController,
            onChanged: (value) => _onSearchListener(),
            decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                hintStyle: TextStyle(color: AppColors.grey50),
                fillColor: AppColors.grey1010),
          ),
        ),
      );

  Widget _resultsField() => (_searchOutput.isEmpty)
      ? _noResultField()
      : UsersList(
          list: _searchOutput,
          currentUserId: UserServices.currentUserId,
          onUserTap: (user) => _onUserTap(user),
        );

  Widget _noResultField() =>
      Text("${AppStrings.noResultFor}${_textEditingController.text}\"");

  void _onSearchListener() {
    setState(() {
      _isSearching = _textEditingController.text.isNotEmpty;
    });
    if (_isSearching) {
      _debouncer.call(() {
        String input = _textEditingController.text;
        setState(() {
          _searchOutput = widget.allUsers
              .where((User user) =>
                  user.name.contains(input) || user.username.contains(input))
              .toList();
        });
      });
    }
  }

  void _onUserTap(User user) {
    Navigator.of(context).pop(user);
  }
}
