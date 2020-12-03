import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/common_elements/list_users/users_list.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';

class LikesPage extends StatefulWidget {
  // List of string id of the users who have liked
  final List<String> likesUsersId;

  LikesPage(this.likesUsersId);

  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  bool _isLoading;
  List<User> _users;
  User _current;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Likes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: (_isLoading)
            ? LoadingWidget()
            : UsersList(
                current: _current,
                list: _users,
              ),
      ),
    );
  }

  ///*** DATA ***///
  Future<User> _getCurrentUser() async => await UserServices.getCurrentUser();

  void _getUsers() async {
    List<User> users = [];
    for (String id in widget.likesUsersId)
      users.add(await UserServices.getUser(id));
    User current = await _getCurrentUser();
    setState(() {
      _users = users;
      _current = current;
      _isLoading = false;
    });
  }
}
