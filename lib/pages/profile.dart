import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ensure left alignment
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundImage: const AssetImage("assets/profile.jpg"),
              ),
            ),
            const SizedBox(height: 15),

            // Username
            Center(
              child: Text(
                "yOnesa",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Email
            Center(
              child: Text(
                "yonesa001@gmail.com",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(height: 15),

            // Edit / Save - Discard Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isEditing) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() => isEditing = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Edit"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      // log out function
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () {
                      setState(() => isEditing = false);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                    ),
                    child: const Text(
                      "Discard",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => isEditing = false);
                      // save function
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            const Divider(color: Colors.black, thickness: 1.5),
            const Divider(color: Colors.white24, thickness: 0.5),

            // Account Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Account Settings',
                style: const TextStyle(
                  color: Color.fromRGBO(60, 78, 111, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            _buildSettingsItem(Icons.person, "Personal Information"),
            _buildSettingsItem(Icons.lock, "Password & Security"),
            _buildSettingsItem(Icons.notifications, "Notification Preferences"),
            _buildSettingsItem(Icons.palette, "Theme"),
            _buildSettingsItem(Icons.delete_outline, "Clear Cache"),
            _buildSettingsItem(Icons.help_outline, "FAQ"),
            _buildSettingsItem(Icons.support_agent, "Contact Support"),
            _buildSettingsItem(Icons.article_outlined, "Terms & Conditions"),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

Widget _buildSettingsItem(IconData icon, String title) {
  return ListTile(
    leading: Icon(icon, color: Colors.white70),
    title: Text(
      title,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    onTap: () {
      // Handle navigation
    },
  );
}
