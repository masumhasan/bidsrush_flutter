import 'package:flutter/material.dart';
import '../../widgets/buttons.dart';
import '../../models/seller_registration.dart';
import 'seller_address_screen.dart';

/// Experience level selection screen
class SellerExperienceScreen extends StatefulWidget {
  final SellerRegistration registration;

  const SellerExperienceScreen({super.key, required this.registration});

  @override
  State<SellerExperienceScreen> createState() => _SellerExperienceScreenState();
}

class _SellerExperienceScreenState extends State<SellerExperienceScreen> {
  String? _selectedExperience;

  @override
  void initState() {
    super.initState();
    _selectedExperience = widget.registration.experienceLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setup Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Which of these better describes you?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'We\'ll tailor your experience based on what you pick',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Experience options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildExperienceOption(
                    'I\'m just starting',
                    'just_starting',
                  ),
                  const SizedBox(height: 16),
                  _buildExperienceOption(
                    'I\'m actively selling online or in person',
                    'actively_selling',
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'Next',
                onPressed: _selectedExperience == null
                    ? null
                    : () {
                        widget.registration.experienceLevel = _selectedExperience;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SellerAddressScreen(
                              registration: widget.registration,
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceOption(String text, String value) {
    final isSelected = _selectedExperience == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedExperience = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF9800) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 14,
                        color: Color(0xFFFF9800),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
