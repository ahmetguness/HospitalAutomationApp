import 'dart:convert';
import 'package:doktorhasta/Model/doctor_model.dart';
import 'package:doktorhasta/config/loading_popup.dart';
import 'package:doktorhasta/pages/patient_home_views/view_doc_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:doktorhasta/Model/patient_model.dart';
import 'package:grock/grock.dart';
import 'package:doktorhasta/config/baseurl.dart';

class ViewDocs extends ConsumerStatefulWidget {
  ViewDocs({Key? key, required this.pat}) : super(key: key);
  final PatientDataModel pat;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewDocsState(pat: pat);
}

List<DoctorDataModel> docList = [];
Future<List<DoctorDataModel>> _getDoctorList() async {
  String baseurl = BaseurlConstants().baseurl;
  try {
    var response = await Dio().get("$baseurl/doctors");
    List<DoctorDataModel>? doctorList = [];
    if (response.statusCode == 200) {
      doctorList = (response.data as List)
          .map((e) => DoctorDataModel.fromJson(e))
          .cast<DoctorDataModel>()
          .toList();
    }
    docList = doctorList;
    return doctorList;
  } on DioError catch (e) {
    return Future.error(e.message);
  }
}

class _ViewDocsState extends ConsumerState<ViewDocs> {
  _ViewDocsState({required this.pat});
  final PatientDataModel pat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 87, 100),
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text(' Ara'),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: customSearchDelegate(pat: pat),
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: FutureBuilder<List<DoctorDataModel>>(
        future: _getDoctorList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var doctorList = snapshot.data!;
            return ListView.builder(
                padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                itemBuilder: (context, index) {
                  var doctor = doctorList[index];
                  return InkWell(
                    onTap: () {
                      Grock.to(
                        ViewDocDetail(
                          doc: doctor,
                          pat: pat,
                        ),
                      );
                    },
                    child: Card(
                      child: Row(
                        children: [
                          ClipOval(
                            child: SizedBox.fromSize(
                                size: const Size.fromRadius(35),
                                child: (doctor.doctorPhoto != null)
                                    ? Image.memory(
                                        base64Decode(doctor.doctorPhoto),
                                        fit: BoxFit.fill,
                                      )
                                    : (doctor.doctorGender.toLowerCase() ==
                                            "erkek")
                                        ? Image.asset("assets/images/male.png")
                                        : Image.asset(
                                            "assets/images/female.png")),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doctor.doctorName),
                                Text(doctor.doctorDiscipline),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            alignment: Alignment.centerRight,
                            child: Text(
                                textAlign: TextAlign.right,
                                (doctor.doctorOnline == 1)
                                    ? "ONLINE"
                                    : "OFFLINE"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: doctorList.length);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class customSearchDelegate extends SearchDelegate {
  customSearchDelegate({Key? key, required this.pat}) : super();
  final PatientDataModel pat;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  IconButton buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<DoctorDataModel> matchQuery = [];
    for (var a in docList) {
      if (a.doctorName.toLowerCase().contains(query.toLowerCase()) ||
          a.doctorDiscipline.toLowerCase().contains(query)) {
        matchQuery.add(a);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () {
            Grock.to(
              ViewDocDetail(
                doc: result,
                pat: pat,
              ),
            );
          },
          leading: Icon(Icons.person),
          title: Text(result.doctorName),
          subtitle: Text(result.doctorDiscipline),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<DoctorDataModel> matchQuery = [];
    for (var a in docList) {
      if (a.doctorName.toLowerCase().contains(query) ||
          a.doctorDiscipline.toLowerCase().contains(query)) {
        matchQuery.add(a);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () {
            Grock.to(
              ViewDocDetail(
                doc: result,
                pat: pat,
              ),
            );
          },
          leading: Icon(Icons.person),
          title: Text(result.doctorName),
          subtitle: Text(result.doctorDiscipline),
        );
      },
    );
  }
}
