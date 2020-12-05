import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:pop_bottom_menu/pop_bottom_menu.dart';

class FollowButton extends StatefulWidget {
  final bool following;
  final User user;
  final bool showMenu;
  final Function(bool, User) onStateChanged;

  FollowButton({this.following, this.user, this.showMenu, this.onStateChanged});

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _followed;
  User _user;

  @override
  void initState() {
    super.initState();
    _followed = widget.following;
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return (_followed) ? _followingButton() : _followButton();
  }

  Widget _followButton() => Padding(
        padding: const EdgeInsets.only(right: 3),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text(
                AppStrings.follow,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _onFollowTap(),
            )),
      );

  Widget _followingButton() => Padding(
        padding: const EdgeInsets.only(right: 3),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: OutlineButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.following,
                  ),
                  (widget.showMenu)
                      ? Icon(Icons.keyboard_arrow_down)
                      : Container(),
                ],
              ),
              onPressed: () => _onFollowTap(),
            )),
      );

  void _onFollowTap() {
    if (!_followed)
      _follow();
    else if (widget.showMenu)
      _showMenu();
    else
      _unfollow();
  }

  void _follow() {
    setState(() {
      _followed = true;
      widget.onStateChanged(_followed, _user);
      _user.following.add(UserServices.currentUserId);
    });
    UserServices.addFollowing(_user.id);
  }

  void _unfollow() {
    setState(() {
      _followed = false;
      widget.onStateChanged(_followed, _user);
      _user.following.remove(UserServices.currentUserId);
    });
    UserServices.removeFollowing(_user.id);
    if (widget.showMenu) Navigator.of(context).pop();
  }

  void _showMenu() => showModalBottomSheet(
        context: context,
        builder: (context) => PopBottomMenu(
            title: TitlePopBottomMenu(label: _user.username),
            items: [
              ItemPopBottomMenu(
                label: AppStrings.notifications,
                icon: Icon(
                  Icons.navigate_next,
                  color: Colors.grey,
                ),
              ),
              ItemPopBottomMenu(
                label: AppStrings.mute,
                icon: Icon(
                  Icons.navigate_next,
                  color: Colors.grey,
                ),
              ),
              ItemPopBottomMenu(
                onPressed: () => _unfollow(),
                label: AppStrings.unfollow,
              ),
            ]),
      );
}
