import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:twitter/twitter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

const kGoogleApiKey = "AIzaSyAgp4bsoBVtPcoDXw1IH2wLy1b5iI-pkus";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
List searchIds = List(); //necessario iniciar a lista pra n dar problema

var y;
var nome = " ";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  _HomePageState(

  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    // show input autocomplete with selected mode
                    // then get the Prediction selected
                    Prediction p = await PlacesAutocomplete.show(
                        context: context, apiKey: kGoogleApiKey);
                    displayPrediction(p);
                  },
                  child: Icon(Icons.search),
                  backgroundColor: Colors.blue,
                ),
                appBar: AppBar(
                  title: Text("Trending Location"),
                ),
                body: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(nome),
                      Expanded(
                        child: ListView.builder(
                            padding: EdgeInsets.all(30),
                            itemCount: searchIds.length,
                            itemBuilder: (context, indice) {
                              return ListTile(
                                title: Text(indice.toString()),
                                subtitle: Text(searchIds[indice]),
                              );
                            }),
                      ),
                    ],
                  ),
                ))));
  }

  void consumirApiTwitter(double lat, double long) async {
    Twitter twitter = new Twitter(
        'EAZVfcwcC8UxBj6Sa0xc3yvhF',
        'XuS1McPPdA1EE0N7m1Jn9Nem75CNrig6t2h8czVicTUD0zOPFR',
        '1167983090347794432-HuvseCzkG5vymCQLy1jxFXHED8plBH',
        'VDE7K8hWLr0fLntSss60Or09EoDoyWBWriya1EC8SI3m3');

    var responseWoeid = await twitter.request(
        "GET", "trends/closest.json?lat=${lat}&long=${long}");

    var x = List<Map<String, dynamic>>.from(json.decode(responseWoeid.body));
    print(x[0]);
    var woeid = x[0]["woeid"];
    nome = "Local mais próximo com trending topics: " + x[0]["name"];
    print(woeid);

    var reponseTrendList =
    await twitter.request("GET", "trends/place.json?id=${woeid}");
    y = List<Map<String, dynamic>>.from(json.decode(reponseTrendList.body));
    print(y[0]);
    print(y[0]["trends"][2]["name"]);
    searchIds = new List<String>();

    setState(() {
      for (int i = 0; i < y[0]["trends"].length; i++) {
        searchIds.add(y[0]["trends"][i]["name"]);
      }
    });

//    print("batata + " + y[0]["name"]);
//    for(int i = 0; i < y.length; i++){
//
//    }

    // var x = json.decode(response.body)["woeid"];
    //print(x);
//    print(woeid);
    twitter.close();
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      print(lat);
      print(lng);
      consumirApiTwitter(lat, lng);
    }
  }

}
