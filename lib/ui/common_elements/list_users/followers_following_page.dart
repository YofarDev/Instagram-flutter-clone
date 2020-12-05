import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/ui/common_elements/list_users/users_list.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/utils/utils.dart';

class FollowersFollowingPage extends StatefulWidget {
  final User user;
  final int indexOfTab;

  FollowersFollowingPage({
    this.user,
    this.indexOfTab,
  });

  @override
  _FollowersFollowingPageState createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<User> _users;
  User _current;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, initialIndex: widget.indexOfTab, vsync: this);
    _getCurrentUser();
    _getUsers();
    _isLoading = true;
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
            widget.user.username,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            _tabs(),
            Container(
              height: 1,
              color: AppColors.grey1010,
            ),
            (_isLoading) ? LoadingWidget() : _tabView(_users),
          ],
        ),
      ),
    );
  }

  Widget _tabs() => TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        indicatorColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: "${widget.user.followers.length} ${AppStrings.followers}"),
          Tab(text: "${widget.user.following.length} ${AppStrings.followers}"),
        ],
      );

  Widget _tabView(List<User> users) => Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            UsersList(
              currentUserId: _current.id,
              list: _users
                  .where(
                      (element) => widget.user.followers.contains(element.id))
                  .toList(),
              followButton: true,
              onUserTap: (user) => Utils.navToUserDetails(context, user),
            ),
            UsersList(
              currentUserId: _current.id,
              list: _users
                  .where(
                      (element) => widget.user.following.contains(element.id))
                  .toList(),
              followButton: true,
              onUserTap: (user) => Utils.navToUserDetails(context, user),
            ),
          ],
        ),
      );

  ///*** DATA ***///
  Future<User> _getCurrentUser() async => await UserServices.getCurrentUser();

  void _getUsers() async {
    // Followers and following list into one set of unique user (to optimize queries)
    Set<String> usersId = [
      ...widget.user.followers,
      ...widget.user.following,
    ].toSet();
    List<User> users = [];
    for (String id in usersId) users.add(await UserServices.getUser(id));
    User current = await _getCurrentUser();
    setState(() {
      _users = users;
      _current = current;
      _isLoading = false;
    });
  }
}
