import 'package:flutter/material.dart';
import 'package:instagram_clone/models/publication.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/publication_services.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/common_elements/follow_button.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/common_elements/persistent_header.dart';
import 'package:instagram_clone/ui/common_elements/user_publications_page.dart';
import 'package:instagram_clone/ui/pages/message/conversation_page.dart';
import 'package:instagram_clone/ui/pages/tab5_user/header_user.dart';
import 'package:instagram_clone/utils/utils.dart';

class UserPage extends StatefulWidget {
  final User user;

  UserPage(this.user);

  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  TabController _tabController;
  Future<dynamic> _publicationsWidgets;
  User _userDetails;
  List<Publication> _mentionsList = [];
  bool _followed;

  @override
  void initState() {
    super.initState();
    _userDetails = widget.user;
    _publicationsWidgets = _getPublications();
    _getFollowingState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _followed = false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            _appBar(),
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
                  SliverToBoxAdapter(
                      child: Container(
                    height: 1,
                    color: AppColors.grey1010,
                  )),
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
          ),
        ),
      ),
    );
  }

  ///*** UI ***///
  Widget _appBar() => SliverAppBar(
        automaticallyImplyLeading: true,
        brightness: Brightness.light,
        pinned: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
        title: SizedBox(
          height: 35.0,
          child: Text(_userDetails.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              )),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Colors.black,
            ),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_outlined,
              color: Colors.black,
            ),
            onPressed: null,
          ),
        ],
      );

  Widget _headerCollapse() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            HeaderUser(_userDetails),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Widget _buttons() => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: FollowButton(
                following: _followed,
                showMenu: true,
                user: _userDetails,
                onStateChanged: (bool state, String id) =>
                    _onFollowButtonTap(state),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 3),
                child: OutlineButton(
                  child: Text(AppStrings.message),
                  onPressed: () => _onMessageTap(),
                ),
              ),
            )
          ],
        ),
      );

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
            _gridPublications(snapshot.data),
            _gridPublications(_mentionsList),
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

  ///*** DATA ***///

  Future<dynamic> _getPublications() async {
    List<Mention> mentions = [];
    // Publications of current user
    List<Publication> publicationsList =
        await PublicationServices.getPublicationsForUser(_userDetails.id);
    // Publications where current user is mentioned
    for (String mentionStr in _userDetails.mentions)
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

  void _onPublicationTap(List<Publication> publications, int index) {
    publications.forEach((Publication p) {
      p.user = _userDetails;
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          UserPublicationsPage(publications, _userDetails, index),
    ));
  }

  void _onMessageTap() async {
    User current = await UserServices.getCurrentUser();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ConversationPage(
        toUser: _userDetails,
        fromUser: current,
      ),
    ));
  }

  void _getFollowingState() async {
    User current = await UserServices.getCurrentUser();
    setState(() {
      _followed = _isFollowedByCurrentUser(current.following, _userDetails);
    });
  }

  bool _isFollowedByCurrentUser(List<String> following, User user) =>
      following.contains(user.id);

  void _onFollowButtonTap(bool state) {
    setState(() {
      _followed = state;
    });
  }
}
