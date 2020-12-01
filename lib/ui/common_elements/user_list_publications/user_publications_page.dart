import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/bottom_app_bar.dart';
import 'package:instagram_clone/ui/common_elements/publication_item.dart';
import 'package:instagram_clone/ui/pages_holder.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class UserPublicationsPage extends StatefulWidget {
  final List<Publication> _publications;
  final User _currentUser;
  final int _index;

  UserPublicationsPage(this._publications, this._currentUser, this._index);

  @override
  _UserPublicationsPageState createState() => _UserPublicationsPageState();
}

class _UserPublicationsPageState extends State<UserPublicationsPage> {
  List<Publication> _publications;
  User _currentUser;
  ItemScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _publications = widget._publications;
    _currentUser = widget._currentUser;

    _scrollController = ItemScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.scrollTo(
        index: widget._index,
        duration: Duration(milliseconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(),
        bottomNavigationBar: _bottomNav(),
        body: ScrollablePositionedList.builder(
          itemScrollController: _scrollController,
          itemCount: _publications.length,
          itemBuilder: (context, index) {
            return PublicationItem(
              publication: _publications[index],
              currentUser: _currentUser,
              isFeed: false,
            );
          },
        ),
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
        AppStrings.posts,
        style: TextStyle(
          color: Colors.black,
        ),
      ));

  Widget _bottomNav() => MyBottomAppBar(
        currentPage: 4,
        onPageChange: (int selected) =>
            Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PagesHolder(selected),
        )),
      );
}
