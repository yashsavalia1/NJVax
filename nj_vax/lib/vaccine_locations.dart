import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';
import 'main.dart';

class AppointmentBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppointmentBodyState();
}

class _AppointmentBodyState extends State<AppointmentBody> {
  late TextEditingController _controller;
  late List<VaccineLocation> _searchedList;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _searchedList = List.from(dataList);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Card(
          child: ListTile(
            title: TextField(
              decoration: InputDecoration(
                suffixIcon: TextButton(
                  child: Icon(
                    Platform.isIOS ? CupertinoIcons.search : Icons.search,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      List<VaccineLocation> temp = List.from(dataList);
                      for (var i = 0; i < temp.length; i++) {
                        if (!temp[i].name.contains(_controller.text)) {
                          temp.removeAt(i);
                          i--;
                        } else {
                          temp[i].name;
                        }
                      }
                      _searchedList = temp;
                    });
                  },
                ),
              ),
              controller: _controller,
              onSubmitted: (String value) {
                setState(() {
                  List<VaccineLocation> temp = List.from(dataList);
                  for (var i = 0; i < temp.length; i++) {
                    if (!temp[i]
                        .name
                        .toLowerCase()
                        .contains(value.toLowerCase())) {
                      temp.removeAt(i);
                      i--;
                    } else {
                      temp[i].name;
                    }
                  }
                  _searchedList = temp;
                });
              },
            ),
          ),
        ),
        if (dataList[0] == VaccineLocation.noConnection)
          ListTile(
            leading: Icon(Icons.wifi_off, size: 32),
            title: Text("Not connected to the Internet."),
          )
        else if (dataList[0] == VaccineLocation.error)
          ListTile(
            leading: Icon(Icons.error, size: 32),
            title: Text("There was an error getting the data."),
          )
        else

          //TODO FIX, Height is too long if there are navigation buttons
          //height: 600 /* MediaQuery.of(context).size.height */,
          Container(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                64,
            child: Scrollbar(
              child: ListView.builder(
                itemCount: _searchedList.length,
                itemBuilder: (context, int index) {
                  VaccineLocation loc = _searchedList[index];
                  return LocationCard.fromLocation(loc);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class LocationCard extends StatelessWidget {
  final VaccineLocation _location;
  final String _subtitle;

  const LocationCard(this._location, this._subtitle, {Key? key})
      : super(key: key);

  factory LocationCard.fromLocation(
    VaccineLocation loc, {
    Key? key,
  }) {
    String subtitle = '${loc.address}, ${loc.city} ${loc.postal_code}';

    return LocationCard(loc, subtitle);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(
                  _location.appointments_available ? Icons.check : Icons.clear,
                  color: _location.appointments_available
                      ? Colors.green
                      : Colors.red),
              title: Text(_location.name),
              subtitle: Text(_subtitle +
                  '\n• ${_location.appointments_available ? 'Appointments are Avaiable' : 'No Appointments Avaiable'}'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('FIND APPOINTMENT'),
                onPressed: () {/* ... */},
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('SEE ON MAP'),
                onPressed: () async {
                  var loc = _location.provider_brand
                          .trim()
                          .replaceAll(' ', '+') +
                      '+' +
                      _subtitle.trim().replaceAll(' ', '+').replaceAll(',', '');
                  var url = Platform.isAndroid
                      ? 'https://maps.google.com/?q=${loc}'
                      : 'maps://maps.google.com/?q=${loc}';
                  await launch(url);
                  //print("Cannot launch");
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
