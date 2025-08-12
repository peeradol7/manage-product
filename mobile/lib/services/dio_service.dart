import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../models/sku_master.dart';

class ApiService {
  late Dio _dio;
  static const String baseUrl = 'https://3f62d0f18ca2.ngrok-free.app/api';
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
        },
        validateStatus: (status) {
          return status! < 500; // Accept any status code below 500
        },
      ),
    );

    // Configure HTTP client for SSL
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
                // Allow certificates for ngrok domains
                if (host.contains('ngrok-free.app') ||
                    host.contains('ngrok.io') ||
                    host.contains('ngrok.app')) {
                  return true;
                }
                return false;
              };
          return client;
        };

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  Future<PaginationResponse<SkuMasterList>> getSkuMasterList({
    int page = 1,
    int pageSize = 20,
    String? searchTerm,
    bool filterNoImages = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['searchTerm'] = searchTerm;
      }

      if (filterNoImages) {
        queryParams['filterNoImages'] = filterNoImages;
      }

      final response = await _dio.get(
        '/SkuMaster/list',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginationResponse.fromJson(
          response.data,
          (json) => SkuMasterList.fromJson(json),
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load SkuMaster list',
        );
      }
    } on DioException catch (e) {
      print('DioException in getSkuMasterList: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('Unexpected error in getSkuMasterList: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SkuMasterDetail> getSkuMasterDetail(int skuKey) async {
    try {
      final response = await _dio.get('/SkuMaster/$skuKey/detail');

      if (response.statusCode == 200) {
        return SkuMasterDetail.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load SkuMaster detail',
        );
      }
    } on DioException catch (e) {
      print('DioException in getSkuMasterDetail: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('Unexpected error in getSkuMasterDetail: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // 3. Update SkuMaster (Name, Images, Size)
  Future<UpdateSkuMasterResponse> updateSkuMaster({
    required UpdateSkuMasterRequest request,
    List<File>? newImages,
  }) async {
    try {
      FormData formData = FormData();

      // Add text fields
      final Map<String, dynamic> formFields = request.toFormData();
      formFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add image files
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          String fileName = newImages[i].path.split('/').last;
          formData.files.add(
            MapEntry(
              'NewImages',
              await MultipartFile.fromFile(
                newImages[i].path,
                filename: fileName,
              ),
            ),
          );
        }
      }

      final response = await _dio.post(
        '/SkuMasterImage/update',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        return UpdateSkuMasterResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to update SkuMaster',
        );
      }
    } on DioException catch (e) {
      print('DioException in updateSkuMaster: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('Unexpected error in updateSkuMaster: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to handle DioException
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout');
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          return Exception('Resource not found');
        } else if (e.response?.statusCode == 500) {
          return Exception('Server error');
        } else {
          return Exception(
            'HTTP ${e.response?.statusCode}: ${e.response?.statusMessage}',
          );
        }
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return Exception('No internet connection');
        }
        return Exception('Unknown error: ${e.message}');
      default:
        return Exception('Network error: ${e.message}');
    }
  }

  // 4. Update SkuMaster Basic Info (Name, Price, Discontinued status)
  Future<bool> updateSkuMasterBasic({
    required int skuKey,
    required UpdateSkuMasterBasicRequest request,
  }) async {
    try {
      final response = await _dio.put(
        '/SkuMaster/$skuKey/update-basic',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('DioException in updateSkuMasterBasic: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('Unexpected error in updateSkuMasterBasic: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/SkuMaster/list?page=1&pageSize=1');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
