import 'package:flutter/material.dart';
import 'package:instagram_clone/database/comment_service.dart';
import 'package:instagram_clone/database/publication_services.dart';
import 'package:instagram_clone/database/user_services.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/pages/tab1_home/home_app_bar.dart';
import 'package:instagram_clone/ui/common_elements/post_item.dart';
import 'package:instagram_clone/ui/pages/tab1_home/img_picker/picker_gallery_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
  final ScrollController scroll;
  HomePage(this.scroll);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<dynamic> feedWidgets;

  @override
  void initState() {
    super.initState();
    feedWidgets = _getFeed();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        HomeAppBar(
          onIconTap: (int index) => onIconTap(index),
        ),
      ],
      body: FutureBuilder(
        future: feedWidgets,
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
                      onPressed: () => refreshFeed(),
                      child: Text(AppStrings.refresh),
                    )
                  ],
                ),
              );
            } else {
              feedList = SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PostItem(snapshot.data[index]);
                  },
                  childCount: snapshot.data.length,
                ),
              );
            }
          }
          return RefreshIndicator(
            key: refreshKey,
            onRefresh: () => refreshFeed(),
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
    User user = await UserServices.getCurrentUser();

    // Get his list of following
    for (String f in user.following)
      users.add(await UserServices.getUser(f));

    // To add own publications in feed :
    users.add(user);

    // To link publication and comments
    List<Publication> publications = await _getPublication(users);
    for (Publication p in publications) p.comments = await _getComments(p);

    // To link comment and user
    publications = await _linkCommentsAndUsers(publications);

    return publications;
  }

  _getPublication(List<User> users) async {
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

  _getComments(Publication publication) async =>
      await CommentServices.getCommentsForPublication(
          publication.user.id, publication.id);

  _linkCommentsAndUsers(List<Publication> publications) async {
    for (Publication p in publications) if (p.comments.isNotEmpty) for (Comment c in p.comments) c.writtenByUser = await UserServices.getUser(c.writtenBy);
    return publications;
  }

  refreshFeed() async {
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      feedWidgets = _getFeed();
    });
  }

  onIconTap(int index) {
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
