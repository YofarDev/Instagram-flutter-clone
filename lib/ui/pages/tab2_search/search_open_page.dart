import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/tab2_search/debouncer.dart';
import 'package:instagram_clone/ui/pages_holder.dart';

class SearchOpenPage extends StatefulWidget {
  @override
  _SearchOpenPageState createState() => _SearchOpenPageState();
}

class _SearchOpenPageState extends State<SearchOpenPage>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  TextEditingController _textEditingController;
  final _debouncer = Debouncer();
  int _tabSelected;
  TabController _tabController;
  List<User> _users;
  List<User> _searchOutput;
  bool _isSearching;

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
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _textEditingController.dispose();
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

  Widget _appBar() =>
      AppBar(
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

  Widget _searchField() =>
      ClipRRect(
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

  Widget _tabBar() =>
      TabBar(
        onTap: (index) {
          _pageController.jumpToPage(index);
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

  List<Widget> _tabView() =>
      [
        _searchOutputWidget(),
        _searchOutputWidget(),
        Expanded(
          child: Container(
            color: Colors.orange,
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.green,
          ),
        )
      ];

  Widget _searchOutputWidget() =>
      Expanded(
        child: (_searchOutput.isEmpty && _isSearching)
            ? _noResult()
            : ListView.builder(
          itemCount: _searchOutput.length,
          itemBuilder: (context, index) {
            return _itemUser(_searchOutput[index]);
          },
        ),
      );

  Widget _noResult() =>
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "${AppStrings.noResultFor}${_textEditingController.text}\"",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );

  Widget _itemUser(User user) =>
      GestureDetector(
        onTap: () => _onUserClick(user),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.picture),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  user.username,
                ),
              ),
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

  void _getAllUsers() async =>
    _users = await UserServices.getUsers();


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

  void _onUserClick(User user) {
    if (user.id == UserServices.currentUser)
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PagesHolder(4)));
  }
}
