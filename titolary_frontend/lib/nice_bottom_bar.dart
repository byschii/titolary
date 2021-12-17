
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NiceBottomBar extends StatelessWidget {

  final int selectedIndex;
  final double iconSize;
  final Color backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<NiceBottomBarItem> items;
  final ValueChanged<int> onItemSelected;

  NiceBottomBar(
      {Key key,
        this.selectedIndex = 0,
        this.showElevation = true,
        this.iconSize = 20,
        this.backgroundColor,
        this.animationDuration = const Duration(milliseconds: 270),
        @required this.items,
        @required this.onItemSelected}) {
    assert(items != null);
    assert(items.length >= 2 && items.length <= 5);
    assert(onItemSelected != null);
  }

  Widget _buildItem(NiceBottomBarItem item, bool isSelected) {
    return AnimatedContainer(
      width: isSelected ? 120 : 50,
      height: double.maxFinite,
      duration: animationDuration,
      // margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: isSelected ? item.activeColor.withOpacity(0.19) : backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child: /*ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: <Widget>[*/
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildIconAndText(item, isSelected)
          ),
        /*],
      ),*/
    );
  }


  List<Widget> _buildIconAndText(NiceBottomBarItem item, bool isSelected){
    List<Widget> couple = [];


    Widget tabIcon2 = Container(
      //width: 55,
      // color: Colors.green,
      // padding: EdgeInsets.only(left:1, right: 1),
      child: IconTheme(
        data: IconThemeData(
          size: iconSize,
          color: isSelected
            ? item.activeColor.withOpacity(1) : item.inactiveColor == null
            ? item.activeColor : item.inactiveColor
        ),
        child: Expanded(
          flex: 4,
          child:Container(
            //color:Colors.green,
            
            child: item.icon,
          )
        )
      ),
    );


    Widget tabText2 = isSelected 
      ? DefaultTextStyle.merge(
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: item.activeColor,
          fontWeight: FontWeight.bold
        ),
        child: Expanded(
          flex: 9,
          child:Container(
            height:20,
            //color: Colors.green,
            padding: EdgeInsets.only(right:15),
            child: Center(
              child:item.title)
          )
        )
      ) : SizedBox.shrink();


    Widget padding = Expanded(
      flex:1, 
      child: Container(
        width: 1,
        //color:Colors.green
        )
    );

    couple.addAll([padding, tabIcon2, tabText2, padding] );
    return couple;
  }


  @override
  Widget build(BuildContext context) {
    final bgColor = (backgroundColor == null) ? Theme.of(context).bottomAppBarColor : backgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          if(showElevation) BoxShadow(color: Colors.black12, blurRadius: 2)
        ]
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: 60,
          padding: EdgeInsets.only(left: 10, right: 10, top: 9, bottom: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              var index = items.indexOf(item);
              return GestureDetector(
                onTap: () {
                  onItemSelected(index);
                },
                child: _buildItem(item, selectedIndex == index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NiceBottomBarItem {
  final Icon icon;
  final Text title;
  final Color activeColor;
  final Color inactiveColor;

  NiceBottomBarItem({@required this.icon, @required this.title,
        this.activeColor = Colors.blue, this.inactiveColor}) {
    assert(icon != null);
    assert(title != null);
  }
}


