/// A local geographic location that is constructed based on Google Maps
/// Platform's response or the native Location API
class GeoLocation {
  final double latitule;
  final double longitude;
  final String address;
  const GeoLocation({
    required this.latitule,
    required this.longitude,
    required this.address,
  });
}
