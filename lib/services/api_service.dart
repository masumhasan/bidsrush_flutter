import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/stream_model.dart';
import '../models/product_model.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = AppConstants.apiBaseUrl;
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Stream APIs
  Future<List<StreamModel>> getActiveStreams() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${AppConstants.streamEndpoint}'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StreamModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load streams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching streams: $e');
    }
  }

  Future<StreamModel> createStream({
    required String callId,
    required String title,
    required bool isRecordingEnabled,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.streamEndpoint}'),
            headers: _headers,
            body: json.encode({
              'callId': callId,
              'title': title,
              'isRecordingEnabled': isRecordingEnabled,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 201) {
        return StreamModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating stream: $e');
    }
  }

  Future<StreamModel> getStreamDetails(String callId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${AppConstants.streamEndpoint}/$callId'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return StreamModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stream details: $e');
    }
  }

  Future<void> endStream(String callId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.streamEndpoint}/$callId/end'),
            headers: _headers,
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to end stream: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ending stream: $e');
    }
  }

  Future<List<StreamModel>> getRecordedStreams({String? userId}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl${AppConstants.streamEndpoint}/recorded',
      ).replace(queryParameters: userId != null ? {'userId': userId} : null);

      final response = await http
          .get(uri, headers: _headers)
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StreamModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load recorded streams: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching recorded streams: $e');
    }
  }

  String getRecordingVideoUrl(String callId) {
    return '$baseUrl${AppConstants.streamEndpoint}/$callId/recording/video';
  }

  // Product APIs
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${AppConstants.productsEndpoint}'))
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<ProductModel> createProduct({
    required String name,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.productsEndpoint}'),
            headers: _headers,
            body: json.encode({
              'name': name,
              'description': description,
              'price': price,
              'imageUrl': imageUrl,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 201) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Stream.io Token
  Future<Map<String, String>> getStreamToken() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl${AppConstants.streamTokenEndpoint}'),
            headers: _headers,
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'token': data['token'] as String,
          'apiKey': data['apiKey'] as String,
        };
      } else {
        throw Exception('Failed to get stream token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting stream token: $e');
    }
  }
}
