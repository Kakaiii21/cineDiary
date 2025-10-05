import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  File? savedCoverImage;
  File? savedProfileImage;
  File? tempCoverImage;
  File? tempProfileImage;
  final ImagePicker _picker = ImagePicker();
  late Box profileBox;

  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    profileBox = Hive.box('profileBox');
    _loadSavedImages();
    _loadUserData();
  }

  void _loadSavedImages() {
    final coverPath = profileBox.get('coverImage');
    final profilePath = profileBox.get('profileImage');
    setState(() {
      if (coverPath != null) savedCoverImage = File(coverPath);
      if (profilePath != null) savedProfileImage = File(profilePath);
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          username = doc['username'];
          email = doc['email'];
        });
      }
    }
  }

  Future<void> _pickCoverImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => tempCoverImage = File(picked.path));
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => tempProfileImage = File(picked.path));
  }

  Future<void> _saveImages() async {
    if (tempCoverImage != null) {
      savedCoverImage = tempCoverImage;
      profileBox.put('coverImage', savedCoverImage!.path);
    }
    if (tempProfileImage != null) {
      savedProfileImage = tempProfileImage;
      profileBox.put('profileImage', savedProfileImage!.path);
    }
    tempCoverImage = null;
    tempProfileImage = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 56, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover + Profile Section
            SizedBox(
              height: 180,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: isEditing ? _pickCoverImage : null,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(15, 29, 56, 1),
                        ),
                        image: DecorationImage(
                          image:
                              (isEditing ? tempCoverImage : savedCoverImage) !=
                                  null
                              ? FileImage(
                                  isEditing
                                      ? tempCoverImage!
                                      : savedCoverImage!,
                                )
                              : const AssetImage("assets/images/cover.png")
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: isEditing
                          ? Container(
                              color: Colors.black38,
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    child: GestureDetector(
                      onTap: isEditing ? _pickProfileImage : null,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromRGBO(15, 29, 56, 1),
                            width: 7,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage:
                              (isEditing
                                      ? tempProfileImage
                                      : savedProfileImage) !=
                                  null
                              ? FileImage(
                                  isEditing
                                      ? tempProfileImage!
                                      : savedProfileImage!,
                                )
                              : const AssetImage("assets/profile.jpg")
                                    as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 70),

            // Username
            Center(
              child: Text(
                username ?? 'Loading...',
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
                email ?? 'Loading...',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
            ),

            const SizedBox(height: 15),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isEditing) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tempCoverImage = savedCoverImage;
                        tempProfileImage = savedProfileImage;
                        isEditing = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(109, 133, 159, 1),
                      minimumSize: const Size(110, 28),
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted)
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/', (_) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(43, 82, 158, 1),
                      minimumSize: const Size(110, 28),
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tempCoverImage = null;
                        tempProfileImage = null;
                        isEditing = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(109, 133, 159, 1),
                      minimumSize: const Size(110, 28),
                    ),
                    child: const Text(
                      "Discard",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveImages();
                      setState(() => isEditing = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(43, 82, 158, 1),
                      minimumSize: const Size(110, 28),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.black, thickness: 1.5),
            const SizedBox(height: 10),

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
