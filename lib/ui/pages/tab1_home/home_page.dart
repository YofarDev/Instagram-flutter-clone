import 'package:flutter/material.dart';
import 'package:instagram_clone/services/publication_services.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/pages/tab1_home/home_app_bar.dart';
import 'package:instagram_clone/ui/common_elements/publication_item.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/picker_gallery_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
  final ScrollController scroll;

  HomePage(this.scroll);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<dynamic> _feedWidgets;
  User _currentUser;

  @override
  void initState() {
    super.initState();
    _feedWidgets = _getFeed();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        HomeAppBar(
          onIconTap: (int index) => _onIconTap(index),
        ),
      ],
      body: FutureBuilder(
        future: _feedWidgets,
        builder: (context, snapshot) {
          Widget feedList;
          if (!snapshot.hasData) {
            feedList = SliverToBoxAdapter(
              child: Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data.length == 0) {
              feedList = SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 80, bottom: 40),
                      child: Center(
                        child: Text(
                          AppStrings.emptyFeed,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _refreshFeed(),
                      child: Text(AppStrings.refresh),
                    )
                  ],
                ),
              );
            } else {
              feedList = SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PostItem(
                      publication: snapshot.data[index],
                      currentUser: _currentUser,
                    );
                  },
                  childCount: snapshot.data.length,
                ),
              );
            }
          }
          return RefreshIndicator(
            key: _refreshKey,
            onRefresh: () => _refreshFeed(),
            child: CustomScrollView(
              controller: widget.scroll,
              slivers: <Widget>[
                feedList,
              ],
            ),
          );
        },
      ),
    );
  }

  _getFeed() async {
    List<User> users = [];
    // Get current user
    _currentUser = await UserServices.getCurrentUser();


    // Get his list of following
    for (String f in _currentUser.following)
      users.add(await UserServices.getUser(f));
    // To add own publications in feed :
    users.add(_currentUser);

    // Get publications from following
    List<Publication> publications = await _getPublication(users);

    return publications;
  }

  Future<List<Publication>> _getPublication(List<User> users) async {
    List<Publication> publications = [];
    // Get publications from all users
    for (User user in users) {
      List<Publication> publis =
          await PublicationServices.getPublicationsForUser(user.id);

      // To link users and publications as objects
      for (Publication p in publis) {
        p.user = user;
        publications.add(p);
      }
    }
    // Sort publications from new to old
    publications.sort((a, b) => b.date.compareTo(a.date));
    return publications;
  }

  Future<void> _refreshFeed() async {
    _refreshKey.currentState?.show(atTop: true);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _feedWidgets = _getFeed();
    });
  }

  void _onIconTap(int index) {
    switch (index) {
      case (0):
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, _, __) {
              return PickerGalleryPage();
            },
            transitionDuration: Duration(seconds: 0),
          ),
        );
        break;
      case (1):
        print(1);
        break;
      case (2):
        print(2);
        break;
    }
  }
}
