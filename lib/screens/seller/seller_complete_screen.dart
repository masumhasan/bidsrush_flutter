import 'package:flutter/material.dart';
import '../../widgets/buttons.dart';
import '../../models/seller_registration.dart';

/// Completion screen for seller registration
class SellerCompleteScreen extends StatelessWidget {
  final SellerRegistration registration;

  const SellerCompleteScreen({super.key, required this.registration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[50],
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 70,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              // Title
              const Text(
                'Completed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              const Text(
                'Thank you very much for signing up as a seller, you can now sell on BidsRush!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              // Done button
              PrimaryButton(
                text: 'Done',
                onPressed: () {
                  // TODO: Submit registration data to backend
                  // TODO: Update user role to 'seller'
                  // For now, just navigate back to root
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
