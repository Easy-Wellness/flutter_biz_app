import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_wellness_biz_app/constants/misc.dart';
import 'package:easy_wellness_biz_app/models/location/geo_position.model.dart';
import 'package:easy_wellness_biz_app/models/nearby_service/db_nearby_service.model.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/services/gmp_service/find_nearby_places.service.dart';
import 'package:easy_wellness_biz_app/widgets/weekly_schedule_settings/edit_weekly_schedule_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;

Future<void> seedPlacesAndServices() async {
  final geo = Geoflutterfire();
  final db = FirebaseFirestore.instance;
  final places = await findNearbyPlaces();
  print('Seeding ${places.length} places and services for each...');
  await Future.wait(places.mapIndexed((placeIndex, place) async {
    final GeoFirePoint location = geo.point(
      latitude: place.geometry.location.lat,
      longitude: place.geometry.location.lng,
    );
    final placeRef = db.collection('places').doc(place.placeId);
    final servicesRef =
        placeRef.collection('services').withConverter<DbNearbyService>(
              fromFirestore: (snapshot, _) =>
                  DbNearbyService.fromJson(snapshot.data()!),
              toFirestore: (service, _) => service.toJson(),
            );
    final address =
        '${place.vicinity}, ${place.plusCode?.compoundCode.substring(8) ?? ''}';
    final geoPos = GeoPosition(
      geohash: location.data['geohash'],
      geopoint: location.data['geopoint'],
    );
    await placeRef
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .set(DbPlace(
          name: _clinicNames[placeIndex],
          geoPosition: geoPos,
          ownerId: FirebaseAuth.instance.currentUser!.uid,
          workingHours: defaultWeeklySchedule,
          email: 'versatileclinic@clinic.biz.com',
          phoneNumber: '(+84) 12 345 67 89',
          address: address,
          status: place.businessStatus.toLowerCase(),
          minuteIncrements: 30,
          minLeadHours: 24,
          maxLeadDays: 365,
        ));
    final random = Random();
    await Future.wait(
      specialties.mapIndexed(
        (specialtyIndex, specialty) => servicesRef.add(DbNearbyService(
          rating: place.rating,
          ratingsTotal: place.userRatingsTotal,
          duration: 15 + random.nextInt(166),
          description:
              'Half section of Italian or French bread with garlic butter, containing ham, provel or provolone cheese, topped with paprika, then toasted. Doner kebab is meat cooked on a vertical spit, normally veal or beef but also may be a mixture of these with lamb, and sometimes chicken that may be served wrapped in a flatbread such as lavash or pita or as a sandwich. Slices of cheese (typically Cheddar) and pickle (a sweet, vinegary chutney with the most popular brand being Branston), sandwiched between two slices of bread.',
          specialty: specialty,
          serviceName: '${_serviceAdjectives[specialtyIndex]} $specialty',
          priceTag: PriceTag(
            type: PriceType.startingAt,
            value: 15 + random.nextInt(986),
          ),
          placeName: _clinicNames[placeIndex],
          placeId: place.placeId,
          address: address,
          geoPosition: geoPos,
          minuteIncrements: 30,
          minLeadHours: 24,
          maxLeadDays: 365,
        )),
      ),
    );
  }));
  print('All done!');
}

/// The fake data returned from Faker Cloud at https://fakercloud.com/api is
/// then hard coded into the Dart file where this method is defined.
///
/// Possible values for [property]: 'Hospital'.
void getDataFromFakerCloud(String property) async {
  final fakerAPI = Uri.https(
    'fakercloud.com',
    '/schemas/property',
  );
  final futures = List.generate(
    8,
    (_) => http.post(fakerAPI, body: {'name': property}).then(
      (res) => (jsonDecode(res.body)['results'] as List)
          .map<String>(
            (e) => e.toString(),
          )
          .toList(),
    ),
    growable: false,
  );
  final results = await Future.wait(futures);
  final jsonString = json.encode(results.expand((list) => list).toList());
  print(jsonString);
}

const _serviceAdjectives = [
  "Exceptional",
  "Licensed",
  "Convenient",
  "Cost-efficient",
  "Blazing fast",
  "Popular",
  "Awesome",
  "Comfortable",
  "Smart",
  "Intelligent",
  "Generic",
];

const _clinicNames = [
  "Floyd Medical Center",
  "Mountainside Hospital",
  "Veterans Affairs Medical Center San Diego",
  "Kenmare Community Hospital",
  "Parkview Lagrange Hospital",
  "Elliot Hospital",
  "Good Samaritan Hospital",
  "Central Alabama Veterans Health Care System East Campus",
  "Cleveland Clinic Hospital",
  "Catholic Medical Center",
  "Plantation General Hospital",
  "Yonkers General Hospital",
  "Martin General Hospital",
  "Samaritan Medical Center/Samaritan Med Ctr",
  "Wishard Memorial Hospital",
  "Jefferson Memorial Hospital",
  "Springhill Medical Center",
  "Eden Medical Center",
  "Goleta Valley Cottage Hospital",
  "Novant Health Matthews Medical Center",
  "Rome Memorial Hospital",
  "Mountain Vista Medical Center",
  "Novant Health Forsyth Medical Center",
  "Effingham Hospital",
  "Barnes-Jewish Hospital",
  "Habersham Medical Center",
  "Healthmark Regional Medical Center",
  "Mercy Gilbert Medical Center",
  "Central Alabama Veterans Health Care System East Campus",
  "Cayuga Medical Center at Ithaca",
  "Catholic Medical Center",
  "St. Mary Mercy Livonia Hospital",
  "Horizon Specialty Hospital",
  "West Palm Beach Hospital",
  "Kennedy Krieger Institute",
  "Major Hospital",
  "Mease Dunedin Hospital",
  "Sarasota Memorial Hospital",
  "George L. Mee Memorial Hospital",
  "Carondelet St. Joseph's Hospital",
  "General Leonard Wood Army Community Hospital",
  "Montclair Hospital Medical Center",
  "Providence Hospital",
  "Murphy Medical Center",
  "Brandon Regional Hospital",
  "Lake Wales Medical Center",
  "Jacobi Medical Center",
  "Presbyterian Intercommunity Hospital",
  "Perry Hospital",
  "Vegas Valley Rehabilitation Hospital",
  "Calvary Hospital",
  "Green Hospital of Scripps Clinic",
  "WellStar Cobb Hospital",
  "Rome Memorial Hospital",
  "St. Petersburg General Hospital",
  "Fairchild Medical Center",
  "Dupont Hospital",
  "Shore Memorial Hospital",
  "DeKalb Medical",
  "Deaconess Incarnate Word Health System",
  "Lee Memorial Hospital",
  "Mountainside Hospital",
  "La Palma Intercommunity Hospital",
  "Bloomington Meadows Hospital"
];
