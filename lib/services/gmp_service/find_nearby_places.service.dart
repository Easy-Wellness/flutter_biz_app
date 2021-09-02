import 'dart:convert';
import 'dart:io';

import 'package:easy_wellness_biz_app/constants/env.dart';
import 'package:easy_wellness_biz_app/models/location/gmp_nearby_place.model.dart';
import 'package:easy_wellness_biz_app/utils/print_object.dart';
import 'package:http/http.dart' as http;

/// Each search can return as many as 60 results, split across three pages.
/// [radius] defines the distance (in meters) within which to return place results
/// Setting [pageToken] will cause any other parameters to be ignored
Future<List<GoogleMapsNearbyPlace>> findNearbyPlaces({
  double latitude = 10.747754,
  double longitude = 106.636902,
  int radius = 20000,
  String type = 'convenience_store',
  String keyword = 'family',
  String? pageToken,
  List<GoogleMapsNearbyPlace> places = const [],
}) async {
  final nearbySearchAPI = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/nearbysearch/json',
    {
      'key': googleMapsApiKey,
      'location': '$latitude,$longitude',
      'radius': '$radius',
      'type': type,
      'keyword': keyword,
      'pagetoken': pageToken ?? '',
    },
  );
  final response = await http.get(nearbySearchAPI);
  if (response.statusCode == 200) {
    final jsonMap = jsonDecode(response.body);
    final nextPageToken = jsonMap['next_page_token'] as String?;
    final parsed = (jsonMap['results'] as List).cast<Map<String, dynamic>>();
    final currentPage = parsed.map<GoogleMapsNearbyPlace>((json) {
      final doc = GoogleMapsNearbyPlace.fromJson(json);
      if (doc.plusCode == null) {
        print('Nearby place from Google Maps with no plus code: ');
        printObject(doc);
      }
      return doc;
    }).toList();
    if (nextPageToken != null) {
      /// There is a delay between when a [next_page_token] is issued, and
      /// when it will become valid
      await Future.delayed(Duration(seconds: 2));
      return await findNearbyPlaces(
          pageToken: nextPageToken, places: [...places, ...currentPage]);
    } else
      return [...places, ...currentPage];
  } else
    throw HttpException(
      'Failed to find nearby places',
      uri: nearbySearchAPI,
    );
}
