import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proj1/pages/forgot_password.dart';
import 'package:provider/provider.dart';

import '../firebase/auth_service.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool showLogin = true;
  bool isChecked = false;
  bool _loading = false;
  String? _error;

  // Login controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Registration controllers
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerUsernameController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to track auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔹 Handle Login
  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final user = await authService.signInWithEmailAndPassword(
        _loginEmailController.text.trim(),
        _loginPasswordController.text.trim(),
      );

      setState(() => _loading = false);

      if (user == null) {
        setState(() => _error = "Login failed. Please check your credentials.");
      } else {
        // ✅ Navigate to home if successful
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "An error occurred: ${e.toString()}";
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    // ✅ Validate password match
    if (_registerPasswordController.text.trim() !=
        _registerConfirmPasswordController.text.trim()) {
      setState(() {
        _loading = false;
        _error = "Passwords do not match.";
      });
      return;
    }

    try {
      final user = await authService.registerWithEmailAndPassword(
        _registerEmailController.text.trim(),
        _registerPasswordController.text.trim(),
        _registerUsernameController.text.trim(),
      );

      if (user == null) {
        setState(() {
          _loading = false;
          _error = "Registration failed. Please try again.";
        });
        return;
      }

      // ✅ Stop loading first
      setState(() => _loading = false);

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful! Please log in."),
        ),
      );

      // ✅ Go back to login screen
      setState(() => showLogin = true);
    } catch (e) {
      // ✅ Always stop loader and show error
      setState(() {
        _loading = false;
        _error = "Error: ${e.toString()}";
      });
      debugPrint("Register error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: -5,
            right: 0,
            child: Center(
              child: Image.asset("assets/images/logo.png", height: 250),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 530,
              width: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 350,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(232, 229, 229, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => showLogin = true),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: showLogin
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "LOG IN",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: showLogin
                                      ? const Color.fromRGBO(15, 29, 56, 1)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => showLogin = false),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: !showLogin
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "SIGN UP",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: !showLogin
                                      ? const Color.fromRGBO(15, 29, 56, 1)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  showLogin ? _buildLoginUI() : _buildRegistrationUI(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
      child: Column(
        children: [
          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              "Email or Username",
              Icons.mail_outline,
            ),
            style: _inputTextStyle(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _loginPasswordController,
            obscureText: true,
            obscuringCharacter: "●",
            decoration: _inputDecoration("Password", Icons.lock_outline),
            style: _inputTextStyle(),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) => setState(() => isChecked = value!),
                  ),
                  const Text(
                    "Remember Me",
                    style: TextStyle(color: Color.fromRGBO(15, 29, 56, 0.5)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPassword()),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Color.fromRGBO(15, 29, 56, 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _loading
              ? const CircularProgressIndicator()
              : _actionButton("LOG IN", _handleLogin),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          _dividerWithLabel("OTHER"),
          const SizedBox(height: 10),
          _socialIcons(),
        ],
      ),
    );
  }

  Widget _buildRegistrationUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
      child: Column(
        children: [
          TextField(
            controller: _registerEmailController,
            decoration: _inputDecoration("Enter email", Icons.mail_outline),
            style: _inputTextStyle(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _registerUsernameController,
            decoration: _inputDecoration(
              "Enter username",
              Icons.person_2_outlined,
            ),
            style: _inputTextStyle(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _registerPasswordController,
            obscureText: true,
            obscuringCharacter: "●",
            decoration: _inputDecoration("New password", Icons.lock_outline),
            style: _inputTextStyle(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _registerConfirmPasswordController,
            obscureText: true,
            obscuringCharacter: "●",
            decoration: _inputDecoration(
              "Confirm password",
              Icons.lock_outline,
            ),
            style: _inputTextStyle(),
          ),
          Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (value) => setState(() => isChecked = value!),
              ),
              const Text(
                "Remember Me",
                style: TextStyle(color: Color.fromRGBO(15, 29, 56, 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          _loading
              ? const CircularProgressIndicator()
              : _actionButton("SIGN UP", _register),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 5),
          _dividerWithLabel("OTHER"),
          const SizedBox(height: 5),
          _socialIcons(),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color.fromRGBO(15, 29, 56, 1)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromRGBO(15, 29, 56, 0.5),
          width: 1.5,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromRGBO(15, 29, 56, 1),
          width: 2.0,
        ),
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color.fromRGBO(15, 29, 56, 0.5),
        fontSize: 16,
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return GoogleFonts.montserrat(
      fontSize: 16,
      color: const Color.fromRGBO(15, 29, 56, 1),
      fontWeight: FontWeight.w500,
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
        padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      child: Text(
        label,
        style: GoogleFonts.jua(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dividerWithLabel(String label) {
    return Column(
      children: [
        Divider(
          color: const Color.fromRGBO(15, 29, 56, 0.5),
          thickness: 2,
          indent: 70,
          endIndent: 70,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color.fromRGBO(15, 29, 56, 0.5),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _socialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset('assets/images/ggl.png', width: 50, height: 50),
        Image.asset('assets/images/fb.png', width: 40, height: 40),
        Image.asset('assets/images/x.png', width: 40, height: 40),
      ],
    );
  }
}
