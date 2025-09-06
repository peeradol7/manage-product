import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../models/sku_master.dart';

class ApiService {
  late Dio _dio;
  static const String baseUrl = 'https://86ed19c82374.ngrok-free.app/api';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
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
                // Allow all ngrok domains
                if (host.contains('ngrok') ||
                    host.contains('localhost') ||
                    host.contains('127.0.0.1')) {
                  return true;
                }
                return false;
              };
          return client;
        };

    // Only log in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) {
          // Only log errors in production
          if (obj.toString().contains('ERROR')) {
            print(obj);
          }
        },
      ),
    );

    // Add retry interceptor for connection issues
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            print('Connection timeout, retrying...');
            // Retry once
            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              print('Retry failed: $e');
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<PaginationResponse<SkuMasterList>> getSkuMasterList({
    int page = 1,
    int pageSize = 20,
    String? searchTerm,
    bool filterNoImages = false,
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['searchTerm'] = searchTerm;
      }

      if (filterNoImages) {
        queryParams['filterNoImages'] = filterNoImages;
      }

      // Add cache busting parameter when force refresh is requested
      if (forceRefresh) {
        queryParams['_t'] = DateTime.now().millisecondsSinceEpoch;
      }

      final response = await _dio.get(
        '/SkuMaster/list',
        queryParameters: queryParams,
        options: Options(headers: {'Cache-Control': 'no-cache'}),
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

  Future<SkuMasterDetail> getSkuMasterDetail(
    int skuKey, {
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      final headers = <String, dynamic>{};

      // Always use strong cache busting for now
      queryParams['_t'] = DateTime.now().millisecondsSinceEpoch;
      headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
      headers['Pragma'] = 'no-cache';
      headers['Expires'] = '0';

      final response = await _dio.get(
        '/SkuMaster/$skuKey/detail',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Debug: Print response data to see what we're getting
        print('API Response for SKU $skuKey: ${response.data}');
        final product = SkuMasterDetail.fromJson(response.data);
        print(
          'Parsed product - Width: ${product.width}, Length: ${product.length}, Height: ${product.height}, Weight: ${product.weight}',
        );
        return product;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load SkuMaster detail',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UpdateSkuMasterResponse> updateSkuMaster({
    required UpdateSkuMasterRequest request,
    List<File>? newImages,
  }) async {
    try {
      FormData formData = FormData();

      final Map<String, dynamic> formFields = request.toFormData();
      formFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

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
      } else if (response.statusCode == 400) {
        // Handle BadRequest - parse the response to get error details
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
      print('Testing connection to: $baseUrl');
      final response = await _dio.get('/SkuMaster/list?page=1&pageSize=1');
      print('Connection test successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      if (e is DioException) {
        print('DioException type: ${e.type}');
        print('DioException message: ${e.message}');
      }
      return false;
    }
  }
}
