import 'package:flutter/material.dart';
import '../../widgets/buttons.dart';
import '../../widgets/seller_widgets.dart';
import '../../models/seller_registration.dart';
import 'seller_experience_screen.dart';

/// Subcategory selection screen for seller registration
class SellerSubcategoryScreen extends StatefulWidget {
  final SellerRegistration registration;

  const SellerSubcategoryScreen({super.key, required this.registration});

  @override
  State<SellerSubcategoryScreen> createState() => _SellerSubcategoryScreenState();
}

class _SellerSubcategoryScreenState extends State<SellerSubcategoryScreen> {
  final List<String> _selectedSubcategories = [];

  final Map<String, List<String>> _subcategories = {
    'Watches': ['Luxury Watches', 'Smart Watches', 'Sport Watches', 'Vintage Watches', 'Watch Accessories'],
    'Jewelry': ['Necklaces', 'Rings', 'Bracelets', 'Earrings', 'Fine Jewelry'],
    'Bags': ['Handbags', 'Backpacks', 'Clutches', 'Tote Bags', 'Luxury Bags'],
    'Shoes': ['Sneakers', 'Boots', 'Heels', 'Sandals', 'Athletic Shoes'],
    'Electronics': ['Phones', 'Laptops', 'Tablets', 'Accessories', 'Gaming'],
    'Fashion': ['Men\'s Clothing', 'Women\'s Clothing', 'Kids Fashion', 'Accessories', 'Vintage'],
    'Collectibles': ['Pokemon Cards', 'Magic The Gathering', 'Yo-Gi-Oh! cards', 'One Piece cards', 'VeeFriends', 'Naruto Cards', 'Union Area', 'Dragon Ball cards', 'Other TCG', 'Riftbound', 'Weiss Schwarz', 'Lorcana'],
    'Home & Garden': ['Furniture', 'Decor', 'Kitchen', 'Garden Tools', 'Lighting'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.registration.subcategories != null) {
      _selectedSubcategories.addAll(widget.registration.subcategories!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.registration.category ?? 'Collectibles';
    final subcategories = _subcategories[category] ?? [];

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Setup Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Which subcategory will you sell in most often?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can always add more later.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Trading cards $category',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Subcategory Chips
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: subcategories.map((subcategory) {
                    final isSelected = _selectedSubcategories.contains(subcategory);
                    return SubcategoryChip(
                      name: subcategory,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSubcategories.remove(subcategory);
                          } else {
                            _selectedSubcategories.add(subcategory);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'Next',
                onPressed: _selectedSubcategories.isEmpty
                    ? null
                    : () {
                        widget.registration.subcategories = _selectedSubcategories;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SellerExperienceScreen(
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
}
