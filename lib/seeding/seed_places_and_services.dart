import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  await Future.wait(places.map((place) async {
    final clinicName = await _getFakeClinicName();
    GeoFirePoint location = geo.point(
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
          name: clinicName,
          geoPosition: geoPos,
          ownerId: FirebaseAuth.instance.currentUser!.uid,
          workingHours: defaultWorkingHoursInSecs,
          email: 'versatileclinic@clinic.biz.com',
          phoneNumber: '(+84) 12 345 67 89',
          address: address,
          status: place.businessStatus.toLowerCase(),
        ));
    await Future.wait(
      specialties.map(
        (specialty) => servicesRef.add(DbNearbyService(
          rating: place.rating,
          ratingsTotal: place.userRatingsTotal,
          specialty: specialty,
          serviceName: specialty,
          placeName: clinicName,
          placeId: place.placeId,
          address: address,
          geoPosition: geoPos,
        )),
      ),
    );
  }));
  print('All done!');
}

Future<String> _getFakeClinicName() async {
  final fakerAPI = Uri.https(
    'fakercloud.com',
    '/schemas/property',
  );
  final response = await http.post(fakerAPI, body: {'name': 'Hospital'});
  if (response.statusCode == 200)
    return jsonDecode(response.body)['results'][0] as String;
  else
    throw HttpException(
      'Failed to find nearby places',
      uri: fakerAPI,
    );
}
