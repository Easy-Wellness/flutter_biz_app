import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
import 'package:easy_wellness_biz_app/constants/specialties.dart';
import 'package:easy_wellness_biz_app/models/nearby_service/db_nearby_service.model.dart';
import 'package:easy_wellness_biz_app/services/gmp_service/find_nearby_places.service.dart';

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
    await placeRef.set({
      'name': clinicName,
      'geo_position': location.data,
      'address': address,
      'status': place.businessStatus,
    });
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
