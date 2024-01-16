import 'dart:math';

class PositionGeo {
  final double latitude;
  final double longitude;

  PositionGeo(this.latitude, this.longitude);

}

double radians(double degrees) {
  return degrees * pi / 180.0;
}

double degrees(double radians) {
  return radians * 180.0 / pi;
}

double calculateDistance(PositionGeo pointA, PositionGeo pointB) {
  const double earthRadius = 6371; // Rayon de la Terre en kilomètres

  double latA = radians(pointA.latitude);
  double lonA = radians(pointA.longitude);
  double latB = radians(pointB.latitude);
  double lonB = radians(pointB.longitude);

  double dLat = latB - latA;
  double dLon = lonB - lonA;

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(latA) * cos(latB) * sin(dLon / 2) * sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

List<PositionGeo> generatePositions(PositionGeo pointA, PositionGeo pointB, int numPositions) {
  // Convertir les coordonnées en radians
  double latA = radians(pointA.latitude);
  double lonA = radians(pointA.longitude);
  double latB = radians(pointB.latitude);
  double lonB = radians(pointB.longitude);

  // Calculer la distance totale entre A et B
  double totalDistance = calculateDistance(pointA, pointB);

  print("totalDistance ${totalDistance}");

  // Calculer l'incrément de distance entre chaque position
  double incrementDistance = totalDistance / (numPositions + 1);

  // Liste pour stocker les positions générées
  List<PositionGeo> positions = [];

  // Générer les positions intermédiaires
  for (int i = 1; i <= numPositions; i++) {
    // Calculer la nouvelle position en fonction de l'incrément
    double fraction = incrementDistance * i / totalDistance;

    PositionGeo newPosition = PositionGeo(
      degrees(latA + fraction * (latB - latA)),
      degrees(lonA + fraction * (lonB - lonA)),
    );

    // Ajouter la nouvelle position à la liste
    positions.add(newPosition);
  }

  return positions;
}