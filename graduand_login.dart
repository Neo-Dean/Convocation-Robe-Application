import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraduandLogin extends StatefulWidget {
  const GraduandLogin({super.key});

  @override
  State<GraduandLogin> createState() => _GraduandLoginState();
}

class _GraduandLoginState extends State<GraduandLogin> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool rememberMe = false; // State for Remember Me checkbox
  bool isLoading = false;

  Future<void> login() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Make the API request
      final response = await http.post(
        Uri.parse('http://192.168.99.15:6000/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': identifier, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save token and role securely
        await secureStorage.write(key: 'token', value: responseData['token']);
        await secureStorage.write(key: 'role', value: responseData['role']);
        await secureStorage.write(
            key: 'userId', value: responseData['userId'].toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        // Navigate to the appropriate screen based on role
        if (responseData['role'] == 'admin') {
          Navigator.pushNamed(context, 'adminMain');
        } else if (responseData['role'] == 'user') {
          Navigator.pushNamed(context, 'graduandMainScreen');
        }
      } else {
        final error = json.decode(response.body)['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'adminLogin');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4C4DDC),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Staff/Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Convocation Robe Application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildInputField(
                label: 'Username/Email',
                /* label: 'Enter Username or Email' */
                controller: identifierController,
                isObscure: false,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Password',
                controller: passwordController,
                isObscure: true,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            rememberMe = !rememberMe;
                          });
                        },
                        child: const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Add Forgot Password functionality here
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF4C4DDC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4C4DDC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'graduandRegistration');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Color(0xFF4C4DDC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: 'Type here....',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }
}
