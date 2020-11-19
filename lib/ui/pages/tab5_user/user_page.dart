import 'package:flutter/material.dart';
import 'package:instagram_clone/database/publication_services.dart';
import 'package:instagram_clone/database/user_services.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/edit_profile/edit_profile.dart';
import 'package:instagram_clone/ui/pages/tab5_user/persistent_header.dart';
import 'package:instagram_clone/ui/pages/tab5_user/user_app_bar.dart';
import 'package:instagram_clone/ui/pages/tab5_user/user_nav_bar.dart';
import 'package:instagram_clone/utils/utils.dart';

class UserPage extends StatefulWidget {
  _UserPageState createState() => _UserPageState();
  final ScrollController scroll;
  UserPage(this.scroll);
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<dynamic> _publicationsWidgets;
  User currentUser;
  String pseudo;
  List<Publication> mentionsList = [];
  int currentPage = 0;
  int posts = 0;

  @override
  void initState() {
    super.initState();
    pseudo = "";
    _publicationsWidgets = _getPublications();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        UserAppBar(pseudo),
      ],
      body: FutureBuilder(
        future: _publicationsWidgets,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            widgets = [
              SliverToBoxAdapter(
                child: Center(
                  child: LoadingWidget(),
                ),
              ),
            ];
          } else {
            widgets = [
              _headerCollapse(),
              _tabs(),
              _outlinesTabs(context),
              (currentPage == 0)
                  ? _gridPublications(snapshot.data)
                  : _gridPublications(mentionsList),
            ];
          }
          return RefreshIndicator(
            key: refreshKey,
            onRefresh: () => refreshlist(),
            child: CustomScrollView(
              controller: widget.scroll,
              slivers: widgets,
            ),
          );
        },
      ),
    );
  }

  _headerCollapse() {
    double fontSizeTop = 20;
    double fontSizeBot = 16;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(currentUser.picture),
                  radius: 50,
                ),
                Column(
                  children: [
                    Text(
                      posts.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSizeTop),
                    ),
                    Text(
                      AppStrings.posts,
                      style: TextStyle(fontSize: fontSizeBot),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      currentUser.followers.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSizeTop),
                    ),
                    Text(
                      AppStrings.followers,
                      style: TextStyle(fontSize: fontSizeBot),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      currentUser.following.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSizeTop),
                    ),
                    Text(
                      AppStrings.following,
                      style: TextStyle(fontSize: fontSizeBot),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Utils.uppercaseFirstLetter(currentUser.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(currentUser.bio),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 15),
              width: double.infinity,
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.grey),
                color: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return EditProfile(currentUser);
                  }),
                ).then((value) {
                  if (value == "noUpdate") print(value);
                }),
                child: Text(AppStrings.editProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _tabs() {
    return SliverPersistentHeader(
      delegate: PersistentHeader(
        widget: UserNavBar(
          currentPage: currentPage,
          onTabChange: (int selected) => onTabChanged(selected),
        ),
      ),
      pinned: true,
    );
  }

  _outlinesTabs(BuildContext context) {
    double width = (MediaQuery.of(context).size.width) / 2;
    return SliverToBoxAdapter(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: (currentPage == 0) ? Colors.black : Colors.white,
          height: 1,
          width: width,
        ),
        Container(
            color: (currentPage == 0) ? Colors.white : Colors.black,
            height: 1,
            width: width),
      ],
    ));
  }

  _gridPublications(List<Publication> publications) {
    return SliverPadding(
      padding: EdgeInsets.only(top: 2),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                      Utils.strToContent(publications[index].content[0]).url,
                      fit: BoxFit.cover),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: _getPublicationIcon(publications[index]),
                ),
              ],
            );
          },
          childCount: publications.length,
        ),
      ),
    );
  }

  _getPublicationIcon(Publication publication) {
    List<Content> content = [];
    Widget icon;
    for (String c in publication.content) content.add(Utils.strToContent(c));
    if (content.length == 1) {
      if (content[0].isVideo)
        icon = Icon(
          Icons.play_arrow_rounded,
          color: AppColors.white90,
          size: 30,
        );
      else
        icon = Container();
    } else
      icon = Icon(
        Icons.dynamic_feed_rounded,
        color: AppColors.white90,
        size: 30,
      );
    return icon;
  }

  ///*** DATA ***///
  _getCurrentUser() async => await UserServices.getCurrentUser();

  _getPublications() async {
    currentUser = await _getCurrentUser();
    setState(() {
      pseudo = currentUser.pseudo;
    });

    List<Mention> mentions = [];

    // Publications of current user
    List<Publication> publicationsList =
        await PublicationServices.getPublicationsForUser(currentUser.id);
    for (Publication p in publicationsList) p.user = currentUser;
    posts = publicationsList.length;

    // Publications where current user is mentionned
    for (String mentionStr in currentUser.mentions)
      mentions.add(Utils.strToMention(mentionStr));
    for (Mention mention in mentions)
      mentionsList
          .add(await _getMention(mention.mentionBy, mention.publication));

    publicationsList.sort((a, b) => b.date.compareTo(a.date));
    return publicationsList;
  }

  _getMention(String userId, String publicationId) async {
    return await PublicationServices.getPublication(userId, publicationId);
  }

  onTabChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  refreshlist() async {
    refreshKey.currentState?.show(
        atTop:
            true); // change atTop to false to show progress indicator at bottom
    await Future.delayed(Duration(seconds: 2)); //wait here for 2 second
    setState(() {
      _publicationsWidgets = _getPublications();
    });
  }
}
