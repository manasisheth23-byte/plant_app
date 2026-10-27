import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageViewControll extends StatelessWidget {

@override
  Widget build(BuildContext context) {
  return CircleAvatar(

child: Image.asset('assets/meeting.png'),
backgroundColor: Colors.transparent,
radius: 100,

);
}
/*
 Widget imageView (dynamic hin){
   return Image.asset('assets/images/lake.jpg'); //   <--- image here
 };*/

//set Circular Image
   Widget imageViewCircular(){

    return CircleAvatar(

        child: Image.asset('assets/meeting.png'),
        backgroundColor: Colors.transparent,
        radius: 100,

    );

         
   }

   //set Circular Image
   Widget imageView(){

     return new MaterialApp(
                home: new ImageIcon(
                          new AssetImage(
                              "assets/companylogo.png"),
                          size: 24.0,
                          color: Colors.white),
        );
    
     
   }
}