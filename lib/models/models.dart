import 'package:intl/intl.dart';

class UserModel {
  final String uid, cin, firstName, lastName, email;
  final bool hasActiveStay;

  UserModel({
    required this.uid,
    required this.cin,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.hasActiveStay = false,
  });

  UserModel copyWith({bool? hasActiveStay}) => UserModel(
        uid: uid,
        cin: cin,
        firstName: firstName,
        lastName: lastName,
        email: email,
        hasActiveStay: hasActiveStay ?? this.hasActiveStay,
      );
}

class HotelModel {
  final String id, name, location, description;
  final double rating;
  final List<ServiceModel> services;

  HotelModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.rating,
    required this.services,
  });

  String? get coverImage {
    const covers = {
      'seaside': 'assets/images/seaside_cover.jpg',
      'evergreen': 'assets/images/evergreen_cover.jpg',
      'sahara': 'assets/images/sahara_cover.jpg',
    };
    return covers[id];
  }
}

class ServiceModel {
  final String id, name, description, category, bookable;
  final int price;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.bookable,
  });

  bool get isRoom => bookable == 'room';
  String get priceLabel => isRoom
      ? '${NumberFormat('#,###').format(price)} DT/night'
      : '$price DT/pers';

  String? get imageAsset {
    const map = {
      's1': 'assets/images/seaside_room.jpg',
      's2': 'assets/images/seaside_suite.jpg',
      's3': 'assets/images/seaside_pool_ext.jpg',
      's4': 'assets/images/seaside_pool_int.jpg',
      's5': 'assets/images/seaside_restau.jpg',
      's6': 'assets/images/seaside_buffet.jpg',
      's7': 'assets/images/seaside_tennis.jpg',
      's8': 'assets/images/seaside_party.jpg',
      'e1': 'assets/images/evergreen_room.jpg',
      'e2': 'assets/images/evergreen_suite.jpg',
      'e3': 'assets/images/evergreen_pool.jpg',
      'e4': 'assets/images/evergreen_pool_int.jpg',
      'e5': 'assets/images/evergreen_restau.jpg',
      'e6': 'assets/images/evergreen_buffet.jpg',
      'e7': 'assets/images/evergreen_spa.jpg',
      'e8': 'assets/images/evergreen_basket.jpg',
      'e9': 'assets/images/evergreen_party.jpg',
      'sa1': 'assets/images/sahara_room.jpg',
      'sa2': 'assets/images/sahara_suite.jpg',
      'sa3': 'assets/images/sahara_pool.jpg',
      'sa4': 'assets/images/sahara_pool_int.jpg',
      'sa5': 'assets/images/sahara_restau.jpg',
      'sa6': 'assets/images/sahara_buffet.jpg',
      'sa7': 'assets/images/sahara_spa.jpg',
      'sa8': 'assets/images/sahara_yoga.jpg',
      'sa9': 'assets/images/sahara_party.jpg',
    };
    return map[id];
  }

  String get categoryIcon {
    const icons = {
      'room': '🛏️',
      'pool': '🏊',
      'dining': '🍽️',
      'sport': '🎾',
      'spa': '💆',
      'entertainment': '🎉',
    };
    return icons[category] ?? '📌';
  }
}

class PriceCalc {
  static int roomTotal({
    required int perNight,
    required int nights,
    required int adults,
    required int children,
    required String formula,
    required bool sport,
    required bool spa,
  }) {
    const formulaPrices = {
      'All Inclusive': 500,
      'All Inclusive Soft': 300,
      'Half Board': 150,
      'Bed & Breakfast': 0,
    };
    final pers = adults + children;
    return nights * perNight +
        nights * pers * (formulaPrices[formula] ?? 0) +
        (sport ? pers * 800 : 0) +
        (spa ? pers * 1200 : 0);
  }
}
