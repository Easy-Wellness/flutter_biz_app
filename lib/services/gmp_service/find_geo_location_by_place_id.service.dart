import 'dart:convert';
import 'dart:io';

import 'package:easy_wellness_biz_app/constants/env.dart';
import 'package:easy_wellness_biz_app/models/location/geo_location.model.dart';
import 'package:easy_wellness_biz_app/models/location/gmp_geocode_result.model.dart';
import 'package:http/http.dart' as http;

/// Find a place with a particular [placeId] on Google Maps and
/// get its geographic coordinates and street address [GeoLocation]
Future<GeoLocation> findGeoLocationByPlaceId(String placeId) async {
  final geocodingAPI = Uri.https(
    'maps.googleapis.com',
    '/maps/api/geocode/json',
    {
      'key': googleMapsApiKey,
      'place_id': placeId,
    },
  );
  final response = await http.get(geocodingAPI);
  if (response.statusCode == 200) {
    final parsed = GoogleMapsGeocodeResult.fromJson(
        jsonDecode(response.body)['results'][0]);
    final geoCoords = parsed.geometry.location;
    return GeoLocation(
      latitule: geoCoords.lat,
      longitude: geoCoords.lng,
      address: parsed.formattedAddress,
    );
  } else
    throw HttpException(
      'Failed to find the location associated with this placeID',
      uri: geocodingAPI,
    );
}
