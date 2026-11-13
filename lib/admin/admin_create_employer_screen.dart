import 'package:flutter/material.dart';
import 'admin_api.dart';

class AdminCreateEmployerScreen extends StatefulWidget {
  final AdminApi api;
  final String token;

  const AdminCreateEmployerScreen({
    super.key,
    required this.api,
    required this.token,
  });

  @override
  State<AdminCreateEmployerScreen> createState() => _AdminCreateEmployerScreenState();
}

class _AdminCreateEmployerScreenState extends State<AdminCreateEmployerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await widget.api.createEmployer(
        widget.token,
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      if (!mounted) return;

      final created = res["data"];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Employer created ✅ ${created["email"]}")),
      );

      _name.clear();
      _email.clear();
      _password.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Employer"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Employer Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: "Employer Email",
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
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: "Employer Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Enter password";
                  if (v.trim().length < 6) return "Minimum 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Create Employer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}