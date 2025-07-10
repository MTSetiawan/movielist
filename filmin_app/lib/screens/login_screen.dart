import 'package:flutter/material.dart';
import 'package:filmin_app/service/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _submit() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    try {
      final response = isLogin
          ? await ApiService.login(email, password)
          : await ApiService.register(name, email, password);

      if (!mounted) return;

      if (response.containsKey('token')) {
        await ApiService.saveToken(response['token']);

        if (!isLogin) {
          // Kalau mode register, beri notifikasi dan pindah ke login
          setState(() {
            isLogin = true; // kembali ke form login
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registration successful! Please login.'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        } else {
          // Kalau login berhasil
          Navigator.pushReplacementNamed(context, '/movies');
        }
      } else {
        _showError('Login/Register failed');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade900,
                  Colors.black87,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.shade700,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade700.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo/Title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'FilmIn',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade600, Colors.red.shade900],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Tabs Login / Register
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade800),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTab('Login', true),
                      _buildTab('Register', false),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Name field (only for register)
                if (!isLogin) ...[
                  _buildTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                ],

                // Email
                _buildTextField(
                  controller: emailController,
                  hintText: 'Email',
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),

                // Password
                _buildTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // Submit button
                isLoading
                    ? CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.red.shade600),
                      )
                    : Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade600, Colors.red.shade800],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade600.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submit,
                          child: Text(
                            isLogin ? 'LOGIN' : 'REGISTER',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool loginTab) {
    final selected = isLogin == loginTab;
    return GestureDetector(
      onTap: () => setState(() => isLogin = loginTab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.red.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade800.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade900,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.red.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade600, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
