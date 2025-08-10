import 'package:dio/dio.dart';
import 'dart:io';
import '../models/sku_master.dart';

class ApiService {
  late Dio _dio;
  static const String baseUrl = 'http://10.210.160.210:5900/api';
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  // 1. Get SkuMaster List with Pagination
  Future<PaginationResponse<SkuMasterList>> getSkuMasterList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/SkuMaster/list',
        queryParameters: {'page': page, 'pageSize': pageSize},
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

  // 2. Get SkuMaster Detail
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
