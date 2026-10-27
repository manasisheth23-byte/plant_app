


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/SizeConfig.dart';

class DecimalNumber extends StatefulWidget {

  var label;
  var IsRequire;
  var value;
  var textStyle = TextStyle();
  TextEditingController inputController;
  DecimalNumber({Key? key,  required this.textStyle,required this.value,required this.inputController,required this.label,required this.IsRequire}) : super(key: key){
    if(value != null && value != "null") {
      inputController.text = value;
    }
  }



  @override
  _DecimalNumberControllState createState() => _DecimalNumberControllState();
}

class _DecimalNumberControllState extends State<DecimalNumber> {


  @override
  Widget build(BuildContext context) {

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Row(
            children: <Widget>[
              Text(
                widget.label,
                style: TextStyle(color: Colors.blue),),
              if(widget.IsRequire != null && widget.IsRequire == "1")...[
                Text(
                  " *",

                  style: TextStyle(color: Colors.red),),
              ]
            ]),
        Container(
          padding: const EdgeInsets.all(8),
          width: SizeConfig.screenWidth! * 100 ,
          child: TextField(
            controller: widget.inputController,
            decoration: InputDecoration(labelText: ''),
            textAlign: TextAlign.start,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),

        ),

      ],
    );
  }


}