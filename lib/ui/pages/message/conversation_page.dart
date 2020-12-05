import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/models/conversation.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/database/conversation_service.dart';
import 'package:instagram_clone/services/database/user_services.dart';
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
  bool _isWriting;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _toUser = widget.toUser;
    _fromUser = widget.fromUser;
    _isWriting = false;
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
          actions: [
            IconButton(
              icon: Icon(Icons.videocam_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
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
                Message nextMessage = (index > 0)
                    ? Message.fromMap(snapshot.data.docs[index - 1].data())
                    : null;
                bool fromCurrent = (message.userId == _fromUser.id);
                if (message.userId == _toUser.id) _resetNotifications();
                return _buildMessagesList(message, nextMessage, fromCurrent);
              });
        }
      });

  Widget _buildMessagesList(
          Message message, Message nextMessage, bool fromCurrent) =>
      Column(
        children: [
          (message.firstOfGroup) ? _getTime(message, fromCurrent) : Container(),
          (!fromCurrent)
              ? Row(
                  children: [
                    (_displayProfilePicture(message, nextMessage))
                        ? SizedBox(
                            width: 40,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    Utils.getProfilePic(_toUser.picture),
                              ),
                            ),
                          )
                        : SizedBox(width: 40),
                    _buildMessage(message, fromCurrent),
                  ],
                )
              : _buildMessage(message, fromCurrent),
        ],
      );

  Widget _getTime(Message message, bool fromCurrent) {
    var date = DateTime.parse(message.date);
    var time;
    if (date.isToday())
      time = "${AppStrings.today}, ${DateFormat('hh:mm a').format(date)}";
    else
      time = DateFormat('d MMM, hh:mm a').format(date);

    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 12),
        child: Text(
          time,
          style: TextStyle(color: Colors.grey),
        ));
  }

  Widget _buildMessage(Message message, bool fromCurrent) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
        child: Align(
          alignment:
              (fromCurrent) ? Alignment.bottomRight : Alignment.bottomLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: 2 * MediaQuery.of(context).size.width / 3),
            decoration: BoxDecoration(
              color: (fromCurrent) ? AppColors.grey1010 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.grey1010, width: (fromCurrent) ? 0 : 1),
            ),
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text(
              message.body,
            ),
          ),
        ),
      );

  Widget _getTextField() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) {
              setState(() {
                _isWriting = value.length>0;
              });
            },
            controller: _textController,
            autocorrect: false,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: "${AppStrings.message}...",
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey1010, width: 1),
                borderRadius: BorderRadius.circular(40),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey1010, width: 1),
                borderRadius: BorderRadius.circular(40),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.blue),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: (!_isWriting)
                    ? SizedBox(
                        width: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.mic_none_outlined,
                              color: Colors.black,
                              size: 25,
                            ),
                            Icon(
                              Icons.image_outlined,
                              color: Colors.black,
                              size: 25,
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => _onSendTap(),
                        child: SizedBox(
                          width: 25,
                          child: Center(
                            child: Text(
                              AppStrings.send,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
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
    FocusScope.of(context).unfocus();
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

  bool _displayProfilePicture(Message message, Message nextMessage) {
    bool display;
    if (message.userId == _fromUser.id)
      display = false;
    else if (nextMessage == null)
      display = true;
    else if (message.userId == _toUser.id && nextMessage.userId == _fromUser.id)
      display = true;
    else if (nextMessage.firstOfGroup)
      display = true;
    else
      display = false;
    return display;
  }
}
