import 'package:flutter/material.dart';
import 'package:instagram_clone/services/publication_services.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/bottom_app_bar.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/common_elements/no_animation_material_page_route.dart';
import 'package:instagram_clone/ui/common_elements/user_list_publications/user_publications_page.dart';
import 'package:instagram_clone/ui/pages/edit_profile/edit_profile.dart';
import 'package:instagram_clone/ui/common_elements/persistent_header.dart';
import 'package:instagram_clone/ui/pages/tab5_user/animated_drawer.dart';
import 'package:instagram_clone/ui/pages_holder.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/utils/extensions.dart';

class CurrentUserPage extends StatefulWidget {
  final Function() onDrawerIconTap;


  CurrentUserPage(this.onDrawerIconTap);

  _CurrentUserPageState createState() => _CurrentUserPageState();
}

class _CurrentUserPageState extends State<CurrentUserPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  TabController _tabController;
  Future<dynamic> _publicationsWidgets;
  String _title;
  User _currentUser;
  List<Publication> _mentionsList = [];
  int _posts = 0;

  @override
  void initState() {
    super.initState();
    _publicationsWidgets = _getPublications();
    _title = "";
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: MyBottomAppBar(
        currentPage: 4,
        onPageChange: _onPageChanged,
        darkTheme: false,
      ),
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
                _appBar(),
              ],
          body: _future()),
    );
  }

  ///*** UI ***///

  Widget _future() => FutureBuilder(
        future: _publicationsWidgets,
        builder: (context, snapshot) {
          List<Widget> widgets = [];
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
              _tabView(snapshot),
            ];
          }
          return RefreshIndicator(
            key: refreshKey,
            onRefresh: () => refreshList(),
            child: CustomScrollView(
              slivers: widgets,
            ),
          );
        },
      );

  Widget _appBar() => SliverAppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        pinned: true,
        backgroundColor: Colors.white,
        elevation: 1,
        forceElevated: true,
        centerTitle: false,
        title: SizedBox(
          height: 35.0,
          child: Text(_title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              )),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: widget.onDrawerIconTap,
          ),
        ],
      );

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
                  backgroundColor: Colors.white,
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
                    _currentUser.name.capitalizeFirstLetterOfWords,
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
                  if (value == "update") _updateUser();
                }),
                child: Text(AppStrings.editProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() => SliverPersistentHeader(
        pinned: true,
        delegate: PersistentHeader(
          widget: TabBar(
            controller: _tabController,
            onTap: (n) {},
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.grid_on_outlined,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.account_box_outlined,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _tabView(AsyncSnapshot snapshot) => SliverFillRemaining(
        child: TabBarView(
          controller: _tabController,
          children: [
            (snapshot.data.isEmpty)
                ? _emptyTabPublications()
                : _gridPublications(snapshot.data),
            (_mentionsList.isEmpty)
                ? _emptyTabMentions()
                : _gridPublications(_mentionsList),
          ],
        ),
      );

  Widget _gridPublications(List<Publication> publications) => GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: publications.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onPublicationTap(publications, index),
          child: Stack(
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
          ),
        );
      });

  Widget _getPublicationIcon(Publication publication) {
    List<Content> content = [];
    Widget icon;
    for (String c in publication.content)
      content.add(Utils.strToItemContent(c));
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

  Widget _emptyTabPublications() => Padding(
        padding: EdgeInsets.only(left: 80, right: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
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
      );

  Widget _emptyTabMentions() => Padding(
        padding: EdgeInsets.only(left: 80, right: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
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
      );

  ///*** DATA ***///
  Future<dynamic> _getCurrentUser() async =>
      await UserServices.getCurrentUser();

  Future<dynamic> _getPublications() async {
    _currentUser = await _getCurrentUser();
    setState(() {
      _title = _currentUser.username;
    });
    List<Mention> mentions = [];
    // Publications of current user
    List<Publication> publicationsList =
        await PublicationServices.getPublicationsForUser(_currentUser.id);
    _posts = publicationsList.length;
    // Publications where current user is mentioned
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

  Future<void> refreshList() async {
    refreshKey.currentState?.show(
        atTop:
            true); // change atTop to false to show progress indicator at bottom
    await Future.delayed(Duration(seconds: 2)); //wait here for 2 second
    setState(() {
      _publicationsWidgets = _getPublications();
    });
  }

  void _updateUser() async {
    User user = await UserServices.getCurrentUser();
    setState(() {
      _currentUser = user;
      _title = user.username;
    });
  }

  void _onPublicationTap(List<Publication> publications, int index) {
    publications.forEach((Publication p) {
      p.user = _currentUser;
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          UserPublicationsPage(publications, _currentUser, index),
    ));
  }

  _onPageChanged(int page) {
    if (page != 4){ if (page ==2)  Navigator.of(context).push(NoAnimationMaterialPageRoute(
      builder: (context) => PagesHolder(page,darkTheme: true),
    ));
    else
      Navigator.of(context).push(NoAnimationMaterialPageRoute(
        builder: (context) => PagesHolder(page, darkTheme: false),
      ));
    }
  }
}
