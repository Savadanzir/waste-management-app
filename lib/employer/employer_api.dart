import 'dart:convert';
import 'package:http/http.dart' as http;

class EmployerApi {
  final String baseUrl;
  EmployerApi({required this.baseUrl});

  Future<List<dynamic>> getAssignedAlerts(String token) async {
    final url = Uri.parse("$baseUrl/api/employer/assigned-alerts");
    final res = await http.get(url, headers: {"Authorization": "Bearer $token"});
    final body = res.body.isEmpty ? "{}" : res.body;

    Map<String, dynamic> data = jsonDecode(body);

    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Request failed (${res.statusCode})");
    }

    return (data["data"] ?? []) as List<dynamic>;
  }
}