
import 'package:erpflutter/database/app_preferences.dart';
import 'package:erpflutter/provider/chat_viewmodel.dart';
import 'package:erpflutter/provider/themecontroller.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController controller =
  TextEditingController();
  final ScrollController _scrollController =
  ScrollController();
  late stt.SpeechToText speech;
  String? userName;
  bool isListening = false;
  String selectedProjectNo = "";
  String selectedProjectName = "";
  bool showProjectList = false;
  TextEditingController projectSearchController =
  TextEditingController();

  String projectSearchText = "";
  List<dynamic> getFilteredProjects(
      List<dynamic> projects,
      )
  {

    if(projectSearchText.trim().isEmpty){
      return projects;
    }

    return projects.where((e) {

      final search =
      projectSearchText.toLowerCase();

      return

        e.projDesc
            .toString()
            .toLowerCase()
            .contains(search)

            ||

            e.projNo
                .toString()
                .toLowerCase()
                .contains(search);

    }).toList();
  }
  void scrollToBottom() {

    Future.delayed(
      const Duration(milliseconds: 300),
          () {

        if (_scrollController.hasClients) {

          _scrollController.animateTo(

            _scrollController.position.maxScrollExtent +

                200,

            duration: const Duration(
              milliseconds: 400,
            ),

            curve: Curves.easeOut,
          );
        }
      },
    );
  }
 /* final List<Map<String, dynamic>> messages = [
    {
      "isBot": true,
      "message":
      "Welcome back! You have 3 overdue tasks and 2 escalations that need your attention today."
    }
  ];
*/
  final List<String> suggestions = [
    "What's my buffer status?",
    "Why is ERP delayed?",
    "Show overdue tasks",
    "Explain fever chart",
    "Recovery % for i-TEK?",
  ];


  Future<void> startListening() async {

    print("Initializing speech");

    bool available = await speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");
      },
      onError: (error) {
        print("Speech error: $error");
      },
    );

    print("Speech available: $available");

    if (available) {

      setState(() {
        isListening = true;
      });

      speech.listen(

            onResult: (result) {

              print("Words: ${result.recognizedWords}");

              setState(() {

                controller.text = result.recognizedWords;
              });

              if (result.finalResult) {

                setState(() {
                  isListening = false;
                });

                print("Final result received");
              }
            },
      );

    } else {

      print("Speech recognition not available");
    }
  }
  Future<void> _loadUser() async {
    userName = await AppPreferences.getUserName();
    setState(() {});
  }
  String? date;
  late ThemeController themeController;
  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    _loadUser();
   date = DateFormat(
      "dd MMM yyyy · hh:mm a",
    ).format(DateTime.now());
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      final vm = context.read<ChatViewModel>();

      vm.createSession( ProjectNo:"NA");

     // vm.loadProjects();

    });
  }
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    themeController = Provider.of<ThemeController>(context, listen: false);
    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      scrollToBottom();
    });

    return Scaffold(
      backgroundColor: isDesktop
          ?  Colors.white // dark app background for Windows/Desktop
          : const Color(0xFFF5F7FB), // light app background for mobile
      body: SafeArea(
    child:LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isMobile = width < 600;
        final bool isTablet = width >= 600 && width < 1000;
        final bool isDesktop = width >= 1000;

        final double horizontalPadding =
        isDesktop ? 24 : isTablet ? 18 : 14;

        final double verticalPadding =
        isDesktop ? 18 : 14;

        final double iconSize =
        isDesktop ? 24 : isTablet ? 22 : 18;

        final double avatarSize =
        isDesktop ? 54 : isTablet ? 46 : 38;

        final double headingFont =
        isDesktop ? 22 : isTablet ? 19 : 16;

        final double bodyFont =
        isDesktop ? 15 : isTablet ? 13 : 12;

        final double smallFont =
        isDesktop ? 13 : isTablet ? 11 : 10;

        final double chatBubbleWidth =
        isDesktop
            ? 500
            : isTablet
            ? 420
            : width * .8;

        return Center(
          child: ConstrainedBox(

            constraints: BoxConstraints(
              maxWidth: isDesktop ? 700 : double.infinity,

            ),
            child:  Container(
                color: const Color(0xFFF5F7FB),
                child:Column(

              children: [

                /// HEADER
           /*     Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  color: themeController.darkColor,
                  child: Row(
                    children: [

                      SizedBox(width: 5),

                      Container(
                        height: avatarSize,
                        width: avatarSize,
                        decoration: BoxDecoration(
                          color: themeController.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white12,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: const Color(0xff60A5FA),
                          size: iconSize,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Cloud9 Assistant",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: headingFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              "● Powered by Cloud9 AI",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: smallFont,
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          selectedProjectName = "";
                          context.read<ChatViewModel>()
                              .createSession(ProjectNo: "NA");
                        },
                        child: Container(
                          height: iconSize + 12,
                          width: iconSize + 12,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),*/

                /// MESSAGES AREA
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 14,
                    ),
                    children: [

                      /// DATE
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              themeController.primaryColor,
                              Colors.white,
                              0.9,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            date ?? "",
                            style: TextStyle(
                              color: themeController.primaryColor,
                              fontSize: smallFont,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// WELCOME BLOCK
                      Column(
                        children: [

                          Container(
                            height: avatarSize + 14,
                            width: avatarSize + 14,
                            decoration: BoxDecoration(
                              color: themeController.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: const Color(0xff60A5FA),
                              size: iconSize + 8,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "Hello, ${userName ?? ""}! 👋",
                            style: TextStyle(
                              fontSize: headingFont,
                              fontWeight: FontWeight.w600,
                              color: themeController.darkColor,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Text(
                              "I'm your Cloud9 Business Suite AI Assistant. Ask me about projects, buffers, delays, escalations, or TOC concepts.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.lerp(
                                  themeController.primaryColor,
                                  themeController.primaryColor,
                                  0.9,
                                ),
                                fontSize: bodyFont,
                                height: 1.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              buildChip("Buffer Health"),
                              buildChip("Task Analysis"),
                              buildChip("CCPM Concepts"),
                              buildChip("Escalation Help"),
                              buildChip("MIS Reports"),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// CHAT MESSAGES
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: context.watch<ChatViewModel>().messages.length,
                        itemBuilder: (context, index) {

                          final message =
                          context.watch<ChatViewModel>().messages[index];

                          bool isBot = message["isBot"];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isBot
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [

                                if (isBot)
                                  Container(
                                    height: avatarSize - 8,
                                    width: avatarSize - 8,
                                    decoration: BoxDecoration(
                                      color: themeController.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: const Color(0xff93C5FD),
                                      size: iconSize - 4,
                                    ),
                                  ),

                                if (isBot)
                                  const SizedBox(width: 8),

                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: chatBubbleWidth,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isBot
                                          ? Colors.white
                                          : themeController.primaryColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomRight:
                                        Radius.circular(isBot ? 16 : 4),
                                        bottomLeft:
                                        Radius.circular(isBot ? 4 : 16),
                                      ),
                                      border: isBot
                                          ? Border.all(
                                        color: const Color(0xffE2E8F0),
                                      )
                                          : null,
                                    ),
                                    child: Text(
                                      message["message"].toString(),
                                      softWrap: true,
                                      style: TextStyle(
                                        color: isBot
                                            ? themeController.primaryColor
                                            : Colors.white,
                                        fontSize: bodyFont,
                                        height: 1.55,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                /// LOADING INDICATOR
                if (context.watch<ChatViewModel>().isLoadingmsg)

                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        // BOT AVATAR
                        Container(
                          height: avatarSize - 8,
                          width: avatarSize - 8,
                          decoration: BoxDecoration(
                            color: themeController.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: const Color(0xff93C5FD),
                            size: iconSize - 2,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // THINKING BUBBLE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(4),
                            ),
                            border: Border.all(
                              color: const Color(0xffE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              SizedBox(
                                height: 10,
                                width: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Thinking...",
                                style: TextStyle(
                                  color: const Color(0xff64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                /// PROJECT SELECTION
                /// PROJECT SELECTION
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// SELECT PROJECT BUTTON
                      InkWell(
                        onTap: () {
                          setState(() {
                            showProjectList = !showProjectList;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color.lerp(
                                themeController.primaryColor,
                                Colors.white,
                                0.9,
                              )!,
                            ),
                          ),
                          child: Row(
                            children: [

                              Icon(
                                Icons.folder_special,
                                color: themeController.primaryColor,
                                size: 20,
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  selectedProjectName.isEmpty
                                      ? "Select Project"
                                      : selectedProjectName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: themeController.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              Icon(
                                showProjectList
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: themeController.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (showProjectList)
                        Column(
                          children: [

                            /// SEARCH BOX
                            Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color.lerp(
                                    themeController.primaryColor,
                                    Colors.white,
                                    0.9,
                                  )!,
                                ),
                              ),
                              child: TextField(
                                controller: projectSearchController,
                                onChanged: (value) {
                                  setState(() {
                                    projectSearchText = value;
                                  });
                                },
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Search Project",
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: themeController.primaryColor,
                                  ),

                                  suffixIcon: projectSearchText.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      projectSearchController.clear();

                                      setState(() {
                                        projectSearchText = "";
                                      });
                                    },
                                  )
                                      : null,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// PROJECT CHIPS
                            /* Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: getFilteredProjects(
                                context.watch<ChatViewModel>().projectList,
                              ).map<Widget>((e) {

                                bool isSelected =
                                    selectedProjectNo == e.projNo.toString();

                                return InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () async {

                                    selectedProjectNo = e.projNo.toString();
                                    selectedProjectName = e.projDesc.toString();

                                    showProjectList = false;

                                    setState(() {});

                                    await context
                                        .read<ChatViewModel>()
                                        .createSession(
                                      ProjectNo: selectedProjectNo,
                                    );

                                    scrollToBottom();
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? themeController.primaryColor
                                          : const Color(0xffEFF6FF),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Color.lerp(
                                          themeController.primaryColor,
                                          Colors.white,
                                          0.7,
                                        )!,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        Icon(
                                          Icons.business_center,
                                          size: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : themeController.primaryColor,
                                        ),

                                        const SizedBox(width: 6),

                                        Text(
                                          e.projDesc.toString(),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : themeController.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),*/
                          ],
                        ),
                    ],
                  ),
                ),

                /// QUICK QUESTIONS
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// HEADER
                      Text(
                        "Suggested questions",
                        style: TextStyle(
                          color: Color.lerp(
                            themeController.primaryColor,
                            Colors.white,
                            0.2,
                          ),
                          fontSize: 12, // slightly larger for desktop readability
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// QUESTIONS LIST
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: context.watch<ChatViewModel>().questionList.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: quickChip(
                                text: e["DISPLAYMSG"].toString(),
                                code: e["CODE"].toString(),
                                message: e["MESSAGE"].toString(), context: context,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                /// INPUT BAR
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      /// MICROPHONE BUTTON
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () async {
                          var status = await Permission.microphone.request();

                          if (status.isGranted) {
                            if (isListening) {
                              await speech.stop();

                              setState(() {
                                isListening = false;
                              });
                            } else {
                              startListening();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Microphone permission denied"),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: isListening ? 55 : 45,
                          width: isListening ? 55 : 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isListening
                                ? Colors.red
                                : const Color(0xffF1F5F9),
                            boxShadow: isListening
                                ? [
                              BoxShadow(
                                color: Colors.red,
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ]
                                : [],
                          ),
                          child: Icon(
                            isListening
                                ? Icons.mic
                                : Icons.mic_none,
                            color: isListening
                                ? Colors.white
                                : Colors.black54,
                            size: isListening ? 28 : 22,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// TEXTFIELD
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffF8FAFC),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xffE2E8F0),
                                ),
                              ),
                              child: TextField(
                                controller: controller,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,

                                onSubmitted: (value) async {
                                  if (value.trim().isEmpty) return;

                                  String text = value;

                                  controller.clear();

                                  await context.read<ChatViewModel>().sendMessage(
                                    message: text,
                                    projectNo: selectedProjectNo ?? "NA",
                                  );

                                  scrollToBottom();
                                },

                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Ask about your projects...",
                                  hintStyle: TextStyle(
                                    color: Color.lerp(
                                      themeController.primaryColor,
                                      Colors.white,
                                      0.6,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            if (isListening)
                              const Padding(
                                padding: EdgeInsets.only(
                                  top: 5,
                                  left: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    Icon(
                                      Icons.mic,
                                      color: Colors.red,
                                      size: 14,
                                    ),

                                    SizedBox(width: 5),

                                    Text(
                                      "Listening...",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// SEND BUTTON
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () async {

                          if (controller.text.trim().isEmpty) return;

                          String text = controller.text;

                          controller.clear();

                          await context.read<ChatViewModel>().sendMessage(
                            message: text,
                            code: "",
                            projectNo: selectedProjectNo ?? "NA",
                          );

                          scrollToBottom();
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: themeController.darkColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ),
        );
      },
    ),


    ),

      /// BOTTOM NAVIGATION
      /*bottomNavigationBar:isDesktop ?
      Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isDesktop ? 700 : double.infinity,
              child: CustomBottomBar(
                currentIndex: 4,
                onTap: (index) {
                  if (index == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MyTasksScreen(),
                      ),
                    );
                  } else if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const HomeDashboardScreen(),
                      ),
                    );
                  } else if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const ActionListScreen(),
                      ),
                    );
                   // screen = const ActionListScreen();
                  } else if (index == 3) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportsListScreen(),
                      ),
                    );
                  }
                  else if(index == 4){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  const ChatBotScreen(),
                      ),
                    );

                  }
                  else if(index == 5){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>   ProfileScreen(),
                      ),
                    );

                  }else if (index == 6){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>       AlertsScreen(),
                      ),
                    );

                  }
                },
              ),
            ),
          ],
        ),
      ):
      CustomBottomBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MyTasksScreen(),
              ),
            );
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const HomeDashboardScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const ActionListScreen(),
              ),
            );
            // screen = const ActionListScreen();
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReportsListScreen(),
              ),
            );
          }
          else if(index == 4){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>  const ChatBotScreen(),
              ),
            );

          }
          else if(index == 5){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>   ProfileScreen(),
              ),
            );

          }else if (index == 6){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>       AlertsScreen(),
              ),
            );

          }
        },
      ),*/
    );
  }
  Widget quickChip({
    required BuildContext context,
    required String text,
    required String code,
    required String message,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await context.read<ChatViewModel>().sendMessage(
            message: message,
            code: code,
            projectNo: selectedProjectNo ?? "NA",
          );
          scrollToBottom();
        },
        child: Container(
          margin: const EdgeInsets.only(right: 6), // horizontal spacing
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xffEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(
                themeController.primaryColor,
                Colors.white,
                0.7,
              )!,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: themeController.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChip(String text, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xffF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xff475569),
            ),
          ),
        ),
      ),
    );
  }}