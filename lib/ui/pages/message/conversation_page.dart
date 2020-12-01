import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instagram_clone/models/conversation.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/conversation_service.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/common_elements/loading_widget.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:instagram_clone/utils/extensions.dart';

class ConversationPage extends StatefulWidget {
  final User toUser;
  final User fromUser;

  ConversationPage({this.toUser, this.fromUser});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  TextEditingController _textController;
  User _toUser;
  User _fromUser;
  bool _newConversation = true;
  Stream _messages;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _toUser = widget.toUser;
    _fromUser = widget.fromUser;
    _checkConversationExists();
    _messages = _getMessagesStream();
    _resetNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () => Utils.navToUserDetails(context, _toUser),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: Utils.getProfilePic(_toUser.picture),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    _toUser.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              (!_newConversation)
                  ? Expanded(
                      child: Container(child: _getMessagesWidget()),
                    )
                  : Expanded(
                      child: Container(),
                    ),
              _getTextField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMessagesWidget() => StreamBuilder<QuerySnapshot>(
      stream: _messages,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget();
        } else {
          return ListView.builder(
              reverse: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Message message =
                    Message.fromMap(snapshot.data.docs[index].data());
                bool fromCurrent = (message.userId == _fromUser.id);
                return _buildMessagesList(message, fromCurrent);
              });
        }
      });

  Widget _buildMessagesList(Message message, bool fromCurrent) => Column(
        children: [
          (message.firstOfGroup) ? _getTime(message, fromCurrent) : Container(),
          _buildMessage(message, fromCurrent),
        ],
      );

  Widget _getTime(Message message, bool fromCurrent) {
    var time = DateFormat('d MMM, hh:mm').format(DateTime.parse(message.date));
    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 10), child: Text(time));
  }

  Widget _buildMessage(Message message, bool fromCurrent) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
        child: Align(
          alignment:
              (fromCurrent) ? Alignment.bottomRight : Alignment.bottomLeft,
          child: Container(
            decoration: BoxDecoration(
              color: (fromCurrent) ? AppColors.grey1010 : Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                  color: AppColors.grey1010, width: (fromCurrent) ? 0 : 1),
            ),
            padding: EdgeInsets.all(10),
            child: Text(message.body),
          ),
        ),
      );

  Widget _getTextField() => Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: TextField(
            controller: _textController,
            autocorrect: false,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              suffix: GestureDetector(
                onTap: () => _onSendTap(),
                child: Text(
                  "Send",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              hintText: "${AppStrings.message}...",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey1010, width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey1010, width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      );

  Stream<dynamic> _getMessagesStream() =>
      ConversationService.getMessagesSnapshot(
          Utils.getConversationId([_fromUser.id, _toUser.id]));

  void _checkConversationExists() async {
    Conversation conversation = await ConversationService.getConversation(
        Utils.getConversationId([_fromUser.id, _toUser.id]));

    setState(() {
      _newConversation = (conversation == null);
    });
  }

  void _onSendTap() async {
    String now = DateTime.now().toString();
    String conversationId = Utils.getConversationId([
      _fromUser.id,
      _toUser.id,
    ]);
    if (_newConversation) {
      _createConversation(now);
    }
    ConversationService.addMessage(
        conversationId,
        Message(
          userId: _fromUser.id,
          body: _textController.text,
          date: now,
          firstOfGroup:
              (_newConversation) ? true : await _isLastMessageOlderThan15min(),
        ));

    _isLastMessageOlderThan15min();
    if (!_newConversation) _updateNotifications(conversationId);

    setState(() {
      _newConversation = false;
      _textController.text = "";
    });
  }

  void _createConversation(String now) {
    ConversationService.createConversation(
      Conversation(
        user1: _fromUser.id,
        user2: _toUser.id,
        id: Utils.getConversationId([_fromUser.id, _toUser.id]),
        lastMessageDate: now,
        lastMessageBody: _textController.text,
        user1Notifications: 0,
        user2Notifications: 1,
      ),
    );
  }

  Future<bool> _isLastMessageOlderThan15min() async {
    Message lastMessage = await ConversationService.getLastMessage(
        Utils.getConversationId([_fromUser.id, _toUser.id]));
    return (DateTime.now()
            .difference(DateTime.parse(lastMessage.date))
            .inMinutes >=
        15);
  }

  // Set the notifications number to 0 for the current user
  void _resetNotifications() async {
    Conversation conversation = await _getConversation();
    ConversationService.resetNotifications(
        conversation.id, conversation.getCurrentNotificationsName);
  }

  Future<Conversation> _getConversation() async =>
      await ConversationService.getConversation(
          Utils.getConversationId([_fromUser.id, _toUser.id]));

  void _updateNotifications(String conversationId) =>
      ConversationService.oneMoreNotification(conversationId);
}
