
import 'package:flutter/material.dart';

import '../utils/SizeConfig.dart';

class Texty extends StatelessWidget{
 final  text;
 var label;
 var IsRequire;
  Texty({ Key? key,required this.text,required this.label,required this.IsRequire}) : super(key: key);
   //Texty({Key key, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
        return new Column(
       mainAxisAlignment: MainAxisAlignment.start,
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[

        Row(
            children: <Widget>[
             Text(
              label,
              style: TextStyle(color: Colors.blue),),
             if(IsRequire != null && IsRequire == "1")...[
              Text(
               " *",

               style: TextStyle(color: Colors.red),),
             ]
            ]),

        Container(
         padding: const EdgeInsets.all(0),
         width: SizeConfig.screenWidth! * 100 ,
         child:  Text(text),),

       ],
      );


  }
}