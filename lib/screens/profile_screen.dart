import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_notifier.dart';
import 'package:waste_management_system/widgets/glass_animated_background.dart';
import 'package:waste_management_system/widgets/glass_section.dart';
// import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "-";
  String email = "-";
  String phone = "-";
  String? profileImagePath;

  final _usernameController = TextEditingController();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _loading = true;
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("current_user");

    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        fullName = (data["fullName"] ?? "-").toString();
        email = (data["email"] ?? "-").toString();
        phone = (data["phone"] ?? "-").toString();
        profileImagePath = (data["profileImagePath"] ?? "").toString().isEmpty
            ? null
            : (data["profileImagePath"] ?? "").toString();

        _usernameController.text = fullName;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveUserToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = {
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "profileImagePath": profileImagePath ?? "",
    };
    await prefs.setString("current_user", jsonEncode(userJson));
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      profileImagePath = picked.path;
    });

    await _saveUserToLocal();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile picture updated")),
    );
  }

  Future<void> _updateUsername() async {
    final newName = _usernameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username cannot be empty")),
      );
      return;
    }

    setState(() {
      fullName = newName;
    });
    await _saveUserToLocal();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Username updated")),
    );
  }

  Future<void> _changePassword() async {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all password fields")),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password must be at least 6 characters")),
      );
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password and confirm password do not match")),
      );
      return;
    }

    _oldPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password changed successfully")),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("current_user");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(
              child: GlassAnimatedBackground(),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TabBar(
                          tabs: const [
                            Tab(text: "Profile", icon: Icon(Icons.person)),
                            Tab(text: "Settings", icon: Icon(Icons.settings)),
                            Tab(text: "About Us", icon: Icon(Icons.info_outline)),
                          ],
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black54,
                          indicatorColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            children: [
                              _profileTab(),
                              _settingsTab(theme),
                              _aboutTab(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _profileAvatar(),
          const SizedBox(height: 16),
          GlassSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "User Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                _infoRow("Full Name", fullName),
                const Divider(),
                _infoRow("Email", email),
                const Divider(),
                _infoRow("Phone", phone),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color.fromARGB(255, 240, 84, 73)),
                foregroundColor: Colors.red,
                backgroundColor: Colors.white.withOpacity(0.35),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _logout,
              child: const Text("Logout"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTab(ThemeNotifier theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile Picture",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _smallAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 139, 188, 95),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _pickProfilePicture,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text("Change Picture"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Change Username",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.90),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 184, 151, 30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _updateUsername,
                    child: const Text("Save Username"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Change Password",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _oldPassController,
                  obscureText: !_showOld,
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.90),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _showOld = !_showOld),
                      icon: Icon(_showOld ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newPassController,
                  obscureText: !_showNew,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.90),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _showNew = !_showNew),
                      icon: Icon(_showNew ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmPassController,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.90),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                      icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 54, 239, 168),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _changePassword,
                    child: const Text("Update Password"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassSection(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Dark Mode"),
              subtitle: const Text("Change the app theme"),
              value: theme.isDark,
              onChanged: (v) => theme.setDark(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "About Waste Management System",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "This app helps citizens and waste collectors manage waste pickup efficiently.\n\n"
              "Purpose of the app:\n"
              "• Request waste pickup from your home or location\n"
              "• Track pickup status (pending / completed)\n"
              "• Raise complaints for missed pickups or issues\n"
              "• Learn proper waste segregation categories\n\n"
              "Our goal is to improve cleanliness, reduce improper dumping, and make waste collection faster and more organized.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: const Color.fromARGB(255, 149, 222, 186),
          backgroundImage: (profileImagePath != null && File(profileImagePath!).existsSync())
              ? FileImage(File(profileImagePath!))
              : null,
          child: (profileImagePath == null)
              ? const Icon(Icons.person, size: 60, color: Color.fromARGB(255, 5, 1, 11))
              : null,
        ),
        FloatingActionButton.small(
          backgroundColor: const Color.fromARGB(255, 69, 137, 247),
          onPressed: _pickProfilePicture,
          child: const Icon(Icons.camera_alt),
        )
      ],
    );
  }

  Widget _smallAvatar() {
    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color.fromARGB(255, 198, 202, 124),
      backgroundImage: (profileImagePath != null && File(profileImagePath!).existsSync())
          ? FileImage(File(profileImagePath!))
          : null,
      child: (profileImagePath == null)
          ? const Icon(Icons.person, size: 26, color: Color.fromARGB(255, 74, 45, 218))
          : null,
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(color: Color.fromARGB(230, 72, 26, 26)),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}