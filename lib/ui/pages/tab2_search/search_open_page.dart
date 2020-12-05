import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/user_services.dart';
import 'package:instagram_clone/ui/common_elements/list_users/users_list.dart';
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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

  Widget _searchOutputWidget() {
    if (!_isSearching)
      return _recent();
    else if (_searchOutput.isEmpty)
      return _noResult();
    else
      return UsersList(
        list: _searchOutput,
        currentUserId: UserServices.currentUserId,
        secondLine: true,
        onUserTap: _onUserTap,
        removeButton: false,
      );
  }

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
            widget = UsersList(
              list: snapshot.data,
              currentUserId: UserServices.currentUserId,
              removeButton: true,
              onUserTap: _onUserTap,
              onRemoveTap: (user)=>_removeRecentUser(user),
              secondLine: true,
            );
          else
            widget = LoadingWidget();
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.recent,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(child: widget),
              ],
            ),
          );
        },
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
    if (_isSearching) {
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
  }

  void _onUserTap(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList(sharedKey) ?? [];
    if (list.contains(user.id)) list.remove(user.id);
    list.insert(0, user.id);
    if (list.length > 10) list = list.getRange(0, 9);
    prefs.setStringList(sharedKey, list);
    Utils.navToUserDetails(context, user).then((value) => _updateRecentList());
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
    _updateRecentList();
  }

  void _updateRecentList() async {
    setState(() {
      _recentList = _getRecentList();
    });
  }
}
