import 'package:flutter/material.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/ui/pages/edit_profile/edit_app_bar.dart';

class ScreenInput extends StatefulWidget {
  final String inputName;
  final String inputText;
  ScreenInput(this.inputName, this.inputText);

  _ScreenInputState createState() => _ScreenInputState();
}

class _ScreenInputState extends State<ScreenInput> {
  TextEditingController controller;
  String textChanged;
  @override
  void initState() {
    super.initState();
    textChanged = widget.inputText;
    controller = TextEditingController(text: textChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          EditAppBar(
            title: widget.inputName,
            inputText: textChanged,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: 35,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.inputName,
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    
                    controller: controller,
                    onChanged: (value) => setState(() {
                      textChanged = value;
                    }),
                    cursorColor: AppColors.darkGreen,
                    cursorWidth: 2,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grey50),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grey50),
                      ),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
