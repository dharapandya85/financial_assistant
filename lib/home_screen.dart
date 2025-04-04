import 'package:flutter/material.dart';
//import 'package:bubble/bubble.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main(){
  runApp(AIAssistantApp());
}
class AIAssistantApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home:HomeScreen(),
    );
  }
}
class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState()=> _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>{
//defining some properties and variables
// we need state key for animated list state
final TextEditingController _controller = TextEditingController();
final GlobalKey<AnimatedListState> _listKey=GlobalKey<AnimatedListState>();
 List<String> _messages = [];

// in flask app we defined the route for our query i.e., /bot


Future<void> sendMessage(String message) async {

  if(message.trim().isEmpty) return;
  setState(() {
    _messages.add("You:$message");

  });
  _listKey.currentState?.insertItem(_messages.length - 1);
  final Uri url = Uri.parse("https://web-production-5bb8.up.railway.app/bot");
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json",

      },
      body: jsonEncode({"message": message}),
    );
    if (response.statusCode == 200) {
      var botReply = jsonDecode(response.body);
      setState(() {
        _messages.add("AI: $botReply");

      });
      _listKey.currentState?.insertItem(_messages.length - 1);
    }
    else {
      setState(() {
        _messages.add("AI: Error processing request.Status: ${response.statusCode}");

      });
      _listKey.currentState?.insertItem(_messages.length - 1);
    }
  } catch (e) {
    setState(() {
      _messages.add("AI: Failed to connect");

    });
    _listKey.currentState?.insertItem(_messages.length - 1);

  }
  _controller.clear();
//TextEditingController queryController = TextEditingController();
}

@override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300],
    appBar: AppBar(
      backgroundColor: Colors.blue,
      centerTitle: true,
      title: Text(
          "Chatbot",
      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: AnimatedList(
            key:_listKey,
            reverse: true,
            padding: EdgeInsets.all(10),

            itemBuilder: (context, index,animation) {

              return SizeTransition(
                sizeFactor:animation,
                child:Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Container(

                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _messages[index].startsWith("You:")
                          ? Colors.blueGrey.shade800
                          : Colors.green.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index],
                      style: GoogleFonts.robotoMono(
                        fontSize:16,
                        color:Colors.white,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ask something...",
                    hintStyle: GoogleFonts.poppins(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),

                ),
              ),
              SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () {
                  if(_controller.text.isNotEmpty){
                    sendMessage(_controller.text);
                  }
                },
                backgroundColor: Colors.green,
                child: Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),

      ],
    ),

  );
}

}


