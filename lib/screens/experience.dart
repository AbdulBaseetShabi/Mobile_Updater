import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:resume_updater/global.dart';

class ExperienceData {
  String id;
  String jobTitle;
  String companyName;
  String dateFrom; //TODO: DateTime
  String dateTo;
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
        dateFrom: json['dateFrom'],
        dateTo: json['dateTo'],
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
  List<ExperienceData> list_experience;
  List<int> coopExperience;
  List<int> workExperience;
  List<int> volunteerExperience;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Experiences"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          int value = 1;
          String jobTitle = "";
          String companyName = "";
          String dateFrom = ""; //TODO: DateTime
          String dateTo = "";
          String location = "";
          List<String> descriptions = [];
          bool isCoop = false;
          bool isWork = false;
          bool isVolunteer = false;
          bool isActive = true;
          TextEditingController newDescription = new TextEditingController();

          showDialog(
              context: context,
              barrierDismissible: false,
              useSafeArea: true,
              builder: (context) => StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                      scrollable: true,
                      title: Text("ADD NEW EXPERIENCE"),
                      content: Column(
                        children: [
                          TextField(
                            onChanged: (value) {
                              jobTitle = value;
                            },
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(),
                              labelText: "Job Title",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          TextField(
                            onChanged: (value) {
                              companyName = value;
                            },
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(),
                              labelText: "Company",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          TextField(
                            onChanged: (value) {
                              location = value;
                            },
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(),
                              labelText: "Location",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    dateFrom = value;
                                  },
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(),
                                    labelText: "From",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    dateTo = value;
                                  },
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(),
                                    labelText: "To",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton(
                                value: value,
                                items: [
                                  DropdownMenuItem(
                                    child: Text("Coop"),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Volunteer"),
                                    value: 2,
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Work"),
                                    value: 3,
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    value = val;
                                  });
                                },
                              ),
                              FlatButton(
                                  child: Text(
                                      isActive ? "Set Inactive" : "Set Active"),
                                  color: isActive
                                      ? Colors.grey
                                      : Colors.greenAccent,
                                  onPressed: () {
                                    setState(() {
                                      isActive = !isActive;
                                    });
                                  })
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: newDescription,
                                  maxLines: null,
                                  autocorrect: true,
                                  keyboardType: TextInputType.multiline,
                                  showCursor: true,
                                  enableSuggestions: true,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                      labelText: "New Description:",
                                      border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          FlatButton(
                            minWidth: MediaQuery.of(context).size.width,
                            child: Text("Add Description"),
                            color: Colors.blueAccent,
                            onPressed: () {
                              if (newDescription.text.isNotEmpty) {
                                setState(() {
                                  descriptions.add(newDescription.text);
                                  newDescription.text = "";
                                });
                              }
                            },
                          ),
                          ExpansionTile(
                            title: Text("Descriptions"),
                            children: descriptions.map((e) => Text(e)).toList(),
                          ),
                          FlatButton(
                            minWidth: MediaQuery.of(context).size.width,
                            child: Text("ADD"),
                            color: Colors.blueAccent,
                            onPressed: () {
                              if (value == 1) {
                                isCoop = true;
                              } else if (value == 2) {
                                isVolunteer = true;
                              } else {
                                isWork = true;
                              }

                              addExperienceData({
                                'companyName': companyName,
                                'dateFrom': dateFrom,
                                'dateTo': dateTo,
                                'descriptions': descriptions,
                                'jobTitle': jobTitle,
                                'location': location,
                                'isCoop': isCoop,
                                'isVolunteer': isVolunteer,
                                'isWork': isWork,
                                'isActive': isActive,
                              }).then((id) {
                                Navigator.pop(context, true);
                              });
                            },
                          ),
                          FlatButton(
                            minWidth: MediaQuery.of(context).size.width,
                            child: Text("SAVE FOR LATER"),
                            color: Colors.greenAccent,
                            onPressed: () {
                              isActive = false;
                              if (value == 1) {
                                isCoop = true;
                              } else if (value == 2) {
                                isVolunteer = true;
                              } else {
                                isWork = true;
                              }

                              addExperienceData({
                                'companyName': companyName,
                                'dateFrom': dateFrom,
                                'dateTo': dateTo,
                                'descriptions': descriptions,
                                'jobTitle': jobTitle,
                                'location': location,
                                'isCoop': isCoop,
                                'isVolunteer': isVolunteer,
                                'isWork': isWork,
                                'isActive': isActive,
                              }).then((id) {
                                Navigator.pop(context, true);
                              });
                            },
                          ),
                          FlatButton(
                            minWidth: MediaQuery.of(context).size.width,
                            child: Text("CANCEL"),
                            color: Colors.redAccent,
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                          ),
                        ],
                      ),
                    ),
                  )).then((value) {
            if (value) {
              setState(() {
                list_experience = list_experience;
              });
            }
          });
        },
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<ExperienceData>>(
          future: getExperiences(),
          builder: (builder, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              list_experience = snapshot.data;
              coopExperience = [];
              workExperience = [];
              volunteerExperience = [];

              for (int i = 0; i < list_experience.length; i++) {
                if (list_experience[i].isCoop) {
                  coopExperience.add(i);
                } else if (list_experience[i].isWork) {
                  workExperience.add(i);
                } else if (list_experience[i].isVolunteer) {
                  volunteerExperience.add(i);
                } else {
                  print("corrupted data");
                }
              }
              return Column(
                children: [
                  ExpansionTile(
                    title: Text("Coop Experiences"),
                    children: listExperienceTiles(coopExperience),
                  ),
                  ExpansionTile(
                    title: Text("Work Experiences"),
                    children: listExperienceTiles(workExperience),
                  ),
                  ExpansionTile(
                    title: Text("Volunteer Experiences"),
                    children: listExperienceTiles(volunteerExperience),
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

  List<Widget> listExperienceTiles(List<int> experienceIndex) {
    return experienceIndex
        .map((e) => experienceTile(e, list_experience[e].isActive))
        .toList();
  }

  Widget experienceTile(int index, bool active) {
    return ExpansionTile(
        title: Text(
            "${list_experience[index].jobTitle} at ${list_experience[index].companyName}"),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("${list_experience[index].location}"),
              Text(
                  "${list_experience[index].dateFrom} - ${list_experience[index].dateTo}"),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 29.0),
            child: Column(
              children: list_experience[index]
                  .descriptions
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
                  deleteExperienceData(list_experience[index].id).then((value) {
                    setState(() {
                      list_experience = list_experience
                          .where((element) =>
                              element.id != list_experience[index].id)
                          .toList();
                    });
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
                child: Text(!active ? "SET ACTIVE" : "SET INACTIVE"),
                onPressed: () {
                  updateExperienceData(
                      {"_id": list_experience[index].id, "isActive": !active});
                  setState(() {
                    active = !active;
                  });
                },
                color: !active ? Colors.greenAccent : Colors.grey,
              ),
            ],
          )
        ]);
  }

  Future<dynamic> deleteExperienceData(String id) async {
    final response = await http.post(
      Global.backend_url_local + '/removeData?db=' + Experience.db,
      headers: {
        'Content-Type': 'application/json',
        "Accept": "application/json"
      },
      body: json.encode({'_id': id}),
    );
    if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  updateExperienceData(dynamic data) async {
    final response = await http.post(
      Global.backend_url_local + '/updateData?db=' + Experience.db,
      headers: {
        'Content-Type': 'application/json',
        "Accept": "application/json"
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else {
      throw new Exception("HTTP call failed");
    }
  }

  addExperienceData(dynamic data) async {
    final response = await http.post(
      Global.backend_url_local + '/addData?db=' + Experience.db,
      headers: {
        'Content-Type': 'application/json',
        "Accept": "application/json"
      },
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else {
      throw new Exception("HTTP call failed");
    }
  }
}
