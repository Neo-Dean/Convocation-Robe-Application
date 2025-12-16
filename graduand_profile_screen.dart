import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraduandProfileScreen extends StatefulWidget {
  const GraduandProfileScreen({super.key});

  @override
  _GraduandProfileScreenState createState() => _GraduandProfileScreenState();
}

class _GraduandProfileScreenState extends State<GraduandProfileScreen> {
  String username = '';
  String password = '';
  String phone_number = ''; // Assuming you have a phone field
  String token = '';
  /*String matric number = '';*/
  bool isPasswordVisible = false;
  int userId = 0;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Map<String, dynamic>? latestBooking; // To store latest booking details
  bool isLoading = true; // To handle loading state

  @override
  void initState() {
    super.initState();
    _loadTokenAndUserId();
  }

  Future<void> _loadTokenAndUserId() async {
    final storedToken = await secureStorage.read(key: 'token');
    final storedUserId = await secureStorage.read(key: 'userId');
    if (storedToken != null && storedUserId != null) {
      setState(() {
        token = storedToken;
        userId = int.parse(storedUserId);
      });
      await _fetchUserDetails(); // Fetch user details
      await _fetchLatestBooking();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Token or user ID not found. Please log in again.')),
      );
      Navigator.pushNamed(context, 'graduandLogin');
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.99.15:6000/api/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'];
          password =
              data['password']; // Assuming this is how password is fetched
          phone_number =
              data['phone_number']; // Assuming phone number is returned
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch user details.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    if (username.isEmpty || password.isEmpty || phone_number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://192.168.99.15:6000/api/update-user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'username': username,
          'password': password,
          'phone_number': phone_number
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
      } else {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseBody['message'] ?? 'Error updating profile.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  // Function to fetch the latest booking from the server
  Future<void> _fetchLatestBooking() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.99.15:6000/api/latest-booking/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          latestBooking = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print(
            'Failed to fetch latest booking. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching latest booking: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true, // Centers the title
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, 'notificationScreen');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xffD9D9D9),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Username/Email
            TextField(
              controller: TextEditingController(text: username),
              decoration: const InputDecoration(
                labelText: 'Username/Email',
                prefixIcon: Icon(Icons.person_outline),
                filled: true,
                fillColor: Color(0xffD9D9D9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (value) => username = value,
            ),
            const SizedBox(height: 20),
            // Password
            TextField(
              controller: TextEditingController(text: ''),
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: Color(0xffD9D9D9),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              onChanged: (value) => password = value,
            ),
            const SizedBox(height: 20),
            // Phone Number
            TextField(
              controller: TextEditingController(text: phone_number),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                filled: true,
                fillColor: Color(0xffD9D9D9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (value) => phone_number = value,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4C4DDC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (token.isNotEmpty && userId > 0) {
                        updateProfile(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Token or User ID not found.')),
                        );
                        Navigator.pushNamed(context, 'graduandLogin');
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white), // White text color
                    ),
                  ),
                ),
                const SizedBox(width: 150),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'graduandLogin');
                    },
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white), // White text color
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Latest Booking Section
            const Text(
              'Latest Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // Loading spinner
                  )
                : latestBooking != null
                    ? Row(
                        children: [
                          // Display the image for the booking
                          Image.asset(
                            latestBooking!['image_url'] ?? '',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Display the booking details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Type: ${latestBooking!['robe_type'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Robe ID: ${latestBooking!['robe_id'] ?? 'N/A'}',
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Size: ${latestBooking!['size'] ?? 'N/A'}',
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Collection Date: ${latestBooking!['booking_date'] ?? 'N/A'}',
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Status: ${latestBooking!['booking_status'] ?? 'N/A'}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const Text('No latest booking found.'),
          ],
        ),
      ),
    );
  }
}
