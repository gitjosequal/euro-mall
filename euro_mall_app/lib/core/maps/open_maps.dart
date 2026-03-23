import 'package:url_launcher/url_launcher.dart';

/// Opens the system maps app (Google Maps in browser / platform handler).
Future<bool> openMapsLatLng(double latitude, double longitude) async {
  final query = Uri.encodeComponent('$latitude,$longitude');
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$query',
  );
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return false;
}
