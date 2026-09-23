const String _geohashBase32 = '0123456789bcdefghjkmnpqrstuvwxyz';

String encodeGeohash(
  double lat,
  double lng, {
  int precision = 9,
}) {
  double minLat = -90;
  double maxLat = 90;
  double minLng = -180;
  double maxLng = 180;
  String geohash = '';
  int bit = 0;
  int ch = 0;
  bool isLng = true;

  while (geohash.length < precision) {
    if (isLng) {
      final mid = (minLng + maxLng) / 2;
      if (lng >= mid) {
        ch |= 1 << (4 - bit);
        minLng = mid;
      } else {
        maxLng = mid;
      }
    } else {
      final mid = (minLat + maxLat) / 2;
      if (lat >= mid) {
        ch |= 1 << (4 - bit);
        minLat = mid;
      } else {
        maxLat = mid;
      }
    }
    isLng = !isLng;
    if (bit < 4) {
      bit++;
    } else {
      geohash += _geohashBase32[ch];
      bit = 0;
      ch = 0;
    }
  }
  return geohash;
}
