import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/user_services.dart';
import 'package:instagram_clone/ui/pages/edit_profile/edit_app_bar.dart';
import 'package:instagram_clone/ui/pages/edit_profile/screen_input.dart';
import 'package:instagram_clone/ui/pages_holder.dart';
import 'package:instagram_clone/utils/utils.dart';

class EditProfile extends StatefulWidget {
  final User currentUser;

  EditProfile(this.currentUser);

  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _nameController;
  TextEditingController _usernameController;
  TextEditingController _bioController;
  List<TextEditingController> _controllers = [];
  User _userUpdated;

  @override
  void initState() {
    super.initState();
    _userUpdated = widget.currentUser;
    _initControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            _appBar(),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          Utils.getProfilePic(_userUpdated.picture),
                      radius: 50,
                    ),
                    GestureDetector(
                      onTap: ()=>_changePicture(),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                        ),
                        child: Text(
                          AppStrings.changePhoto,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// NAME ///
                          Text(
                            AppStrings.name,
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => _onInputTap(
                                context, 0, AppStrings.name, _userUpdated.name),
                            child: TextField(
                              controller: _nameController,
                              enabled: false,
                            ),
                          ),
                          Container(
                            height: 20,
                          ),

                          /// PSEUDO ///
                          Text(
                            AppStrings.username,
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => _onInputTap(context, 1,
                                AppStrings.username, _userUpdated.username),
                            child: TextField(
                              controller: _usernameController,
                              enabled: false,
                            ),
                          ),
                          Container(
                            height: 20,
                          ),

                          /// BIO ///
                          Text(
                            AppStrings.bio,
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => _onInputTap(context, 2,
                                AppStrings.username, _userUpdated.bio),
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: _bioController,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget _appBar() => SliverAppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        pinned: true,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: 40,
            color: Colors.black87,
          ),
          onPressed: () => {Navigator.of(context).pop()},
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(
              right: 30,
            ),
            icon: Icon(
              Icons.check,
              size: 40,
              color: Colors.blue,
            ),
            onPressed: () => _uploadUpdatedUser(),
          ),
        ],
      );

  void _onInputTap(
      BuildContext context, int index, String inputName, String inputText) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) {
          return ScreenInput(inputName, inputText);
        },
        transitionDuration: Duration(seconds: 0),
      ),
    ).then((value) {
      _controllers[index].text = value;
      _updateUserObject(index, value);
    });
  }

  void _updateUserObject(int index, String newValue) {
    switch (index) {
      case 0:
        {
          _userUpdated.name = newValue;
        }
        break;
      case 1:
        {
          _userUpdated.username = newValue;
        }
        break;
      case 2:
        {
          _userUpdated.bio = newValue;
        }
        break;
    }
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.currentUser.name);
    _usernameController =
        TextEditingController(text: widget.currentUser.username);
    _bioController = TextEditingController(text: widget.currentUser.bio);
    _controllers = [
      _nameController,
      _usernameController,
      _bioController,
    ];
  }

  void _uploadUpdatedUser() async {
    await UserServices.updateUserProfile(_userUpdated);
    Navigator.of(context).pop("update");
  }

  void _changePicture(){

  }
}
