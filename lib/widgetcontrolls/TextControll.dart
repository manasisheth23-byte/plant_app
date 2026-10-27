


import 'package:flutter/material.dart';

class TextControll extends StatefulWidget {


  var value;
  var textStyle = TextStyle();

    TextControll({Key? key,  required this.textStyle,this.value}) : super(key: key);

  @override
  _TextControllState createState() => _TextControllState();
}

class _TextControllState extends State<TextControll> {
  @override
  Widget build(BuildContext context) {

        return new Text(
             widget.value,
             style: widget.textStyle,
             
             
             

             
    );
  }

// @override
//   Widget build(BuildContext context) => null;
  
 
//   Widget text(dynamic txtValue){
    
//      return Text("$txtValue",
//      style:  TextStyle(
//         color: Colors.black,
//         fontSize: SizeConfig.safeBlockHorizontal * 2,
//         fontStyle: FontStyle.normal,       
//     ),
//     );
    
     
  



// }
}