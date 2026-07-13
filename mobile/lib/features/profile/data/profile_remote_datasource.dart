import 'package:dio/dio.dart';
import 'package:coffee_card/core/constants/api_endpoints.dart';
import 'package:coffee_card/core/network/dio_client.dart';
import 'package:coffee_card/features/auth/domain/user_model.dart';
import 'package:coffee_card/features/profile/domain/profile_model.dart';

class ProfileRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      return UserModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.me,
        data: {
          if (request.displayName != null) 'displayName': request.displayName,
          if (request.avatarUrl != null) 'avatarUrl': request.avatarUrl,
        },
      );
      return UserModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.addresses);
      final data = response.data!['data'] as List<dynamic>;
      return data.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AddressModel> addAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addresses,
        data: addressData,
      );
      return AddressModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AddressModel> updateAddress(String id, Map<String, dynamic> addressData) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.addressById(id),
        data: addressData,
      );
      return AddressModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete<void>(ApiEndpoints.addressById(id));
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
