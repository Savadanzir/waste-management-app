import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'admin_api.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: "admin@ecogurd.com");
  final _password = TextEditingController();
  bool _loading = false;
  bool _show = false;

  String get _baseUrl {
    if (kIsWeb) return "http://localhost:5000";
    return "http://10.0.2.2:5000";
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Map<String, dynamic> safeDecode(String body) {
    final b = body.isEmpty ? "{}" : body.trimLeft();

    // If server returned HTML -> wrong route
    if (b.startsWith("<!DOCTYPE") || b.startsWith("<html")) {
      return {
        "success": false,
        "message": "Wrong API URL/route. Server returned HTML not JSON."
      };
    }

    try {
      final decoded = jsonDecode(b);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"success": false, "message": "Invalid server response (not JSON object)."};
    } catch (_) {
      return {"success": false, "message": "Invalid JSON from server."};
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final api = AdminApi(baseUrl: _baseUrl);

      final res = await api.login(
        _email.text.trim(),
        _password.text.trim(),
      );

      // ✅ NEVER call res["token"]() or res["admin"]()
      final success = res["success"] == true;
      final token = res["token"];

      if (!mounted) return;

      if (success && token is String && token.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin login success ✅")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(api: api, token: token),
          ),
        );
      } else {
        final msg = (res["message"] ?? "Login failed").toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login"), backgroundColor: Colors.green),
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/ecogurd.png", height: 90),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Enter email";
                      if (!v.contains("@")) return "Enter valid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _password,
                    obscureText: !_show,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _show = !_show),
                        icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Enter password";
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}