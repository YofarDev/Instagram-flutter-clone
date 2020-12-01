import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/conversation.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/conversation_service.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/ui/pages/message/conversation_page.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/utils/extensions.dart';

class ConversationsList extends StatefulWidget {
  final User currentUser;

  ConversationsList(this.currentUser);

  @override
  _ConversationsListState createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  Future<List<Conversation>> _conversations;

  @override
  void initState() {
    super.initState();
    _conversations = _getConversations();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            AppStrings.directConv,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.videocam_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.create_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Text(
                AppStrings.messages,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder(
              future: _conversations,
              builder: (context, snapshot) {
                Widget widget;
                if (snapshot.hasData) {
                  widget = (snapshot.data.length == 0)
                      ? _buildEmptyView()
                      : _buildConversationsList(snapshot.data);
                } else
                  widget = LoadingWidget();
                return Expanded(child: widget);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() => Container(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.grey50,
              ),
              filled: true,
              fillColor: AppColors.grey1010,
              hintText: AppStrings.search,
              hintStyle: TextStyle(color:Colors.grey, ),
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
            ),
          ),
        ),
      );

  Widget _buildConversationsList(List<Conversation> conversations) =>
      ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          String userId =
              (conversations[index].user1 == UserServices.currentUserId)
                  ? conversations[index].user2
                  : conversations[index].user1;
          return FutureBuilder(
            future: _getUser(userId),
            builder: (context, snapshot) {
              Widget widget;

              if (snapshot.hasData)
                widget = _itemList(conversations[index], snapshot.data);
              else
                widget = LoadingWidget();
              return widget;
            },
          );
        },
      );

  Widget _itemList(Conversation conversation, User user) {
    bool _hasNewMessage = conversation.getCurrentNotifications > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => onConversationTap(conversation, user),
            child: Container(
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: Utils.getProfilePic(user.picture),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: (_hasNewMessage)
                              ? TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                              : null,
                        ),
                        Row(
                          children: [
                            Text(
                           _getLastMessage(conversation.lastMessageBody),
                              style: (_hasNewMessage)
                                  ? TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )
                                  : TextStyle(color: AppColors.darkGrey),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                Utils.getHowLongAgo(conversation.lastMessageDate),
                                style: TextStyle(color: AppColors.silver),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (_hasNewMessage)
                      ? Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.blue,
                    ),
                  )
                      : Container(),
                  Container(
                    padding: EdgeInsets.only(left:20, top:4),
                    child: Icon(
            Icons.camera_alt_outlined,
            color: AppColors.grey1040,
          ),
                  ),

                ],
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyView() => Padding(
        padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.emptyMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppStrings.emptyMessageBody,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppStrings.emptySend,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );

  Future<List<Conversation>> _getConversations() async {
    List<Conversation> conversations = [];
    var list = await ConversationService.getConversationsListForUser();
    for (String conversationId in list)
      conversations
          .add(await ConversationService.getConversation(conversationId));
    conversations
        .sort((a, b) => b.lastMessageDate.compareTo(a.lastMessageDate));
    return conversations;
  }

  Future<User> _getUser(String id) async => await UserServices.getUser(id);

  void onConversationTap(Conversation conversation, User user) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ConversationPage(
              toUser: user,
              fromUser: widget.currentUser,
            ),
          ),
        )
        .then((value) => _updateConversations());
  }

  void _updateConversations() {
    setState(() {
      _conversations = _getConversations();
    });
  }
  String _getLastMessage(String text){
    if (text.length >= 23)
    return "${text.substring(0, 22)}...";
    else return text;
  }
}
