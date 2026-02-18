import 'package:flutter/material.dart';
import '../../widgets/buttons.dart';
import '../../models/seller_registration.dart';
import 'seller_complete_screen.dart';

/// Monthly income selection screen for seller registration
class SellerIncomeScreen extends StatefulWidget {
  final SellerRegistration registration;

  const SellerIncomeScreen({super.key, required this.registration});

  @override
  State<SellerIncomeScreen> createState() => _SellerIncomeScreenState();
}

class _SellerIncomeScreenState extends State<SellerIncomeScreen> {
  String? _selectedIncome;

  final List<Map<String, String>> _incomeRanges = [
    {'value': 'less_than_1000', 'label': 'Less than £1,000'},
    {'value': '1000_5000', 'label': '£1,000 - £5,000'},
    {'value': '5000_20000', 'label': '£5,000 - £20,000'},
    {'value': '20000_50000', 'label': '£20,000 - £50,000'},
    {'value': 'more_than_50000', 'label': 'More than £50,000'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIncome = widget.registration.monthlyIncome;
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
                    'What is your estimated monthly income?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This information will help us better serve you.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Income options
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _incomeRanges.length,
                itemBuilder: (context, index) {
                  final income = _incomeRanges[index];
                  final isSelected = _selectedIncome == income['value'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildIncomeOption(
                      label: income['label']!,
                      value: income['value']!,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'Complete',
                onPressed: _selectedIncome == null
                    ? null
                    : () {
                        widget.registration.monthlyIncome = _selectedIncome;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SellerCompleteScreen(
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

  Widget _buildIncomeOption({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIncome = value;
        });
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF9800) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
