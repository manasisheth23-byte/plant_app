

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/SizeConfig.dart';


class TextFieldControllPwd extends StatefulWidget{

  var myController = TextEditingController();
   var onfieldSubmited;
    TextFieldControllPwd({Key? key, required this.myController,this.onfieldSubmited}) : super(key: key);

  @override
  _TextFieldControllPwdState createState() => _TextFieldControllPwdState();
}

class _TextFieldControllPwdState extends State<TextFieldControllPwd> {
  @override
  Widget build(BuildContext context) {

     return new TextFormField(
          controller: widget.myController,
           onFieldSubmitted: widget.onfieldSubmited,
          keyboardType: TextInputType.text,
           // keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
          autofocus: false,
          obscureText: true,
      decoration: InputDecoration(
           hintText: "Enter Password",
           hintStyle: new TextStyle(color: Colors.grey,),
           contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
           border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0),gapPadding: 10, ),
           ),
           
      style: TextStyle(
        //color: Colors.blueAccent,
        fontSize: SizeConfig.safeBlockHorizontal! * 3,
        fontStyle: FontStyle.normal,
         ),
    

  //***DONT DELETE */
    //***** */Design for material design input text field

        // controller: widget.myController,
        //             keyboardType: TextInputType.text,
        //             autofocus: false,
        //             obscureText: true,
        //             decoration: InputDecoration(
        //                hintText: " ",
        //               labelText: "Enter Password",
        //              contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        //              ),
                                       
        //            // border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0),gapPadding: 10, ),
                  
       );    
  }
}

  

  


