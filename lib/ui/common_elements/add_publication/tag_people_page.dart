import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/ui/common_elements/add_publication/search_users_page.dart';
import 'package:instagram_clone/ui/common_elements/content_slider.dart';
import 'package:instagram_clone/ui/common_elements/list_users/users_list.dart';

class TagPeoplePage extends StatefulWidget {
  final List<Content> medias;

  TagPeoplePage(this.medias);

  @override
  _TagPeoplePageState createState() => _TagPeoplePageState();
}

class _TagPeoplePageState extends State<TagPeoplePage> {
  PageController _pageController;
  List<Content> _medias;
  int _currentMediaIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      keepPage: false,
    );
    _getAllUsers();
    // Copy an object in dart is not so easy :
    _medias = widget.medias
        .map((e) => Content(mentions: [...e.mentions], bytes: e.bytes))
        .toList();
    _currentMediaIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(100),
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () => _onAddTagPeopleTap(),
          ),
        ),
        body: _page(),
      ),
    );
  }

  Widget _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.tagPeople,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.blue,
            ),
            onPressed: () => _onConfirmTap(),
          ),
        ],
      );

  Widget _page() => PageView.builder(
        controller: _pageController,
        itemCount: _medias.length,
        onPageChanged: (index) {
          setState(() {
            _currentMediaIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Column(
            children: [
              _mediaView(index),
              _getUserList(index),
            ],
          );
        },
      );

  Widget _mediaView(int index) => Image.memory(_medias[index].bytes);

  Widget _getUserList(int index) => Expanded(
        child: UsersList(
          currentUserId: UserServices.currentUserId,
          list: _medias[index].mentions,
          removeButton: true,
          onRemoveTap: (user) => _onRemoveUserTap(user),
        ),
      );

  Future<List<User>> _getAllUsers() async => await UserServices.getUsers();

  void _onAddTagPeopleTap() async {
    List<User> allUsers = await _getAllUsers();
    List<User> copyUsers = [...allUsers];
    // To remove already tag users
    for (User user in copyUsers)
      for (User user2 in _medias[_currentMediaIndex].mentions)
        if (user.id == user2.id) allUsers.remove(user);

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => SearchUsersPage(allUsers),
          ),
        )
        .then((user) => _handleResults(user));
  }

  void _handleResults(User user) {
    setState(() {
      if (user != null) _medias[_currentMediaIndex].mentions.add(user);
    });
  }

  void _onRemoveUserTap(User user) {
    setState(() {
      _medias[_currentMediaIndex].mentions.remove(user);
    });
  }

  void _onConfirmTap() => Navigator.of(context).pop(_medias);
}
