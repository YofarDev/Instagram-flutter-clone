import 'package:flutter/material.dart';
import 'package:instagram_clone/services/publication_services.dart';
import 'package:instagram_clone/services/user_services.dart';
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
  final ScrollController scrollController;

  UserPage(this.scrollController);
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<dynamic> _publicationsWidgets;
  User _currentUser;
  String _username;
  List<Publication> _mentionsList = [];
  int _currentPage = 0;
  int _posts = 0;

  @override
  void initState() {
    super.initState();
    _username = "";
    _publicationsWidgets = _getPublications();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Widget> widgets = [];
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        UserAppBar(_username),
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
              _outlinedTabs(context),
              (_currentPage == 0)
                  ? (snapshot.data.isEmpty)
                      ? _emptyTabPublications()
                      : _gridPublications(snapshot.data)
                  : (snapshot.data.isEmpty)
                      ? _emptyTabMentions()
                      : _gridPublications(_mentionsList),
            ];
          }
          return RefreshIndicator(
            key: refreshKey,
            onRefresh: () => refreshList(),
            child: CustomScrollView(
              controller: widget.scrollController,
              slivers: widgets,
            ),
          );
        },
      ),
    );
  }

  ///*** UI ***///

  Widget _headerCollapse() {
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
                  backgroundImage: Utils.getProfilePic(_currentUser.picture),
                  radius: 50,
                ),
                Column(
                  children: [
                    Text(
                      _posts.toString(),
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
                      _currentUser.followers.length.toString(),
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
                      _currentUser.following.length.toString(),
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
                    Utils.uppercaseFirstLetter(_currentUser.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(_currentUser.bio),
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
                    return EditProfile(_currentUser);
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

  Widget _tabs() {
    return SliverPersistentHeader(
      delegate: PersistentHeader(
        widget: UserNavBar(
          currentPage: _currentPage,
          onTabChange: (int selected) => onTabChanged(selected),
        ),
      ),
      pinned: true,
    );
  }

  Widget _outlinedTabs(BuildContext context) {
    double width = (MediaQuery.of(context).size.width) / 2;
    return SliverToBoxAdapter(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: (_currentPage == 0) ? Colors.black : Colors.white,
          height: 1,
          width: width,
        ),
        Container(
            color: (_currentPage == 0) ? Colors.white : Colors.black,
            height: 1,
            width: width),
      ],
    ));
  }

  Widget _gridPublications(List<Publication> publications) {
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
                  child: Image.network(
                      Utils.strToItemContent(publications[index].content[0]).url,
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

  Widget _getPublicationIcon(Publication publication) {
    List<Content> content = [];
    Widget icon;
    for (String c in publication.content) content.add(Utils.strToItemContent(c));
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

  Widget _emptyTabPublications() => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(left:80, right:80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text(
                  AppStrings.profile,
                  style: (TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  AppStrings.emptyProfile,
                  textAlign: TextAlign.center,
                  style: (TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 16,
                  )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  AppStrings.emptyProfileShare,
                  textAlign: TextAlign.center,
                  style: (TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _emptyTabMentions() => SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.only(left:80, right:80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Padding(
            padding: EdgeInsets.only(top: 60),
            child: Text(
              AppStrings.mentions,
              textAlign: TextAlign.center,
              style: (TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              )),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              AppStrings.mentionsEmpty,
              textAlign: TextAlign.center,
              style: (TextStyle(
                color: AppColors.darkGrey,
                fontSize: 16,
              )),
            ),
          ),

        ],
      ),
    ),
  );

  ///*** DATA ***///
  Future<dynamic> _getCurrentUser() async =>
      await UserServices.getCurrentUser();

  Future<dynamic> _getPublications() async {
    _currentUser = await _getCurrentUser();
    setState(() {
      _username = _currentUser.username;
    });

    List<Mention> mentions = [];

    // Publications of current user
    List<Publication> publicationsList =
        await PublicationServices.getPublicationsForUser(_currentUser.id);
    print(publicationsList.length);
    _posts = publicationsList.length;

    // Publications where current user is mentionned
    for (String mentionStr in _currentUser.mentions)
      mentions.add(Utils.strToMention(mentionStr));
    for (Mention mention in mentions)
      _mentionsList
          .add(await _getMention(mention.mentionBy, mention.publication));

    publicationsList.sort((a, b) => b.date.compareTo(a.date));
    return publicationsList;
  }

  Future<dynamic> _getMention(String userId, String publicationId) async {
    return await PublicationServices.getPublication(userId, publicationId);
  }

  void onTabChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> refreshList() async {
    refreshKey.currentState?.show(
        atTop:
            true); // change atTop to false to show progress indicator at bottom
    await Future.delayed(Duration(seconds: 2)); //wait here for 2 second
    setState(() {
      _publicationsWidgets = _getPublications();
    });
  }
}
