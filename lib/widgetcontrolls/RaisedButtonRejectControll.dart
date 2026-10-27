

import 'package:flutter/material.dart';

class RaisedButtonRejectControll extends StatefulWidget{
  final   onPressed;
  final btnText ;
  
   RaisedButtonRejectControll({Key? key, this.onPressed,this.btnText}) : super(key: key);

  @override
  _RaisedButtonRejectControllState createState() => _RaisedButtonRejectControllState();
}

class _RaisedButtonRejectControllState extends State<RaisedButtonRejectControll> {
  @override
  Widget build(BuildContext context) {
    
    return new ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor:Color((int.parse("#d15b47".substring(1, 7), radix: 16) + 0xFF000000)),
          padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(color: Colors.white)),
      onPressed:  widget.onPressed,

      child:  widget.btnText,
    );
    /*RaisedButton(
      onPressed: widget.onPressed,
      child: widget.btnText,
      color: Color((int.parse("#d15b47".substring(1, 7), radix: 16) + 0xFF000000)),
      padding: EdgeInsets.symmetric(horizontal: 100.0,vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10) ), 
      
      );*/
  }
}