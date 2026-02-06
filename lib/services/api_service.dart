import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../models/listing.dart';
import '../models/agent.dart';
import '../models/subscription_package.dart'; // ایمپورت مدل جدید
import 'auth_service.dart';

class ApiService {
  // آدرس سرور
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // --- متدهای جدید: اشتراک ---
  
  // 1. دریافت لیست بسته‌ها
  Future<List<SubscriptionPackage>> fetchPackages() async {
    final url = Uri.parse('$baseUrl/accounts/packages/');
    final token = await AuthService().getToken();
    if (token == null) return [];

    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => SubscriptionPackage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. خرید بسته
  Future<bool> buyPackage(int packageId) async {
    final url = Uri.parse('$baseUrl/accounts/packages/buy/$packageId/');
    final token = await AuthService().getToken();
    if (token == null) return false;

    try {
      final response = await http.post(url, headers: {'Authorization': 'Token $token'});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // ---------------------------

  Future<List<Listing>> fetchListings({
    String? city,
    String? propertyType,
    String? minPrice,
    String? maxPrice,
  }) async {
    String query = '$baseUrl/listings/?';
    if (city != null && city.isNotEmpty) query += 'city__icontains=$city&';
    if (propertyType != null && propertyType.isNotEmpty) query += 'property_type=$propertyType&';
    if (minPrice != null && minPrice.isNotEmpty) query += 'price__gte=$minPrice&';
    if (maxPrice != null && maxPrice.isNotEmpty) query += 'price__lte=$maxPrice&';

    final url = Uri.parse(query);
    final token = await AuthService().getToken();

    try {
      final response = await http.get(
        url,
        headers: token != null 
            ? {'Authorization': 'Token $token', 'Content-Type': 'application/json'}
            : {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<List<Listing>> fetchMyListings() async {
    final url = Uri.parse('$baseUrl/listings/my_listings/');
    final token = await AuthService().getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<bool> toggleFavorite(int id) async {
    final url = Uri.parse('$baseUrl/listings/$id/toggle_favorite/');
    final token = await AuthService().getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Listing>> fetchFavorites() async {
    final url = Uri.parse('$baseUrl/listings/favorites/');
    final token = await AuthService().getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<bool> deleteListing(int id) async {
    final url = Uri.parse('$baseUrl/listings/$id/');
    final token = await AuthService().getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGalleryImage(int imageId) async {
    final url = Uri.parse('$baseUrl/listing-images/$imageId/');
    final token = await AuthService().getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateListing(
      int id, 
      Map<String, String> fields, 
      {XFile? newMainImage, List<XFile>? newGalleryImages}
  ) async {
    final url = Uri.parse('$baseUrl/listings/$id/');
    final token = await AuthService().getToken();
    if (token == null) return false;

    try {
      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Token $token';
      request.fields.addAll(fields);

      Future<void> addFileToRequest(String fieldName, XFile file) async {
        if (kIsWeb) {
          var bytes = await file.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            fieldName,
            bytes,
            filename: file.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
        }
      }

      if (newMainImage != null) {
        await addFileToRequest('image', newMainImage);
      }

      if (newGalleryImages != null) {
        for (var img in newGalleryImages) {
          await addFileToRequest('uploaded_images', img);
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createSavedSearch({
    String? city,
    String? propertyType,
    String? minPrice,
    String? maxPrice,
  }) async {
    final url = Uri.parse('$baseUrl/saved-searches/');
    final token = await AuthService().getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'city': city,
          'property_type': propertyType,
          'min_price': minPrice,
          'max_price': maxPrice,
        }),
      );
      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchActiveAd() async {
    final url = Uri.parse('$baseUrl/listings/ad/active/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body == '{}') return null;
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createListing(
      Map<String, String> fields, 
      dynamic mainImage,       
      List<dynamic> galleryImages 
  ) async {
    final url = Uri.parse('$baseUrl/listings/');
    final token = await AuthService().getToken();
    if (token == null) return false;

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Token $token';
      request.fields.addAll(fields);

      Future<void> addFileToRequest(String fieldName, dynamic file) async {
        if (kIsWeb) {
          if (file != null) {
            var bytes = await file.readAsBytes();
            request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: file.name));
          }
        } else {
          if (file != null) {
             String path = (file is File) ? file.path : file.path;
             request.files.add(await http.MultipartFile.fromPath(fieldName, path));
          }
        }
      }

      await addFileToRequest('image', mainImage);
      for (var img in galleryImages) {
        await addFileToRequest('uploaded_images', img);
      }

      var response = await request.send();
      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Agent> fetchAgentProfile(int agentId) async {
    final url = Uri.parse('$baseUrl/accounts/agent/$agentId/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Agent.fromJson(data);
      } else {
        return Agent(id: agentId, username: 'مشاور', email: '');
      }
    } catch (e) {
      return Agent(id: agentId, username: 'مشاور', email: '');
    }
  }

  Future<List<Listing>> fetchAgentListings(int agentId) async {
    final url = Uri.parse('$baseUrl/listings/?agent=$agentId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}
