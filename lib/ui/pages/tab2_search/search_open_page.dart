import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab2_search/debouncer.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchOpenPage extends StatefulWidget {
  @override
  _SearchOpenPageState createState() => _SearchOpenPageState();
}

class _SearchOpenPageState extends State<SearchOpenPage>
    with SingleTickerProviderStateMixin {
  String sharedKey = UserServices.currentUserId;
  PageController _pageController;
  TabController _tabController;
  TextEditingController _textEditingController;
  final _debouncer = Debouncer();
  int _tabSelected;
  List<User> _users;
  List<User> _searchOutput;
  bool _isSearching;
  Future _recentList;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _textEditingController = TextEditingController();
    _tabSelected = 0;
    _tabController = TabController(length: 4, initialIndex: 0, vsync: this);
    _getAllUsers();
    _users = [];
    _searchOutput = [];
    _isSearching = false;
    _recentList = _getRecentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          _tabBar(),
          Container(
            height: 1,
            color: AppColors.grey1010,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabView(),
            ),
          )
        ],
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
        title: _searchField(),
      );

  Widget _searchField() => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextField(
          controller: _textEditingController,
          onChanged: (value) => _onSearchListener(),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _getHint(),
              filled: true,
              hintStyle: TextStyle(color: AppColors.grey50),
              fillColor: AppColors.grey1010),
        ),
      );

  Widget _tabBar() => TabBar(
        onTap: (index) {
          if (_pageController.hasClients) _pageController.jumpToPage(index);
          setState(() {
            _tabSelected = index;
          });
        },
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        controller: _tabController,
        tabs: [
          Tab(text: AppStrings.top),
          Tab(text: AppStrings.accounts),
          Tab(text: AppStrings.tags),
          Tab(text: AppStrings.places),
        ],
      );

  List<Widget> _tabView() => [
        _searchOutputWidget(),
        _searchOutputWidget(),
        Container(
          color: Colors.orange,
        ),
        Container(
          color: Colors.green,
        )
      ];

  Widget _searchOutputWidget() => (_searchOutput.isEmpty)
      ? (_isSearching)
          ? _noResult()
          : _recent()
      : ListView.builder(
          itemCount: _searchOutput.length,
          itemBuilder: (context, index) {
            return _itemUser(_searchOutput[index]);
          },
        );

  Widget _noResult() => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "${AppStrings.noResultFor}${_textEditingController.text}\"",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );

  Widget _recent() => FutureBuilder(
        future: _recentList,
        builder: (context, snapshot) {
          Widget widget;
          if (snapshot.hasData)
            widget = Expanded(
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return _itemUser(snapshot.data[index]);
                },
              ),
            );
          else
            widget = LoadingWidget();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppStrings.recent,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              widget,
            ],
          );
        },
      );

  Widget _itemUser(User user) => GestureDetector(
        onTap: () => _onUserClick(user),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: Utils.getProfilePic(user.picture),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                        ),
                        Text(_getTextInfo(user),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey))
                      ],
                    ),
                  ),
                ],
              ),
              (!_isSearching)
                  ? GestureDetector(
                      onTap: () => _removeRecentUser(user),
                      child: Icon(
                        Icons.close,
                        size: 15,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );

  String _getHint() {
    switch (_tabSelected) {
      case 0:
        return AppStrings.search;
        break;
      case 1:
        return AppStrings.searchAccounts;
        break;
      case 2:
        return AppStrings.searchTags;
        break;
      case 3:
        return AppStrings.searchPlaces;
        break;
      default:
        return AppStrings.search;
    }
  }

  void _getAllUsers() async => _users = await UserServices.getUsers();

  void _onSearchListener() {
    setState(() {
      _isSearching = _textEditingController.text.isNotEmpty;
    });
    _debouncer.call(() {
      String input = _textEditingController.text;
      if (_users != null)
        setState(() {
          _searchOutput = _users
              .where((User user) =>
                  user.name.contains(input) || user.username.contains(input))
              .toList();
        });
    });
  }

  String _getTextInfo(User user) {
    String str = user.name;
    if (_isFollowedByCurrentUser(user)) str += " - ${AppStrings.following}";
    return str;
  }

  bool _isFollowedByCurrentUser(User user) =>
      user.followers.contains(UserServices.currentUserId);

  void _onUserClick(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList(sharedKey) ?? [];
    if (list.contains(user.id)) list.remove(user.id);
    list.insert(0, user.id);
    if (list.length > 10) list = list.getRange(0, 9);
    prefs.setStringList(sharedKey, list);
    Utils.navToUserDetails(context, user);
  }

  Future<List<User>> _getRecentList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList(sharedKey) ?? [];
    List<User> users = [];
    for (String id in recent) users.add(await UserServices.getUser(id));
    return users;
  }

  void _removeRecentUser(User user) async {
    var recent = await _getRecentList();
    var list = recent.map((e) => e.id).toList();
    list.remove(user.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(sharedKey, list);
    setState(() {
      _recentList = _getRecentList();
    });
  }
}
