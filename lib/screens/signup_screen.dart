import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // ✅ NEW: Google Sign-In (named constructor)
 final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
  scopes: <String>['email'],
);

  

  // Animations
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  // ✅ Base URL
  String get _baseUrl {
    if (kIsWeb) return "http://localhost:5000";
    return "http://10.0.2.2:5000";
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse("$_baseUrl/api/users/register");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created ✅ Please login")),
        );
        Navigator.pop(context); // back to login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Signup failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ NEW: Google signup (auto fill name + email)
  Future<void> _signupWithGoogle() async {
  try {
    setState(() => _isLoading = true);

    final GoogleSignInAccount? account = await _googleSignIn.signIn();

    if (!mounted) return;

    if (account == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _nameController.text = account.displayName ?? "";
      _emailController.text = account.email;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google account selected ✅")),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Sign-In failed: $e")),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // -------- Background (same style as Login) --------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0EA75A),
                  Color(0xFF0B5C33),
                  Color(0xFF1BCB6B),
                ],
              ),
            ),
          ),

          const Positioned(top: -80, left: -60, child: _GlowBlob(size: 220)),
          const Positioned(bottom: -90, right: -70, child: _GlowBlob(size: 260)),

          SafeArea(
            child: Column(
              children: [
                // -------- Top bar (Back + Title) --------
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Signup",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // -------- Centered Card --------
                Expanded(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: _GlassCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Create Account",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    _GlassTextField(
                                      controller: _nameController,
                                      hintText: "Name",
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Enter name";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    _GlassTextField(
                                      controller: _emailController,
                                      hintText: "Email",
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Enter email";
                                        }
                                        if (!v.contains("@")) {
                                          return "Enter valid email";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    _GlassTextField(
                                      controller: _phoneController,
                                      hintText: "Phone Number",
                                      keyboardType: TextInputType.phone,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Enter phone number";
                                        }
                                        if (v.length < 8) {
                                          return "Enter valid phone number";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    _GlassTextField(
                                      controller: _passwordController,
                                      hintText: "Password",
                                      obscureText: !_isPasswordVisible,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Enter password";
                                        }
                                        if (v.length < 6) {
                                          return "Password must be 6+ characters";
                                        }
                                        return null;
                                      },
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        }),
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    _GlassTextField(
                                      controller: _confirmPasswordController,
                                      hintText: "Confirm Password",
                                      obscureText: !_isConfirmPasswordVisible,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Confirm password";
                                        }
                                        if (v !=
                                            _passwordController.text.trim()) {
                                          return "Passwords do not match";
                                        }
                                        return null;
                                      },
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        }),
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    // -------- Create Account button (kept) --------
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : registerUser,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF17D16B),
                                          disabledBackgroundColor:
                                              const Color(0xFF17D16B)
                                                  .withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                "Create Account",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                    ),

                                    // ✅ NEW Google button (added, not removing anything)
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            _isLoading ? null : _signupWithGoogle,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color:
                                                Colors.white.withOpacity(0.35),
                                          ),
                                          backgroundColor:
                                              Colors.white.withOpacity(0.08),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.g_mobiledata,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        label: const Text(
                                          "Sign up with Google",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ Glass Card ------------------
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withOpacity(0.14),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ------------------ Glass TextField ------------------
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _GlassTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.75)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.50)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ------------------ Background Glow Blob ------------------
class _GlowBlob extends StatelessWidget {
  final double size;
  const _GlowBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.30),
            Colors.white.withOpacity(0.00),
          ],
        ),
      ),
    );
  }
}
