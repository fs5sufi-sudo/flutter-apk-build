import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required bool isAgent,
    String? phoneNumber,
    String? bio,
    XFile? avatar,
  }) async {
    final url = Uri.parse('$baseUrl/accounts/register/');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['is_agent'] = isAgent.toString();
      
      if (isAgent) {
        if (phoneNumber != null) request.fields['phone_number'] = phoneNumber;
        if (bio != null) request.fields['bio'] = bio;
        
        if (avatar != null) {
          if (kIsWeb) {
            var bytes = await avatar.readAsBytes();
            request.files.add(http.MultipartFile.fromBytes('avatar', bytes, filename: avatar.name));
          } else {
            request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
          }
        }
      }

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/accounts/login/');
    try {
      final response = await http.post(
        url,
        body: json.encode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await _fetchAndSaveUserProfile(token);
        return true;
      }
      return false;
    } catch (e) { return false; }
  }

  Future<void> _fetchAndSaveUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/accounts/profile/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setBool('is_agent', data['is_agent'] ?? false);
        await prefs.setBool('is_approved', data['is_approved'] ?? false);
        // ذخیره وضعیت مدیر بودن (is_staff)
        await prefs.setBool('is_staff', data['is_staff'] ?? false);
        
        await prefs.setString('username', data['username'] ?? '');
        if (data['avatar'] != null) await prefs.setString('avatar', data['avatar']);
      }
    } catch (e) { print(e); }
  }

  Future<bool> isAgent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_agent') ?? false;
  }

  Future<bool> isUserApproved() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) await _fetchAndSaveUserProfile(token);
    return prefs.getBool('is_approved') ?? false;
  }

  // متد جدید: آیا کاربر مدیر است؟
  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_staff') ?? false;
  }

  // --- متدهای پنل مدیریت ---
  Future<List<dynamic>> getPendingAgents() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/accounts/admin/pending-agents/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> approveAgent(int id) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/accounts/admin/approve-agent/$id/');
    try {
      final response = await http.post(url, headers: {'Authorization': 'Token $token'});
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<Map<String, dynamic>> getSystemSettings() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/accounts/admin/settings/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'free_listings_limit': 3};
    } catch (e) { return {'free_listings_limit': 3}; }
  }

  Future<bool> updateSystemSettings(int limit) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/accounts/admin/settings/');
    try {
      final response = await http.post(
        url, 
        headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
        body: json.encode({'free_listings_limit': limit}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
  // -----------------------

  Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;
    final url = Uri.parse('$baseUrl/accounts/profile/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) { return null; }
  }

  Future<bool> updateProfile(Map<String, String> fields, XFile? avatar) async {
    final url = Uri.parse('$baseUrl/accounts/profile/');
    final token = await getToken();
    if (token == null) return false;

    try {
      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Token $token';
      request.fields.addAll(fields);

      if (avatar != null) {
        if (kIsWeb) {
          var bytes = await avatar.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('avatar', bytes, filename: avatar.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
        }
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
