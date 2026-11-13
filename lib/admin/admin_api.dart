import 'dart:convert';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:waste_management_system/employer/employer_login_screen.dart';

class AdminApi {
  final String baseUrl;
  AdminApi({required this.baseUrl});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/api/admin/login");

    try {
      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 12));

      print("ADMIN LOGIN URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      return _decode(res);
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<List<dynamic>> getComplaints(String token) async {
    final url = Uri.parse("$baseUrl/api/complaints/admin");
    try {
      final res = await http
          .get(url, headers: {"Authorization": "Bearer $token"})
          .timeout(const Duration(seconds: 12));

      print("GET COMPLAINTS URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      final data = _decode(res);
      return (data["data"] ?? []) as List<dynamic>;
    } catch (e) {
      throw Exception("Fetching complaints failed: $e");
    }
  }

  Future<List<dynamic>> getPickups(String token) async {
    final url = Uri.parse("$baseUrl/api/admin/pickups");
    try {
      final res = await http
          .get(url, headers: {"Authorization": "Bearer $token"})
          .timeout(const Duration(seconds: 12));

      print("GET PICKUPS URL => $url");
      print("STATUS => ${res.statusCode}");

      final data = _decode(res);
      return (data["data"] ?? []) as List<dynamic>;
    } catch (e) {
      throw Exception("Fetching pickups failed: $e");
    }
  }

  Future<void> updateComplaintStatus(
    String token,
    String id,
    String status,
  ) async {
    final url = Uri.parse("$baseUrl/api/admin/complaints/$id/status");
    try {
      final res = await http
          .patch(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"status": status}),
          )
          .timeout(const Duration(seconds: 12));

      print("UPDATE COMPLAINT STATUS URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      _decode(res);
    } catch (e) {
      throw Exception("Updating complaint failed: $e");
    }
  }

  Future<void> updatePickupStatus(
    String token,
    String id,
    String status,
  ) async {
    final url = Uri.parse("$baseUrl/api/admin/pickups/$id/status");
    try {
      final res = await http
          .patch(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"status": status}),
          )
          .timeout(const Duration(seconds: 12));

      print("UPDATE PICKUP STATUS URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      _decode(res);
    } catch (e) {
      throw Exception("Updating pickup failed: $e");
    }
  }

  Future<void> approvePickup(String token, String id) async {
    final url = Uri.parse("$baseUrl/api/admin/pickups/$id/approve");
    try {
      final res = await http
          .patch(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 12));

      print("APPROVE PICKUP URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      _decode(res);
    } catch (e) {
      throw Exception("Approving pickup failed: $e");
    }
  }

  Future<void> rejectPickup(String token, String id) async {
    final url = Uri.parse("$baseUrl/api/admin/pickups/$id/reject");
    try {
      final res = await http
          .patch(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 12));

      print("REJECT PICKUP URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      _decode(res);
    } catch (e) {
      throw Exception("Rejecting pickup failed: $e");
    }
  }

  Future<List<dynamic>> getNotHomeAlerts(String token) async {
    final url = Uri.parse("$baseUrl/api/admin/not-home");
    try {
      final res = await http
          .get(url, headers: {"Authorization": "Bearer $token"})
          .timeout(const Duration(seconds: 12));

      print("GET NOT-HOME ALERTS URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      final data = _decode(res);
      return (data["data"] ?? []) as List<dynamic>;
    } catch (e) {
      throw Exception("Fetching not-home alerts failed: $e");
    }
  }

  Future<void> resolveNotHomeAlert(String token, String id) async {
    final url = Uri.parse("$baseUrl/api/admin/not-home/$id/resolve");
    try {
      final res = await http
          .patch(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 12));

      print("RESOLVE NOT-HOME ALERT URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      _decode(res);
    } catch (e) {
      throw Exception("Resolving not-home alert failed: $e");
    }
  }

  Map<String, dynamic> _decode(http.Response res) {
    final body = res.body.isEmpty ? "{}" : res.body;

    final trimmed = body.trimLeft();
    if (trimmed.startsWith("<!DOCTYPE") || trimmed.startsWith("<html")) {
      throw Exception(
          "Wrong API URL or route missing. Server returned HTML, not JSON.");
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
          "Invalid JSON from server (status ${res.statusCode}). Body: $body");
    }

    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Request failed (${res.statusCode})");
    }

    return data;
  }

  // ✅ FIXED: CREATE EMPLOYER (ADMIN)
  Future<Map<String, dynamic>> createEmployer(
    String token, {
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/admin/employers");

    try {
      final res = await http
          .post(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 12));

      print("CREATE EMPLOYER URL => $url");
      print("STATUS => ${res.statusCode}");
      print("BODY => ${res.body}");

      return _decode(res);
    } catch (e) {
      throw Exception("Creating employer failed: $e");
    }
  }
}