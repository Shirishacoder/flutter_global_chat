import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globalchat/provider/userprovider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatroomScreen extends StatefulWidget {
  String chatroomName;
  String chatroomId;
  ChatroomScreen({
    super.key,
    required this.chatroomName,
    required this.chatroomId,
  });

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  var db = FirebaseFirestore.instance;
  TextEditingController messageText = TextEditingController();
  Future<void> sendmessage() async {
    if (messageText.text.isEmpty) {
      return;
    }
    Map<String, dynamic> messagetosend = {
      "text": messageText.text,
      "sender_name": Provider.of<Userprovider>(context, listen: false).userName,
      "sender_id": Provider.of<Userprovider>(context, listen: false).id,
      "chatroom_id": widget.chatroomId,
      "timestamp": FieldValue.serverTimestamp(),
    };
    messageText.text = "";
    try {
      await db.collection("message").add(messagetosend);
    } catch (e) {}
  }

  Widget singlechatitem({
    required String sender_name,
    required String text,
    required String sender_id,
  }) {
    return Column(
      crossAxisAlignment:
          sender_id == Provider.of<Userprovider>(context, listen: false).id
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 6.0),
          child: Text(
            sender_name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),

          child: Container(
            decoration: BoxDecoration(
              color:
                  sender_id ==
                          Provider.of<Userprovider>(context, listen: false).id
                      ? const Color.fromARGB(255, 14, 132, 217)
                      : const Color.fromARGB(255, 210, 201, 201),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: TextStyle(
                  color:
                      sender_id ==
                              Provider.of<Userprovider>(
                                context,
                                listen: false,
                              ).id
                          ? const Color.fromARGB(255, 253, 250, 250)
                          : Colors.black,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatroom")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  db
                      .collection("message")
                      .where("chatroom_id", isEqualTo: widget.chatroomId)
                      .limit(100)
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                print(snapshot.error);
                if (snapshot.hasError) {
                  return Text("Some error has occured!");
                }
                var allmessages = snapshot.data?.docs ?? [];
                if (allmessages.length < 1) {
                  return Center(child: Text("No message here"));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: allmessages.length,
                  itemBuilder: (BuildContext context, int index) {
                    var messageData =
                        allmessages[index].data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: singlechatitem(
                        sender_name: messageData["sender_name"] ?? "Unknown",
                        text: messageData["text"] ?? "",
                        sender_id:
                            messageData["sender_id"] ??
                            "unknown", // fallback value
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageText,
                      decoration: InputDecoration(
                        hintText: "Write message here...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  InkWell(onTap: sendmessage, child: Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
