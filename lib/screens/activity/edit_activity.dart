import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/provider/edit_note_provider.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../models/LoginResponseModel.dart';
import 'activity_list_screen.dart';

class EditActivity extends StatefulWidget {
  const EditActivity({super.key, this.subject, this.content, this.activityid, required taskOwner, this.loginResponseModel});

  final String? subject;
  final String? content;
  final String? activityid;
  final LoginResponseModel? loginResponseModel;

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  late TextEditingController _subjectController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.subject);
    _contentController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _editNote() async {
    if (_subjectController.text.isEmpty) {
      showErrorSnackBar("Enter Subject");
      return;
    }

    if (_contentController.text.isEmpty) {
      showErrorSnackBar("Enter Content");
      return;
    }


    AlertDialog alert = AlertDialog(
      content: Row(children: [
        CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
        Container(
            margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
      ]),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    await Provider.of<EditNoteProvider>(context, listen: false).EditNote(
      _contentController.text,
      _subjectController.text,
      widget.activityid!,
      "E",
    );

    if (!mounted) return;
    Navigator.pop(context); //for dissmiss progres dialog

    _showAddedSnackbar('Note edited successfully!');
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 10),
        reverseTransitionDuration: const Duration(milliseconds: 10),
        pageBuilder: (_, animation, secondaryAnimation) =>
            ActivityListFragment(
              loginResponseModel: widget.loginResponseModel,),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );

   /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ActivityListFragment(
            loginResponseModel: widget.loginResponseModel,)),
    );*/

  //  Navigator.of(context).pop(true);
  }
  void _showAddedSnackbar(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      // You can also use Toast.LENGTH_SHORT
      gravity: ToastGravity.BOTTOM,
      // Position of the toast
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    AlertDialog alert = AlertDialog(
      content: Row(children: [
        CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
        Container(
            margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
      ]),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    await Provider.of<EditNoteProvider>(context, listen: false).EditNote(
      _contentController.text,
      _subjectController.text,
      widget.activityid!,
      "D",
    );

    if (!mounted) return;
    Navigator.pop(context); //for dissmiss progres dialog

    _showAddedSnackbar('Note deleted successfully!');
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 10),
        reverseTransitionDuration: const Duration(milliseconds: 10),
        pageBuilder: (_, animation, secondaryAnimation) =>
            ActivityListFragment(
              loginResponseModel: widget.loginResponseModel,),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
   /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ActivityListFragment(
            loginResponseModel: widget.loginResponseModel,)),
    );*/

  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
       //   Navigator.pop(context);
         /* Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ActivityListFragment(loginResponseModel: widget.loginResponseModel,)),
          );*/

          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  ActivityListFragment(loginResponseModel: widget.loginResponseModel,),
              transitionsBuilder: (_, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child:Center(
          child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
                  appBar: AppBar(
            backgroundColor: AppColors.APPCOLOR,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: Platform.isWindows ? true : false,


            leading: new IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () {
              //  Navigator.pop(context);
               /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      ActivityListFragment(
                        loginResponseModel: widget.loginResponseModel,)),
                );*/
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        ActivityListFragment(loginResponseModel: widget.loginResponseModel,),
                    transitionsBuilder: (_, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            title: const Text(
              "Edit Notes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (!_isLoading)
                IconButton(
                  tooltip: "Save",
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 28,
                  ),
                  onPressed: _editNote,
                ),
              if (!_isLoading)
                IconButton(
                  tooltip: "Delete",
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 28,
                  ),
                  onPressed: _deleteNote,
                ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
                  ),
              bottomNavigationBar: Builder(
                builder: (context) {
                  return NavigationBarTheme(
                    data: NavigationBarThemeData(
                      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                            (states) {
                          if (states.contains(MaterialState.selected)) {
                            return const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            );
                          }
                          return const TextStyle(
                            fontSize: 9,
                          );
                        },
                      ),
                    ),
                    child: NavigationBar(
                      selectedIndex: _idx,
                      onDestinationSelected: (index) async {
                        if (index == 3) {
                          showDialog( context: context, builder: (context) =>
                              AlertDialog( title: const Text("Coming Soon 🚀"),
                                content: const Text( "This feature is under development and will be available soon.", ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text("OK"), ), ], ), ); return; }
                        final plantName = context.read<PlantProvider>().plantName;
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 10),
                            reverseTransitionDuration: const Duration(milliseconds: 10),
                            pageBuilder: (_, animation, secondaryAnimation) =>
                                AppShell(
                                  role: "Admin",
                                  plant: plantName,
                                  selectedIndex: index,

                                ),
                            transitionsBuilder: (_, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                    /*    Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppShell(
                              role: "Admin",
                              plant: plantName,
                              selectedIndex: index,

                            ),
                          ),
                        );*/
                      },
                      height: 60,

                      backgroundColor: Colors.white,
                      indicatorColor: C.bluep,
                      destinations: [
                        const NavigationDestination(
                          icon: Icon(Icons.home_outlined, size: 30),
                          selectedIcon: Icon(Icons.home, color: C.blue, size: 30),
                          label: 'Home',
                        ),

                        /*const NavigationDestination(icon: Icon(Icons.grid_view_outlined,size: 30), selectedIcon: Icon(Icons.grid_view,size: 30, color: C.blue), label: 'Shop Floor'),*/
                        NavigationDestination(
                          icon: Badge( label: Text(unreadProvider.unreadCount.toString()), child: const Icon(Icons.notifications_outlined,size: 30)),
                          selectedIcon: const Icon(Icons.notifications,size: 30, color: C.blue),
                          label: 'Alerts',
                        ),
                        const NavigationDestination(icon: Icon(Icons.bar_chart_outlined,size: 30), selectedIcon: Icon(Icons.bar_chart,size: 30, color: C.blue), label: 'Reports'),
                        const NavigationDestination(icon: Icon(Icons.chat_bubble_outline,size: 30), selectedIcon: Icon(Icons.chat_bubble,size: 30, color: C.blue), label: 'Assistant'),
                        const NavigationDestination(
                          icon: Icon(Icons.person,size: 30),
                          selectedIcon: Icon(Icons.person,size: 30, color: C.blue),
                          label: 'Profile',
                        ),

                        /*const NavigationDestination(
                          icon: Icon(Icons.menu,size: 30),
                          selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                          label: 'More',
                        ),*/

                      ],
                    ),
                  );
                }
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Center(
                    child: Container(
                     /* width: Platform.isAndroid
                          ? double.infinity
                          : MediaQuery.of(context).size.width * 0.40,*/
                      decoration: Platform.isAndroid
                          ? null
                          : BoxDecoration(
                        color: const Color(0xFFF6F9FC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _buildSectionTitle(
                              "Subject",
                              required: true,
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _subjectController,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter Subject",
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.APPCOLOR.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.subject_outlined,
                                    color: AppColors.APPCOLOR,
                                    size: 20,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.APPCOLOR,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildSectionTitle(
                              "Content",
                              required: true,
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _contentController,
                              minLines: 5,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter Content",
                                alignLabelWithHint: true,
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.APPCOLOR.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: AppColors.APPCOLOR,
                                    size: 20,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.APPCOLOR,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                 /* body: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Container(
                width: Platform.isAndroid
                    ? double.infinity
                    : MediaQuery.of(context).size.width * 0.4,
                decoration: Platform.isAndroid
                    ? null
                    : BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Subject",
                          style: TextStyle(color: Colors.blue)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("Content",
                          style: TextStyle(color: Colors.blue)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
                  ),*/
                ),
          ),
        ));
  }
  Widget _buildSectionTitle(
      String title, {
        bool required = false,
      }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF12426E),
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
