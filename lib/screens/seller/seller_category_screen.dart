import 'package:flutter/material.dart';
import '../../widgets/buttons.dart';
import '../../widgets/seller_widgets.dart';
import '../../models/seller_registration.dart';
import 'seller_subcategory_screen.dart';

/// Category selection screen for seller registration
class SellerCategoryScreen extends StatefulWidget {
  final SellerRegistration? registration;

  const SellerCategoryScreen({super.key, this.registration});

  @override
  State<SellerCategoryScreen> createState() => _SellerCategoryScreenState();
}

class _SellerCategoryScreenState extends State<SellerCategoryScreen> {
  late SellerRegistration _registration;
  String? _selectedCategory;

  final List<Map<String, String>> _categories = [
    {
      'name': 'Watches',
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200',
    },
    {
      'name': 'Jewelry',
      'image': 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=200',
    },
    {
      'name': 'Bags',
      'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=200',
    },
    {
      'name': 'Shoes',
      'image': 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=200',
    },
    {
      'name': 'Electronics',
      'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=200',
    },
    {
      'name': 'Fashion',
      'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=200',
    },
    {
      'name': 'Collectibles',
      'image': 'https://images.unsplash.com/photo-1604762524548-ed58d3d6a68e?w=200',
    },
    {
      'name': 'Home & Garden',
      'image': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _registration = widget.registration ?? SellerRegistration();
    _selectedCategory = _registration.category;
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
                    'Which category will you sell in most often?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pick 4 to get Started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Category Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return CategoryCard(
                    name: category['name']!,
                    imageUrl: category['image']!,
                    isSelected: _selectedCategory == category['name'],
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                    },
                  );
                },
              ),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'Next',
                onPressed: _selectedCategory == null
                    ? null
                    : () {
                        _registration.category = _selectedCategory;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SellerSubcategoryScreen(
                              registration: _registration,
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
