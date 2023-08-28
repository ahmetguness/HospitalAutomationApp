import 'dart:convert';
import 'dart:developer';

import 'package:doktorhasta/Model/doctor_model.dart';
import 'package:doktorhasta/Model/message_model.dart';
import 'package:doktorhasta/Model/patient_model.dart';
import 'package:doktorhasta/pages/patient_home_views/chat.dart';
import 'package:doktorhasta/riverpod/riverpod_management.dart';
import 'package:doktorhasta/service/chat_update_service.dart';
import 'package:doktorhasta/service/get_doc_service.dart';
import 'package:doktorhasta/service/message_chat_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:grock/grock.dart';

class Chats extends ConsumerStatefulWidget {
  Chats({Key? key, required this.pat}) : super(key: key);
  PatientDataModel pat;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatsState(pat: pat);
}

class _ChatsState extends ConsumerState<Chats> {
  final service = Message_Chat_List();
  final service2 = get_doc_service();
  final service3 = Chat_Update_service();
  _ChatsState({required this.pat});
  PatientDataModel pat;
  @override
  void initState() {
    super.initState();
    service.message_update_call(sender: pat.patientID).then((value) {
      senderID = [];
      for (int i = 0; i < value.length; i++) {
        if (senderID.contains(value[i].recieverID) == false) {
          senderID.add(int.parse(value[i].recieverID.toString()));
          messages.add(value[i]);
        } else {
          continue;
        }
      }
      for (int i = 0; i < senderID.length; i++) {
        service2.get_doc_call(id: messages[i].recieverID).then((value) {
          doclist.add(value);
        });
      }
    });
  }

  List<MessageModel> allmessages = [];
  List<DoctorDataModel> doclist = [];
  List<int> senderID = [];
  List<MessageModel> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: senderID.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              service3
                  .message_update_call(
                      sender: pat.patientID, reciever: doclist[index].doctorID)
                  .then((value) {
                Grock.to(
                    Chat(pat: pat, doc: doclist[index], messageList: value));
              });
            },
            child: Card(
              child: Row(children: [
                ClipOval(
                  child: SizedBox.fromSize(
                      size: const Size.fromRadius(35),
                      child: (doclist[index].doctorPhoto != null)
                          ? Image.memory(
                              base64Decode(doclist[index].doctorPhoto),
                              fit: BoxFit.fill,
                            )
                          : (doclist[index].doctorGender.toLowerCase() ==
                                  "erkek")
                              ? Image.asset("assets/images/male.png")
                              : Image.asset("assets/images/female.png")),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doclist[index].doctorName),
                      Text("(...)"),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
