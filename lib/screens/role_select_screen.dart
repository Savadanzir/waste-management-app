import 'package:flutter/material.dart';
import '../admin/admin_login_screen.dart';
import 'login_screen.dart'; // your user login screen

// ✅ ADD THIS (create this screen file/class, or change to your employer screen)
// ignore: unused_import
import '../employer/employer_login_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset("assets/ecogurd.png", height: 100),
                const SizedBox(height: 14),
                const Text(
                  "Continue as",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text("User"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text("Admin"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade900,
                      side: BorderSide(color: Colors.green.shade700, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                      );
                    },
                  ),
                ),

                 ],
            ),
          ),
        ),
      ),
    );
  }
}