import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WasteApi {
  WasteApi._();

  // ✅ Change this IP when using a real phone on same WiFi (example: 192.168.1.10)
  static const String _androidEmulatorBase = "http://10.0.2.2:5000";
  static const String _webBase = "http://localhost:5000";

  static String get baseUrl => kIsWeb ? _webBase : _androidEmulatorBase;

  static Future<Map<String, dynamic>> createPickupRequest({
    String? userId,
    required String wasteType,
    required String pickupAddress,
    required String pickupDate, // "yyyy-mm-dd"
    required String pickupTime, // "HH:mm"
    String notes = "",
  }) async {
    final uri = Uri.parse("$baseUrl/api/waste/pickup");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "wasteType": wasteType,
        "pickupAddress": pickupAddress,
        "pickupDate": pickupDate,
        "pickupTime": pickupTime,
        "notes": notes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data; // {success:true,data:{...}}
    } else {
      throw Exception(data["message"] ?? "Failed to submit request");
    }
  }
}
