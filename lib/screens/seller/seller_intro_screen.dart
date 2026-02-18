import 'package:flutter/material.dart';
import '../../widgets/buttons.dart';
import '../../widgets/seller_widgets.dart';
import 'seller_faq_screen.dart';

/// "Ready to Earn?" intro screen for seller registration
class SellerIntroScreen extends StatelessWidget {
  const SellerIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Title
              const Text(
                'Ready to Earn?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Benefits
              const InfoCard(
                icon: Icons.verified_outlined,
                text: 'Pay one of the lowest fees around',
              ),
              const SizedBox(height: 12),
              const InfoCard(
                icon: Icons.verified_outlined,
                text: 'Buyers cover shipping costs',
              ),
              const SizedBox(height: 12),
              const InfoCard(
                icon: Icons.verified_outlined,
                text: 'Honor purchases and giveaways',
              ),
              const Spacer(),
              // Continue button
              PrimaryButton(
                text: 'Got It!',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SellerFaqScreen(),
                    ),
                  );
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
