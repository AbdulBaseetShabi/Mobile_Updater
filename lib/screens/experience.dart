import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:resume_updater/global.dart';
import 'package:intl/intl.dart';

class ExperienceData {
  String id;
  String jobTitle;
  String companyName;
  DateTime dateFrom;
  DateTime dateTo;
  String location;
  List<String> descriptions;
  bool isCoop;
  bool isWork;
  bool isVolunteer;
  bool isActive;

  ExperienceData(
      {this.id,
      this.jobTitle,
      this.companyName,
      this.dateFrom,
      this.dateTo,
      this.location,
      this.descriptions,
      this.isCoop,
      this.isWork,
      this.isVolunteer,
      this.isActive});

  static ExperienceData fromJson(dynamic json) {
    List<String> descriptions = [];
    for (int i = 0; i < json['descriptions'].length; i++) {
      descriptions.add(json['descriptions'][i].toString());
    }
    return ExperienceData(
        companyName: json['companyName'],
        dateFrom: DateTime.parse(json['dateFrom']),
        dateTo: DateTime.parse(json['dateTo']),
        descriptions: descriptions,
        jobTitle: json['jobTitle'],
        location: json['location'],
        isCoop: json['isCoop'],
        isVolunteer: json['isVolunteer'],
        isWork: json['isWork'],
        id: json['_id'],
        isActive: json['isActive']);
  }

  static List<ExperienceData> fromJsonList(dynamic json) {
    List<ExperienceData> response = [];

    for (int i = 0; i < json.length; i++) {
      response.add(fromJson(json[i]));
    }

    return response;
  }
}

class Experience extends StatefulWidget {
  static String db = "experience";
  @override
  _ExperienceState createState() => _ExperienceState();
}

class _ExperienceState extends State<Experience> {
  Future<List<ExperienceData>> experience;
  List<ExperienceData> list_experience;

  void initState() {
    super.initState();
    experience = getExperiences();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Experiences"),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<ExperienceData>>(
          future: experience,
          builder: (builder, snapshot) {
            if (snapshot.hasData) {
              list_experience = snapshot.data;

              return Column(
                children: [
                  ExpansionTile(
                    title: Text("Coop Experiences"),
                    children: listExperienceTiles(list_experience
                        .where((element) => element.isCoop)
                        .toList()),
                  ),
                  ExpansionTile(
                    title: Text("Work Experiences"),
                    children: listExperienceTiles(list_experience
                        .where((element) => element.isWork)
                        .toList()),
                  ),
                  ExpansionTile(
                    title: Text("Volunteer Experiences"),
                    children: listExperienceTiles(list_experience
                        .where((element) => element.isVolunteer)
                        .toList()),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<List<ExperienceData>> getExperiences() async {
    final response = await http
        .post(Global.backend_url_local + '/getData?db=' + Experience.db);
    if (response.statusCode == 200) {
      return ExperienceData.fromJsonList(json.decode(response.body));
    } else if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else {
      throw new Exception("HTTP call failed");
    }
  }

  List<Widget> listExperienceTiles(List<ExperienceData> listExperiences) {
    return listExperiences.map((e) => experienceTile(e)).toList();
  }

  Widget experienceTile(ExperienceData experienceData) {
    return ExpansionTile(
        title:
            Text("${experienceData.jobTitle} at ${experienceData.companyName}"),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("${experienceData.location}"),
              Text(
                  "${DateFormat('yyyy-MM-dd').format(experienceData.dateFrom.toLocal())} - ${DateFormat('yyyy-MM-dd').format(experienceData.dateTo.toLocal())}"),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 29.0),
            child: Column(
              children: experienceData.descriptions
                  .map((e) => Text(" - " + e))
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                child: Text("DELETE"),
                onPressed: () {
                  deleteExperienceData(experienceData.id);
                  setState(() {
                    print(list_experience);
                    list_experience = list_experience
                        .where((element) => element.id != experienceData.id)
                        .toList();
                    print(list_experience);
                  });
                },
                color: Colors.redAccent,
              ),
              FlatButton(
                child: Text("EDIT"),
                onPressed: () {},
                color: Colors.blueAccent,
              ),
              FlatButton(
                child: Text(
                    !experienceData.isActive ? "SET ACTIVE" : "SET INACTIVE"),
                onPressed: () {},
                color:
                    !experienceData.isActive ? Colors.greenAccent : Colors.grey,
              ),
            ],
          )
        ]);
  }

  deleteExperienceData(String id) async {
    final response = await http.post(
        Global.backend_url_local + '/removeData?db=' + Experience.db,
        body: {'_id': id});
    if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else if (response.statusCode == 200) {
      return;
    }
  }
}
