import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/listing.dart';
import '../models/agent.dart';
import '../models/subscription_package.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  // ✅ متد جدید برای نوتیفیکیشن‌ها
  Future<List<dynamic>> getNotifications() async {
    final url = Uri.parse('$baseUrl/accounts/notifications/');
    final token = await AuthService().getToken();
    if (token == null) return [];
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) { return []; }
  }

  // --- سایر متدها (بدون تغییر) ---
  Future<int> getUnreadMessagesCount() async {
    final url = Uri.parse('$baseUrl/accounts/chat/unread-count/');
    final token = await AuthService().getToken();
    if (token == null) return 0;
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) { return 0; }
  }

  Future<List<dynamic>> getConversations() async {
    final url = Uri.parse('$baseUrl/accounts/chat/conversations/');
    final token = await AuthService().getToken();
    if (token == null) return [];
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> getMessages(int otherUserId) async {
    final url = Uri.parse('$baseUrl/accounts/chat/messages/$otherUserId/');
    final token = await AuthService().getToken();
    if (token == null) return [];
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> sendMessage(int receiverId, String content) async {
    final url = Uri.parse('$baseUrl/accounts/chat/send/');
    final token = await AuthService().getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
        body: json.encode({'receiver_id': receiverId, 'content': content}),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<List<dynamic>> getComments(int listingId) async {
    final url = Uri.parse('$baseUrl/listings/$listingId/comments/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> addComment(int listingId, String text) async {
    final url = Uri.parse('$baseUrl/listings/$listingId/add_comment/');
    final token = await AuthService().getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<void> incrementView(int id) async {
    final url = Uri.parse('$baseUrl/listings/$id/view_listing/'); 
    try { await http.get(url); } catch (e) {}
  }

  Future<Map<String, dynamic>> getAgentStats() async {
    final url = Uri.parse('$baseUrl/listings/agent_stats/');
    final token = await AuthService().getToken();
    if (token == null) return {};
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return {};
    } catch (e) { return {}; }
  }

  Future<bool> updateListingStatus(int id, String status) async {
    final url = Uri.parse('$baseUrl/listings/$id/update_status/');
    final token = await AuthService().getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<Map<String, dynamic>> changePassword(String oldPass, String newPass) async {
    final url = Uri.parse('$baseUrl/accounts/change-password/');
    final token = await AuthService().getToken();
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
        body: json.encode({'old_password': oldPass, 'new_password': newPass}),
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      return {'success': response.statusCode == 200, 'message': data['message'] ?? data['error']};
    } catch (e) { return {'success': false, 'message': 'خطای شبکه'}; }
  }

  Future<bool> deleteAccount() async {
    final url = Uri.parse('$baseUrl/accounts/delete-account/');
    final token = await AuthService().getToken();
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Token $token'});
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<Map<String, dynamic>> updateAccountInfo(String username, String email) async {
    final url = Uri.parse('$baseUrl/accounts/update-account/');
    final token = await AuthService().getToken();
    try {
      final response = await http.patch(
        url,
        headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'email': email}),
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      return {'success': response.statusCode == 200, 'message': data['message'] ?? data['error']};
    } catch (e) { return {'success': false, 'message': 'خطای شبکه'}; }
  }

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
    } catch (e) { return []; }
  }

  Future<Map<String, dynamic>> buyPackage(int packageId) async {
    final url = Uri.parse('$baseUrl/accounts/packages/buy/$packageId/');
    final token = await AuthService().getToken();
    if (token == null) return {'success': false, 'message': 'لطفاً وارد شوید'};
    try {
      final response = await http.post(url, headers: {'Authorization': 'Token $token'});
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'خرید موفق بود'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'خطا در خرید'};
      }
    } catch (e) { return {'success': false, 'message': 'خطای شبکه'}; }
  }

  Future<List<Listing>> fetchListings({String? city, String? propertyType, String? minPrice, String? maxPrice}) async {
    String query = '$baseUrl/listings/?';
    if (city != null && city.isNotEmpty) query += 'city__icontains=$city&';
    if (propertyType != null && propertyType.isNotEmpty) query += 'property_type=$propertyType&';
    if (minPrice != null && minPrice.isNotEmpty) query += 'price__gte=$minPrice&';
    if (maxPrice != null && maxPrice.isNotEmpty) query += 'price__lte=$maxPrice&';
    final url = Uri.parse(query);
    final token = await AuthService().getToken();
    try {
      final response = await http.get(url, headers: token != null ? {'Authorization': 'Token $token', 'Content-Type': 'application/json'} : {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else { throw Exception('Error: ${response.statusCode}'); }
    } catch (e) { throw Exception('Network Error: $e'); }
  }

  Future<List<Listing>> fetchMyListings() async {
    final url = Uri.parse('$baseUrl/listings/my_listings/');
    final token = await AuthService().getToken();
    if (token == null) return [];
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else { throw Exception('Error: ${response.statusCode}'); }
    } catch (e) { throw Exception('Network Error: $e'); }
  }

  Future<bool> toggleFavorite(int id) async {
    final url = Uri.parse('$baseUrl/listings/$id/toggle_favorite/');
    final token = await AuthService().getToken();
    if (token == null) return false;
    try {
      final response = await http.post(url, headers: {'Authorization': 'Token $token'});
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<List<Listing>> fetchFavorites() async {
    final url = Uri.parse('$baseUrl/listings/favorites/');
    final token = await AuthService().getToken();
    if (token == null) return [];
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else { throw Exception('Error: ${response.statusCode}'); }
    } catch (e) { throw Exception('Network Error: $e'); }
  }

  Future<bool> deleteListing(int id) async {
    final url = Uri.parse('$baseUrl/listings/$id/');
    final token = await AuthService().getToken();
    if (token == null) return false;
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Token $token'});
      return response.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<bool> deleteGalleryImage(int imageId) async {
    final url = Uri.parse('$baseUrl/listing-images/$imageId/');
    final token = await AuthService().getToken();
    if (token == null) return false;
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Token $token'});
      return response.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<bool> updateListing(int id, Map<String, String> fields, {XFile? newMainImage, List<XFile>? newGalleryImages}) async {
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
          request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: file.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
        }
      }
      if (newMainImage != null) await addFileToRequest('image', newMainImage);
      if (newGalleryImages != null) for (var img in newGalleryImages) await addFileToRequest('uploaded_images', img);
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> createSavedSearch({String? city, String? propertyType, String? minPrice, String? maxPrice}) async {
    final url = Uri.parse('$baseUrl/saved-searches/');
    final token = await AuthService().getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Token $token'},
        body: json.encode({'city': city, 'property_type': propertyType, 'min_price': minPrice, 'max_price': maxPrice}),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
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
    } catch (e) { return null; }
  }

  Future<bool> createListing(Map<String, String> fields, dynamic mainImage, List<dynamic> galleryImages) async {
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
      for (var img in galleryImages) await addFileToRequest('uploaded_images', img);
      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<Agent> fetchAgentProfile(int agentId) async {
    final url = Uri.parse('$baseUrl/accounts/agent/$agentId/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['avatar'] == null && data['avatar_url'] != null) data['avatar'] = data['avatar_url'];
        if (data['avatar'] != null && !data['avatar'].toString().startsWith('http')) {
           final base = baseUrl.replaceAll('/api', ''); 
           data['avatar'] = '$base${data['avatar']}';
        }
        return Agent.fromJson(data);
      } else { return Agent(id: agentId, username: 'مشاور', email: ''); }
    } catch (e) { return Agent(id: agentId, username: 'مشاور', email: ''); }
  }

  Future<List<Listing>> fetchAgentListings(int agentId) async {
    final url = Uri.parse('$baseUrl/listings/?agent=$agentId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Listing.fromJson(json)).toList();
      } else { throw Exception('Error: ${response.statusCode}'); }
    } catch (e) { throw Exception('Network Error: $e'); }
  }
}
