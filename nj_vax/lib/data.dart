import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<List<VaccineLocation>> fetchNJ() async {
  final response;
  try {
    response = await http
        .get(Uri.parse('https://www.vaccinespotter.org/api/v0/states/NJ.json'));
  } catch (e) {
    return [VaccineLocation.noConnection];
  }

  if (response.statusCode == 200) {
    var elements = List.from(jsonDecode((response.body))['features']);

    List<VaccineLocation> list = [
      for (var element in elements)
        VaccineLocation.fromJson((element['properties']))
    ];

    for (var item in list) {
      var adds = item.address.split(" ");
      var cities = item.city.split(" ");
      for (var i = 0; i < adds.length; i++) {
        if (adds[i] == "") {
          adds.removeAt(i);
        }
      }

      for (var i = 0; i < cities.length; i++) {
        if (cities[i] == "") {
          cities.removeAt(i);
        }
      }

      for (var i = 0; i < adds.length; i++) {
        adds[i] = adds[i].toLowerCase();
        adds[i] = adds[i].substring(0, 1).toUpperCase() + adds[i].substring(1);
      }

      for (var i = 0; i < cities.length; i++) {
        cities[i] = cities[i].toLowerCase();
        cities[i] =
            cities[i].substring(0, 1).toUpperCase() + cities[i].substring(1);
      }

      item.address = adds.join(" ");
      item.city = cities.join(" ");
    }
    list.sort((VaccineLocation vc1, VaccineLocation vc2) {
      if (!vc1.appointments_available && vc2.appointments_available) {
        return 1;
      } else
        return -1;
    });

    return list;
  } else {
    return [VaccineLocation.error];
  }
}

class VaccineLocation {
  static final noConnection = VaccineLocation(
      name: "OFF",
      address: "",
      city: "",
      state: "",
      postal_code: "",
      id: 0,
      appointments_available: false,
      url: "");

  static final error = VaccineLocation(
      name: "ERR",
      address: "",
      city: "",
      state: "",
      postal_code: "",
      id: 0,
      appointments_available: false,
      url: "");

  String name;
  String address;
  String city;
  String state;
  String postal_code;
  int id;
  String provider_brand;

  bool appointments_available;
  List<dynamic>? appointments;
  String url;

  VaccineLocation({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.postal_code,
    required this.id,
    this.provider_brand = '',
    required this.appointments_available,
    this.appointments,
    required this.url,
  });

  factory VaccineLocation.fromJson(Map<String, dynamic> json) {
    return VaccineLocation(
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postal_code: json['postal_code'],
      id: json['id'],
      appointments_available: json['appointments_available'] == null
          ? false
          : json['appointments_available'],
      appointments: json['appointments'],
      url: json['url'],
      provider_brand: json['provider_brand_name'],
    );
  }

  @override
  String toString() {
    return '''
      VaccineLocation(
      name: $name, 
      address: $address, 
      city: $city, 
      state: $state, 
      postal_code: $postal_code, 
      appointments_available: $appointments_available, 
      appointments: ${appointments != null ? appointments!.length : 0}, 
      url: $url
      ) \n\n''';
  }
}

Future<bool> isConnected() async {
  try {
    await InternetAddress.lookup('www.google.com');
    return true;
  } on SocketException {
    return false;
  }
}
