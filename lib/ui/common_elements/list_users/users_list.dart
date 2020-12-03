import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/utils/extensions.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../follow_button.dart';

class UsersList extends StatefulWidget {
  final User current;
  final List<User> list;

  UsersList({
    @required this.current,
    @required this.list,
  });

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List<User> _users;
  User _current;

  @override
  void initState() {
    super.initState();
    _current = widget.current;
    _users = widget.list;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _buildList(_users),
      ),
    );
  }

  Widget _buildList(List<User> users) => ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildItem(users[index]);
        },
      );

  Widget _buildItem(User user) => Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Utils.navToUserDetails(context, user),
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: Utils.getProfilePic(user.picture),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                          ),
                          Text(user.name.capitalizeFirstLetterOfWords,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey))
                        ],
                      ),
                    ),
                  ],
                ),
                (_current != null && user.id != _current.id)
                    ? Container(
                        width: 150,
                        child: FollowButton(
                          following: _isFollowedByCurrentUser(user),
                          user: user,
                          showMenu: false,
                          onStateChanged: _onFollowStateChanged,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );

  ///*** DATA ***///
  bool _isFollowedByCurrentUser(User user) =>
      _current.following.contains(user.id);

  void _onFollowStateChanged(bool isFollowed, String id) {
    if (isFollowed)
      _current.following.add(id);
    else
      _current.following.remove(id);
  }
}
