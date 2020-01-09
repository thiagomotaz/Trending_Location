import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:trending_local/TrendingTopics.dart';
import 'package:twitter/twitter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const kGoogleApiKey = "AIzaSyAgp4bsoBVtPcoDXw1IH2wLy1b5iI-pkus";
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  var nome = " ";
  String url;
  Twitter twitter = new Twitter(
      'EAZVfcwcC8UxBj6Sa0xc3yvhF',
      'XuS1McPPdA1EE0N7m1Jn9Nem75CNrig6t2h8czVicTUD0zOPFR',
      '1167983090347794432-HuvseCzkG5vymCQLy1jxFXHED8plBH',
      'VDE7K8hWLr0fLntSss60Or09EoDoyWBWriya1EC8SI3m3');

  double lat, long;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trending local")),
      body: Container(
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                Prediction p = await PlacesAutocomplete.show(
                    context: context, apiKey: kGoogleApiKey);
                displayPrediction(p);
                return lista();
              },
              child: Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }

  Widget lista() {
    FutureBuilder<List<TrendingTopics>>(
      future: _recuperarTrendingList(),
      builder: (context, snapshot) {
        print("chega aqui?2");
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            print("entrou no switch");
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              print("Erro ao carregar lista");
            } else {
              print("Lista carregada com sucesso");
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    List<TrendingTopics> lista = snapshot.data;
                    TrendingTopics t = lista[index];

                    return ListTile(
                      title: Text("titulo"),
                      subtitle: Text("a"),
                    );
                  });
            }
            break;
        }
        return Container();
      },
    );
  }

  Future<int> _recoveryWOEID() async {
    print("chamou recovery woeid");

    http.Response responseWoeid = await twitter.request(
        "GET", "trends/closest.json?lat=${lat}&long=${long}");
    var dados =
        List<Map<String, dynamic>>.from(json.decode(responseWoeid.body));
    var woeid = dados[0]["woeid"];

    return Future.value(woeid);
  }

  Future<List<TrendingTopics>> _recuperarTrendingList() async {
    print("chamou recovery trending list");

    int woeid = await _recoveryWOEID();
    print("woeid da funcaoooo" + woeid.toString());

    var reponseTrendList =
        await twitter.request("GET", "trends/place.json?id=${woeid}");
    List dados =
        List<Map<String, dynamic>>.from(json.decode(reponseTrendList.body));
    List<TrendingTopics> trendingList = new List<TrendingTopics>();

    for (int i = 0; i < dados[0]["trends"].length; i++) {
      TrendingTopics t = TrendingTopics(dados[0]["trends"][i]["name"]);
      trendingList.add(t);
    }
    //twitter.close();
    print("chamou os trending lista");

    return trendingList;
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      lat = detail.result.geometry.location.lat;
      long = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);
    }
  }
}
