import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

/// Screen for changing user email
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _newEmailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  Future<void> _changeEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final result = await apiService.changeEmail(
        password: _passwordController.text,
        newEmail: _newEmailController.text,
      );

      if (mounted) {
        // Update auth provider with new token and user data
        final authProvider = context.read<AuthProvider>();
        await authProvider.updateUserAfterEmailChange(
          result['user'],
          result['token'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentEmail = auth.user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Change Email',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Enter your password and choose a new email address.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Current Email (Display only)
                _buildInfoField(
                  label: 'Current Email',
                  value: currentEmail,
                ),
                const SizedBox(height: 20),
                
                // Password
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF999999),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // New Email
                _buildTextField(
                  controller: _newEmailController,
                  label: 'New Email',
                  hint: 'Enter your new email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new email';
                    }
                    // Email validation
                    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    if (value.toLowerCase() == currentEmail.toLowerCase()) {
                      return 'New email must be different from current email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Confirm Email
                _buildTextField(
                  controller: _confirmEmailController,
                  label: 'Confirm New Email',
                  hint: 'Re-enter your new email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new email';
                    }
                    if (value != _newEmailController.text) {
                      return 'Emails do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Change Email Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changeEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005FFF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCCCCCC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Change Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

  Widget _buildInfoField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1a1a1a),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFFAAAAAA),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF005FFF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
