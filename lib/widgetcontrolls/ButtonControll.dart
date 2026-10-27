

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/SizeConfig.dart';


class ButtonControll extends StatelessWidget {
  var btntxt;


@override
  Widget build(BuildContext context) {
  return
    ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor:Colors.blue,
          padding: EdgeInsets.symmetric( vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(color: Colors.white)),
      onPressed: () {


      },

      child:  Text("$btntxt",
        style: TextStyle( fontSize: SizeConfig.safeBlockHorizontal! * 3,),),
    );
}
  

   Widget button(dynamic btntxt){
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor:Colors.blue,
            padding: EdgeInsets.symmetric( vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(color: Colors.white)),
        onPressed: () {


        },

        child:  Text("$btntxt",
          style: TextStyle( fontSize: SizeConfig.safeBlockHorizontal! * 3,),),
      );
   }

   Widget okButton(dynamic btntxt){

      return
       /* RaisedButton(
      child: Text("$btntxt"),
      color: Colors.green,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
       onPressed: ()
        {

        },
    );*/
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor:Colors.green,
              padding: EdgeInsets.symmetric( vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(color: Colors.white)),
          onPressed: () {


          },

          child:  Text("$btntxt",
          ),
        );
   }

   Widget rejectButton(dynamic btntxt){

      return
        /*RaisedButton(
      child: Text("$btntxt"),
      color: Colors.red,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
       onPressed: ()
        {

        },
    );*/

        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor:Colors.red,
              padding: EdgeInsets.symmetric( vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(color: Colors.white)),
          onPressed: () {


          },

          child:  Text("$btntxt",
          ),
        );
   }


   Widget floatingButton(dynamic btntxt){
     return FloatingActionButton(
         onPressed: () {
            
          },
          child: new ConstrainedBox(
            constraints: new BoxConstraints.expand(),
            child: Image.asset('assets/partner.png'),
          ),
       
     );

   }

  

  
  
  
  
  }

