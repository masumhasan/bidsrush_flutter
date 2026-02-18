import 'package:flutter/material.dart';
import '../../widgets/buttons.dart';
import '../../widgets/seller_widgets.dart';
import 'seller_category_screen.dart';

/// FAQ screen for seller registration
class SellerFaqScreen extends StatelessWidget {
  const SellerFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
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
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // FAQ List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: const [
                    FaqAccordion(
                      question: 'How do I unlock my seller access?',
                      answer: 'Complete the registration process by providing your business details, preferred categories, and shipping information. Once verified, you\'ll have full seller access.',
                    ),
                    FaqAccordion(
                      question: 'Can I have a second selling account?',
                      answer: 'Each user is limited to one seller account. This helps maintain trust and accountability within our marketplace.',
                    ),
                    FaqAccordion(
                      question: 'When can I schedule a show?',
                      answer: 'Once your seller account is approved, you can schedule live shows at any time. We recommend planning at least 24 hours in advance for better viewership.',
                    ),
                    FaqAccordion(
                      question: 'How and when do I get paid?',
                      answer: 'Payments are processed within 3-5 business days after successful delivery. Funds are transferred directly to your registered bank account or payment method.',
                    ),
                    FaqAccordion(
                      question: 'Do I need to show my face on camera?',
                      answer: 'While showing your face can help build trust with buyers, it\'s not mandatory. Many successful sellers showcase products without appearing on camera.',
                    ),
                    FaqAccordion(
                      question: 'Can I sell if I\'m under 18?',
                      answer: 'Sellers must be at least 18 years old to comply with legal requirements and payment processing regulations.',
                    ),
                    FaqAccordion(
                      question: 'How does shipping work?',
                      answer: 'Buyers cover shipping costs. You\'ll receive shipping labels automatically once an order is confirmed. Simply pack and ship within the specified timeframe.',
                    ),
                    FaqAccordion(
                      question: 'What are the fees?',
                      answer: 'We charge one of the lowest fees in the industry - typically 5-10% per sale depending on your seller tier and category. No hidden charges.',
                    ),
                    FaqAccordion(
                      question: 'What can I sell?',
                      answer: 'You can sell most new and used items including electronics, fashion, collectibles, and more. Prohibited items include weapons, illegal goods, and counterfeit products.',
                    ),
                  ],
                ),
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'Proceed',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SellerCategoryScreen(),
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
}
