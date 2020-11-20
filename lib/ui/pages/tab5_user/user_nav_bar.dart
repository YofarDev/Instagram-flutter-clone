import 'package:flutter/material.dart';

class UserNavBar extends StatelessWidget {
   final int currentPage;
  final Function(int) onTabChange;
  UserNavBar({
    @required this.currentPage,
    @required this.onTabChange,
  });
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      elevation: 0,
      onTap: (n) => onTabChange(n),
    
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_on_outlined, color: (currentPage == 0)? Colors.black : Colors.grey,),
          label: "",  
        
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_outlined, color: (currentPage == 1)? Colors.black : Colors.grey,),
          label: "",
        ),
      ],
    );
  }
}
