import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/ui/common_elements/list_users/followers_following_page.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/utils/extensions.dart';

class HeaderUser extends StatelessWidget {
  final User user;

  HeaderUser(this.user);

  @override
  Widget build(BuildContext context) {
    double fontSizeTop = 20;
    double fontSizeBot = 16;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,

          children: [
            CircleAvatar(
              backgroundColor: AppColors.grey1010,
              radius: 45,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: Utils.getProfilePic(user.picture),
                radius: 44,
              ),
            ),
            // Publications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      user.publicationsId.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSizeTop),
                    ),
                    Text(
                      AppStrings.posts,
                      style: TextStyle(fontSize: fontSizeBot),
                    ),
                  ],
                ),
                // Followers
                GestureDetector(
                  onTap: () => _onFollowListTap(context, 0),
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(left:20, right:20),
                    child: Column(
                      children: [
                        Text(
                          user.followers.length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontSizeTop),
                        ),
                        Text(
                          AppStrings.followers,
                          style: TextStyle(fontSize: fontSizeBot),
                        ),
                      ],
                    ),
                  ),
                ),
                // Following
                GestureDetector(
                  onTap: () => _onFollowListTap(context, 1),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Text(
                          user.following.length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontSizeTop),
                        ),
                        Text(
                          AppStrings.following,
                          style: TextStyle(fontSize: fontSizeBot),
                        ),
                      ],
                    ),
                  ),
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
                  user.name.capitalizeFirstLetterOfWords,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.bio),
              ],
            ))
      ],
    );
  }

  void _onFollowListTap(BuildContext context, int index) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FollowersFollowingPage(
            user: user,
            indexOfTab: index,
          ),
        ),
      );
}
