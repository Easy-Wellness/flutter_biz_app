import 'dart:convert';
import 'dart:io';

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
  await Future.wait(places.map((place) async {
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
    final clinicName = await _getFakePropertyValue('Hospital');
    await placeRef
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .set(DbPlace(
          name: clinicName,
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
    final nameList = await Future.wait(
        specialties.map((_) => _getFakePropertyValue('Company Name')));
    await Future.wait(
      specialties.mapIndexed(
        (index, specialty) => servicesRef.add(DbNearbyService(
          rating: place.rating,
          ratingsTotal: place.userRatingsTotal,
          duration: 60,
          description:
              'This sandwich can be made in a pan. Margarine on the outside, pizza sauce and fillings on the inside. The term "pudgy pie" is sometimes used to refer to pie irons, a gadget used for campfire cooking.',
          specialty: specialty,
          serviceName: nameList[index],
          priceTag: PriceTag(type: PriceType.notSet),
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

Future<String> _getFakePropertyValue(String property) async {
  final fakerAPI = Uri.https(
    'fakercloud.com',
    '/schemas/property',
  );
  final response = await http.post(fakerAPI, body: {'name': property});
  if (response.statusCode == 200)
    return jsonDecode(response.body)['results'][0] as String;
  else
    throw HttpException(
      'Failed to get data from Faker Cloud',
      uri: fakerAPI,
    );
}
