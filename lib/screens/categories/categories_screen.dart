import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _buildCategoryItem(
            context,
            'Watches',
            Icons.watch,
            Colors.purple,
          ),
          _buildCategoryItem(
            context,
            'Jewelry',
            Icons.diamond,
            Colors.pink,
          ),
          _buildCategoryItem(
            context,
            'Fashion',
            Icons.checkroom,
            Colors.green,
          ),
          _buildCategoryItem(
            context,
            'Handbags',
            Icons.shopping_bag,
            Colors.orange,
          ),
          _buildCategoryItem(
            context,
            'Sneakers',
            Icons.hiking,
            Colors.red,
          ),
          _buildCategoryItem(
            context,
            'Electronics',
            Icons.devices,
            Colors.blue,
          ),
          _buildCategoryItem(
            context,
            'Home',
            Icons.home,
            Colors.brown,
          ),
          _buildCategoryItem(
            context,
            'Art',
            Icons.palette,
            Colors.deepPurple,
          ),
          _buildCategoryItem(
            context,
            'Collectibles',
            Icons.collections,
            Colors.teal,
          ),
          _buildCategoryItem(
            context,
            'Toys',
            Icons.toys,
            Colors.indigo,
          ),
          _buildCategoryItem(
            context,
            'Beauty',
            Icons.face,
            Colors.pinkAccent,
          ),
          _buildCategoryItem(
            context,
            'Sports',
            Icons.sports_basketball,
            Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        // Navigate to category details or search
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
