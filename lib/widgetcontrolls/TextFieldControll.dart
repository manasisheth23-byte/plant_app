




import 'package:flutter/material.dart';

import '../utils/SizeConfig.dart';

class TextFieldControll extends StatefulWidget{
  var myController = TextEditingController();
  var inputdecoration = InputDecoration();
    var onfieldSubmited;
  
  var enable = true;

    TextFieldControll({Key? key, required this.myController,required this.inputdecoration,required this.enable,this.onfieldSubmited}) : super(key: key);

  @override
  _TextFieldControllState createState() => _TextFieldControllState();
}

class _TextFieldControllState extends State<TextFieldControll> {
  @override
  Widget build(BuildContext context) {

        return new TextFormField(
           
            controller: widget.myController,
            decoration: widget.inputdecoration,
            onFieldSubmitted: widget.onfieldSubmited,
            textInputAction: TextInputAction.next,
            

            // for muliline purpose
             keyboardType: TextInputType.text,
            // keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
            
             maxLength: null,
             maxLines: null,
             enabled: widget.enable,

             style: TextStyle(
        //color: Colors.blueAccent,
        fontSize: SizeConfig.safeBlockHorizontal! * 3,
        fontStyle: FontStyle.normal,
        
         ),
         
                    // decoration: InputDecoration(
                    // border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0),gapPadding: 10, ),
                    //   hintText: 'Enter company code',
                    //   hintStyle: TextStyle(color: Colors.grey),
                    // )
    );
  }
}