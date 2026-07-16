import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';

/// One address suggestion from the backend Places proxy.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => PlaceSuggestion(
        placeId: json['placeId'] as String? ?? '',
        description: json['description'] as String? ?? '',
        mainText: json['mainText'] as String? ?? '',
        secondaryText: json['secondaryText'] as String? ?? '',
      );
}

/// Structured address resolved from a place id.
class PlaceAddress {
  const PlaceAddress({
    required this.formattedAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  final String formattedAddress;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  factory PlaceAddress.fromJson(Map<String, dynamic> json) => PlaceAddress(
        formattedAddress: json['formattedAddress'] as String? ?? '',
        street: json['street'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
        country: json['country'] as String? ?? '',
      );
}

/// Talks to the server-side Google Places proxy — the API key stays on the
/// backend, never in the app bundle.
class PlacesDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<List<PlaceSuggestion>> autocomplete(String input) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.placesAutocomplete,
        queryParameters: {'input': input},
      );
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<PlaceAddress> details(String placeId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.placeDetails(placeId),
      );
      return PlaceAddress.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
