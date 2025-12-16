import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GraduandRegistration extends StatefulWidget {
  const GraduandRegistration({super.key});

  @override
  State<GraduandRegistration> createState() => _GraduandRegistrationState();
}

class _GraduandRegistrationState extends State<GraduandRegistration> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  bool agreeToTerms = false;
  bool isLoading = false;

  Future<void> register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@siswa\.unimas\.my").hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Email must be a @siswa.unimas.my address')),
        /*content: Text ('Email must be a matric number@siswa.unimas.my email address') */
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms of service')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Make API call to the backend
      final response = await http.post(
        Uri.parse(
            'http://192.168.99.15:6000/register'), // Update the IP and port
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'role': 'user',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to the login screen
        Navigator.pushNamed(context, 'graduandLogin');
      } else {
        final error =
            json.decode(response.body)['message'] ?? 'Registration failed';
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
                label: 'Username',
                controller: usernameController,
                isObscure: false,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Email',
                controller: emailController,
                isObscure: false,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Password',
                controller: passwordController,
                isObscure: true,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Confirm Password',
                controller: confirmPasswordController,
                isObscure: true,
              ),
              const SizedBox(height: 20), // Space before the phone number field
              _buildInputField(
                label: 'Phone Number',
                controller: phoneNumberController,
                isObscure: false,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the terms of service',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : const Text(
                          'Register',
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
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'graduandLogin');
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Colors.blue,
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
          keyboardType: label == 'Phone Number'
              ? TextInputType.phone
              : (label == 'Email'
                  ? TextInputType.emailAddress
                  : TextInputType.text),
          decoration: InputDecoration(
            prefixIcon: label == 'Phone Number'
                ? const Icon(Icons.phone)
                : (label == 'Email'
                    ? const Icon(Icons.email)
                    : (isObscure
                        ? const Icon(Icons.lock)
                        : const Icon(Icons.person))),
            hintText: 'Type here...',
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
