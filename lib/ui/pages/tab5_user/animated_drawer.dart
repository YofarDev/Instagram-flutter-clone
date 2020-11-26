import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instagram_clone/res/colors.dart';
import 'package:instagram_clone/res/strings.dart';

class AnimatedDrawer extends StatefulWidget {
  final Key key;
  final Widget child;
  final String title;
  final List<Widget> items;

  AnimatedDrawer({
    this.key,
    @required this.child,
    @required this.title,
    @required this.items,
  });

  @override
  AnimatedDrawerState createState() => AnimatedDrawerState();
}

class AnimatedDrawerState extends State<AnimatedDrawer>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _screenTranslate;
  bool _open;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _open = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _open = (_controller.value == 1);
    return Stack(
      children: [
        // Drawer
        AnimatedBuilder(
          animation: _controller,
          child: _drawer(),
          builder: (context, child) {
            _screenTranslate = Tween<Offset>(
              begin: Offset(MediaQuery.of(context).size.width, 0),
              end: Offset(MediaQuery.of(context).size.width / 3, 0),
            ).animate(_controller);
            return Transform.translate(
              offset: _screenTranslate.value,
              child: child,
            );
          },
        ),

        // Main screen
        AnimatedBuilder(
          animation: _controller,
          child: _build(),
          builder: (BuildContext context, Widget child) {
            _screenTranslate = Tween<Offset>(
              begin: Offset(0, 0),
              end: Offset(-2 * MediaQuery.of(context).size.width / 3, 0),
            ).animate(_controller);
            return Transform.translate(
              offset: _screenTranslate.value,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: child,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _build() {
    var _dxStart;
    var _dxEnd;
    return GestureDetector(
      onTap: ()=>_closeDrawer(),
        onHorizontalDragStart: (details) {
          _dxStart = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          _dxEnd = details.globalPosition.dx;
          // To move the view while dragging
          _controller.value -=
              details.primaryDelta / MediaQuery.of(context).size.width;
        },
        onHorizontalDragEnd: (details) {
          if (_dxEnd == null) {

            if (_dxStart <= MediaQuery.of(context).size.width / 3) if (_open)
              _closeDrawer();
          } else {
            // We only change the state of the drawer
            // if the drag distance was > to screen width/10
            // and if the drag is in the correct way
            // (left to open, right to close)
            bool _minDrag = ((_dxEnd - _dxStart).abs() >=
                (MediaQuery.of(context).size.width * 0.1));
            bool _dragRight = (_dxEnd - _dxStart > 0);
            bool _change;

            if (_minDrag && _open && _dragRight)
              _change = true;
            else if (_minDrag && !_open && !_dragRight)
              _change = true;
            else
              _change = false;

            _changeState(_change);

            _dxStart = null;
            _dxEnd = null;
          }
        },
        child: widget.child);
  }

  Widget _drawer() => SizedBox(
        height: MediaQuery.of(context).size.height,
        width: 2 * MediaQuery.of(context).size.width / 3,
        child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: 1,
                  color: AppColors.grey1010,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        height: kToolbarHeight,
                        padding: EdgeInsets.only(left:20),
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: AppColors.grey1010,
                      ),
                      Expanded(
                        child: ListView(


                          children: widget.items,
                        ),
                      ),
                      Container(
                        height: 1,
                        color: AppColors.grey1010,
                      ),
                      Container(
                        color: Colors.white,
                        height: 47,
                        child: FlatButton.icon(
                          icon: Icon(Icons.settings),
                          label: Text(AppStrings.settings),
                          onPressed: () => onSettingsTap(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      );

  void onDrawerIconTap() {
    _open = (_controller.value == 1);
    if (_open)
      _closeDrawer();
    else
      _openDrawer();
  }
  
  void onSettingsTap(){}

  void _openDrawer() {
    _controller.forward();
    _open = true;
  }

  void _closeDrawer() {
    _controller.reverse();
    _open = false;
  }

  void _changeState(bool change) {
    // Change state
    if (change) {
      if (_open) {
        _closeDrawer();
        _open = false;
      } else {
        _openDrawer();
        _open = true;
      }
      // Keep state
    } else {
      if (_open)
        _openDrawer();
      else
        _closeDrawer();
    }
  }
}
