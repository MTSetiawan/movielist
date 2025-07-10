import 'package:flutter/material.dart';
import 'package:filmin_app/models/user.dart';
import 'package:filmin_app/service/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserModel> _futureUser;
  bool _isNotificationOn = true;

  @override
  void initState() {
    super.initState();
    _futureUser = ApiService.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Darker black background
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<UserModel>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD32F2F), // Red loading indicator
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'User not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final user = snapshot.data!;
          final initials = user.name.isNotEmpty
              ? user.name.trim().split(' ').map((e) => e[0]).take(2).join()
              : '?';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD32F2F), // Red gradient
                        const Color(0xFFB71C1C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // General Section
                _buildSectionTitle("General"),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  title: "Notifications",
                  subtitle: "Get updates about new movies",
                  value: _isNotificationOn,
                  onChanged: (val) {
                    setState(() {
                      _isNotificationOn = val;
                    });
                  },
                ),
                _buildTile("Dark Mode", "Always On", Icons.dark_mode),
                _buildTile("Video Quality", "Auto", Icons.hd),
                _buildTile("Download Quality", "High", Icons.download),
                _buildTile("Language", "English", Icons.language),

                const SizedBox(height: 28),

                // Account Section
                _buildSectionTitle("Account"),
                const SizedBox(height: 12),
                _buildTile("Subscription", "Premium", Icons.star,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "PRO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                _buildTile("Payment Method", "•••• 1234", Icons.credit_card),
                _buildTile("Privacy Settings", "", Icons.privacy_tip),
                _buildTile("Invite Friends", "", Icons.share),

                const SizedBox(height: 28),

                // Support Section
                _buildSectionTitle("Support & Legal"),
                const SizedBox(height: 12),
                _buildTile("Help Center", "", Icons.help_outline),
                _buildTile("Terms of Service", "", Icons.description),
                _buildTile("Privacy Policy", "", Icons.security),
                _buildTile("Contact Us", "", Icons.contact_support),
                _buildTile("Report Issue", "", Icons.report_problem),

                const SizedBox(height: 32),

                // Logout Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side:
                          const BorderSide(color: Color(0xFFD32F2F), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFFD32F2F), // Red section titles
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(String title, String subtitle, IconData icon,
      {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark gray tiles
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFD32F2F),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
        onTap: () {
          // Handle tile tap
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.notifications,
            color: Color(0xFFD32F2F),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFD32F2F), // Red switch
        inactiveThumbColor: Colors.grey.shade600,
        inactiveTrackColor: Colors.grey.shade800,
      ),
    );
  }
}
