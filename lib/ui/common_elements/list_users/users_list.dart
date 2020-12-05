import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/utils/extensions.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../follow_button.dart';

class UsersList extends StatefulWidget {
  final List<User> list;
  final String currentUserId;
  final Function(User) onUserTap;
  final Function(User) onRemoveTap;
  final bool followButton;
  final bool removeButton;
  final bool secondLine;

  UsersList({
    @required this.list,
    @required this.currentUserId,
    this.onUserTap,
    this.onRemoveTap,
    this.followButton,
    this.removeButton,
    this.secondLine,
  });

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List<User> _users;
  String _currentUserId;
  bool _followButton;
  bool _removeButton;
  bool _secondLine;

  @override
  void initState() {
    super.initState();
    _currentUserId = widget.currentUserId;
    _users = widget.list;
    _followButton = widget.followButton ?? false;
    _removeButton = widget.removeButton ?? false;
    _secondLine = widget.secondLine ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return _buildList(_users);
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
          onTap: ()=> widget.onUserTap(user),
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
                          Text(
                              _secondLine
                                  ? _getTextInfo(user)
                                  : user.name.capitalizeFirstLetterOfWords,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey))
                        ],
                      ),
                    ),
                  ],
                ),
                (user.id != _currentUserId && _followButton)
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
                (_removeButton) ? _removeButtonWidget(user) : Container(),
              ],
            ),
          ),
        ),
      );

  Widget _removeButtonWidget(User user) => GestureDetector(
        onTap: () => widget.onRemoveTap(user),
        child: Icon(
          Icons.close,
          size: 15,
        ),
      );

  ///*** DATA ***///
  bool _isFollowedByCurrentUser(User user) =>
    user.followers.contains(_currentUserId);

  void _onFollowStateChanged(bool isFollowed, User user) {
    if (isFollowed)
      user.followers.add(_currentUserId);
    else
      user.followers.remove(_currentUserId);
  }

  String _getTextInfo(User user) {
    String str = user.name;
    if (_isFollowedByCurrentUser(user)) str += " - ${AppStrings.following}";
    return str;
  }
}
