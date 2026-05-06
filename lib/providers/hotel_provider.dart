import 'package:flutter/material.dart';
import '../models/models.dart';

class HotelProvider extends ChangeNotifier {
  final List<HotelModel> hotels = [
    HotelModel(
      id: 'seaside',
      name: 'Seaside Hotel',
      location: 'Mediterranean Coast',
      rating: 4.8,
      description:
          'Nestled along the shimmering Mediterranean shoreline, Seaside Hotel offers breathtaking ocean views, world-class dining, and unparalleled relaxation.',
      services: [
        ServiceModel(id: 's1', name: 'Sea View Room', description: 'Panoramic ocean views with floor-to-ceiling windows, king-size bed, marble bathroom and private balcony.', price: 4500, category: 'room', bookable: 'room'),
        ServiceModel(id: 's2', name: 'Premium Suite', description: 'Spacious luxury suite with living area, jacuzzi, butler service and sea-facing terrace.', price: 7200, category: 'room', bookable: 'room'),
        ServiceModel(id: 's3', name: 'Outdoor Pool', description: 'Infinity pool overlooking the Mediterranean with sun loungers and poolside bar.', price: 180, category: 'pool', bookable: 'activity'),
        ServiceModel(id: 's4', name: 'Indoor Pool', description: 'Year-round heated indoor pool with spa jets, sauna and steam room.', price: 150, category: 'pool', bookable: 'activity'),
        ServiceModel(id: 's5', name: 'Le Rivage Restaurant', description: 'Fine dining with Mediterranean seafood, local wines and sea views.', price: 280, category: 'dining', bookable: 'dining'),
        ServiceModel(id: 's6', name: 'Grand Buffet', description: 'International buffet with 150+ dishes and live cooking stations.', price: 220, category: 'dining', bookable: 'dining'),
        ServiceModel(id: 's7', name: 'Tennis Court', description: 'Professional clay courts with floodlights and coaching.', price: 140, category: 'sport', bookable: 'activity'),
        ServiceModel(id: 's8', name: 'Beach Party', description: 'Beachfront events with live DJs, fire shows and cocktails.', price: 320, category: 'entertainment', bookable: 'event'),
      ],
    ),
    HotelModel(
      id: 'evergreen',
      name: 'Evergreen Hotel',
      location: 'Forest & Mountains',
      rating: 4.9,
      description:
          'Surrounded by ancient forests and majestic peaks. Eco-luxury meets adventure in this breathtaking mountain retreat.',
      services: [
        ServiceModel(id: 'e1', name: 'Forest View Room', description: 'Elegant room with forest views, natural wood finishes and private balcony.', price: 4200, category: 'room', bookable: 'room'),
        ServiceModel(id: 'e2', name: 'Panoramic Suite', description: 'Mountain suite with fireplace, rain shower and terrace with hot tub.', price: 6800, category: 'room', bookable: 'room'),
        ServiceModel(id: 'e3', name: 'Mountain Pool', description: 'Heated outdoor infinity pool with mountain panorama.', price: 170, category: 'pool', bookable: 'activity'),
        ServiceModel(id: 'e4', name: 'Wellness Pool', description: 'Therapeutic indoor pool with mineral water and grotto.', price: 160, category: 'pool', bookable: 'activity'),
        ServiceModel(id: 'e5', name: 'Canopy Restaurant', description: 'Farm-to-table dining in treehouse setting with organic ingredients.', price: 300, category: 'dining', bookable: 'dining'),
        ServiceModel(id: 'e6', name: 'Organic Buffet', description: 'Sustainable buffet with organic produce and artisan breads.', price: 240, category: 'dining', bookable: 'dining'),
        ServiceModel(id: 'e7', name: 'Spa & Jacuzzi', description: 'Alpine spa with hot stone therapy, aromatherapy and sauna.', price: 350, category: 'spa', bookable: 'activity'),
        ServiceModel(id: 'e8', name: 'Basketball Court', description: 'Professional indoor court with equipment provided.', price: 120, category: 'sport', bookable: 'activity'),
        ServiceModel(id: 'e9', name: 'Garden Gala', description: 'Garden parties with lanterns, live jazz and premium cocktails.', price: 290, category: 'entertainment', bookable: 'event'),
      ],
    ),
    HotelModel(
      id: 'sahara',
      name: 'Sahara Hotel',
      location: 'Desert & Oasis',
      rating: 4.7,
      description:
          'Where golden dunes meet timeless elegance. A mystical desert experience with luxurious amenities and cultural immersion.',
      services: [
        ServiceModel(id: 'sa1', name: 'Desert Room', description: 'Saharan-style room with handcrafted furnishings and desert views.', price: 4800, category: 'room', bookable: 'room'),
        ServiceModel(id: 'sa2', name: 'Oasis Suite', description: 'Lavish suite with dune views, private plunge pool and butler.', price: 8500, category: 'room', bookable: 'room'),
        ServiceModel(id: 'sa3', name: 'Desert Pool', description: 'Oasis-style pool with cabanas and sunset cocktail service.', price: 190, category: 'pool', bookable: 'activity'),
        ServiceModel(id: 'sa4', name: 'Grotto Pool', description: 'Underground pool in a cave with ambient lighting and springs.', price: 170, category: 'pool', bookable: 'activity'),
        ServiceModel(id: 'sa5', name: 'Cave Restaurant', description: 'Dining inside a natural cave with Saharan cuisine and oud music.', price: 320, category: 'dining', bookable: 'dining'),
        ServiceModel(id: 'sa6', name: 'Dunes Buffet', description: 'Open-air buffet under Berber tents with tagines and grilled meats.', price: 230, category: 'dining', bookable: 'dining'),
        ServiceModel(id: 'sa7', name: 'Thalasso Spa', description: 'Thalassotherapy with sand baths, hammam and essential oils.', price: 380, category: 'spa', bookable: 'activity'),
        ServiceModel(id: 'sa8', name: 'Sunrise Yoga', description: 'Daily yoga on a desert terrace at sunrise.', price: 110, category: 'sport', bookable: 'activity'),
        ServiceModel(id: 'sa9', name: 'Fire Show', description: 'Desert fire performance with Berber music and stargazing.', price: 270, category: 'entertainment', bookable: 'event'),
      ],
    ),
  ];
}
