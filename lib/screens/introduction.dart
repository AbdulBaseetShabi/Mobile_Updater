import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:resume_updater/global.dart';

class Biography {
  final String id;
  final DateTime date;
  String data;
  bool isActive;

  Biography({this.id, this.date, this.data, this.isActive});

  static Biography fromJson(dynamic json) {
    return Biography(
        id: json["_id"],
        data: json["data"],
        date: DateTime.parse(json["date"]),
        isActive: json["is_active"]);
  }

  static List<Biography> fromJsonList(dynamic json) {
    List<Biography> result = [];
    for (int i = 0; i < json.length; i++) {
      result.add(fromJson(json[i]));
    }

    return result;
  }
}

class Introduction extends StatefulWidget {
  static final String db = "biography";
  @override
  _IntroductionState createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  Future<List<Biography>> biography;
  List<Biography> list_biography = [];
  // bool _checkboxValue = false;
  TextEditingController _newBiography = new TextEditingController();
  List<TextEditingController> _editBiography = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Introduction"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              child: AlertDialog(
                actions: <Widget>[
                  FlatButton(
                      onPressed: () async {
                        String date = DateTime.now().toUtc().toString();
                        String value = _newBiography.text;
                        await addBiography({
                          "is_active": "false",
                          "data": value,
                          "date": date
                        }).then((id) => {
                              setState(() {
                                list_biography.add(Biography.fromJson({
                                  "_id": id,
                                  "is_active": false,
                                  "data": value,
                                  "date": date
                                }));
                              })
                            });
                        _newBiography.clear();
                        Navigator.pop(context);
                      },
                      child: Text("Submit")),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"))
                ],
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _newBiography,
                      maxLines: null,
                      autocorrect: true,
                      keyboardType: TextInputType.multiline,
                      showCursor: true,
                      enableSuggestions: true,
                      autofocus: true,
                      decoration: InputDecoration(
                          labelText: "Biography:",
                          border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Icon(Icons.add)),
      body: FutureBuilder<List<Biography>>(
        future: biography,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            list_biography = snapshot.data;
            return CarouselSlider.builder(
              itemCount: list_biography.length,
              itemBuilder: (context, index) {
                _editBiography.add(new TextEditingController(
                    text: list_biography[index].data));
                return biographyTile(index);
              },
              options:
                  CarouselOptions(height: MediaQuery.of(context).size.height),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void initState() {
    super.initState();
    biography = getAllBiographies();
  }

  Future<List<Biography>> getAllBiographies() async {
    final response = await http
        .post(Global.backend_url_local + '/getData?db=' + Introduction.db);
    if (response.statusCode == 200) {
      return Biography.fromJsonList(json.decode(response.body));
    } else if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else {
      throw new Exception("HTTP call failed");
    }
  }

  Future<String> addBiography(dynamic data) async {
    final response = await http.post(
        Global.backend_url_local + '/addData?db=' + Introduction.db,
        body: data);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else {
      throw new Exception("HTTP call failed");
    }
  }

  deleteBiography(String id) async {
    final response = await http.post(
        Global.backend_url_local + '/removeData?db=' + Introduction.db,
        body: {'_id': id});
    if (response.statusCode == 500) {
      throw new Exception(response.body);
    } else if (response.statusCode == 200) {
      return;
    }
  }

  void makeBiographyActive(id) async {
    final response = await http.post(
        Global.backend_url_local + '/biography/active',
        body: {'_id': id});
    if (response.statusCode == 500) {
      throw new Exception(response.body);
    }
  }

  void makeActiveBioInactive() {
    for (int i = 0; i < list_biography.length; i++) {
      if (list_biography[i].isActive) {
        list_biography[i].isActive = false;
      }
    }
  }

  Widget biographyTile(int index) {
    bool editMode = false;
    return Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: list_biography[index].isActive
                  ? const EdgeInsets.all(5.0)
                  : const EdgeInsets.all(0),
              child: Text(
                list_biography[index].isActive ? "ACTIVE" : "",
                style: TextStyle(
                    color: Colors.greenAccent,
                    height: list_biography[index].isActive ? 1 : 0),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Date:"),
                    Text(list_biography[index].date.toLocal().toString()),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: TextFormField(
                controller: _editBiography[index],
                maxLines: 15,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                enableSuggestions: true,
                readOnly: !editMode,
                enabled: !editMode,
                decoration: InputDecoration(
                    labelStyle: TextStyle(fontSize: 24),
                    labelText: "Biography:",
                    border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              child: RaisedButton(
                child: Text("Set as Actice"),
                onPressed: list_biography[index].isActive
                    ? null
                    : () {
                        makeBiographyActive(list_biography[index].id);
                        setState(() {
                          makeActiveBioInactive();
                          list_biography[index].isActive = true;
                        });
                      },
                color: Colors.greenAccent,
                disabledColor: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              child: RaisedButton(
                child: editMode ? Text("Done") : Text("Edit"),
                onPressed: editMode
                    ? () {
                        setState(() {
                          editMode = !editMode;
                        });
                      }
                    : () {
                        setState(() {
                          editMode = !editMode;
                        });
                      },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              child: RaisedButton(
                child: editMode ? Text("Cancel") : Text("Delete"),
                onPressed: editMode
                    ? () {}
                    : list_biography[index].isActive
                        ? null
                        : () {
                            deleteBiography(list_biography[index].id);
                            setState(() {
                              list_biography.removeAt(index);
                            });                            
                            _editBiography.removeAt(index);
                          },
                color: Colors.redAccent,
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _newBiography.dispose();
    super.dispose();
  }
}
