import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  // آدرس را چک کنید
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
      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      return false;
    }
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
        
        // ذخیره توکن
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        // --- دریافت و ذخیره نقش کاربر (مهم) ---
        await _fetchAndSaveUserProfile(token);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // متد کمکی برای گرفتن اطلاعات کاربر و ذخیره نقش‌ها
  Future<void> _fetchAndSaveUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/accounts/profile/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Token $token'});
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        
        // ذخیره وضعیت‌ها
        await prefs.setBool('is_agent', data['is_agent'] ?? false);
        await prefs.setBool('is_approved', data['is_approved'] ?? false);
        await prefs.setString('username', data['username'] ?? '');
        if (data['avatar'] != null) await prefs.setString('avatar', data['avatar']);
      }
    } catch (e) {
      print('Profile fetch error: $e');
    }
  }

  // چک کردن اینکه آیا مشاور است؟
  Future<bool> isAgent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_agent') ?? false;
  }

  // چک کردن اینکه آیا تأیید شده؟
  Future<bool> isUserApproved() async {
    final prefs = await SharedPreferences.getInstance();
    // برای اطمینان، اگر توکن بود دوباره پروفایل را بگیر (چون شاید مدیر تازه تأیید کرده باشد)
    final token = prefs.getString('auth_token');
    if (token != null) await _fetchAndSaveUserProfile(token);
    
    return prefs.getBool('is_approved') ?? false;
  }

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
    await prefs.clear(); // همه اطلاعات (توکن، نقش، عکس) پاک شود
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
