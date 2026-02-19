import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Create Product Screen - Product listing creation
class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _costPerItemController = TextEditingController(text: '\$3.00');
  final _skuController = TextEditingController();

  int _quantityAvailable = 1;
  bool _hazardousMaterials = false;
  bool _everyoneCanEnter = true;
  bool _followersOnly = false;
  bool _buyerAppreciation = true;
  bool _internationalShipping = true;

  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _costPerItemController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Quality Listing'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMediaSection(),
                    const SizedBox(height: 24),
                    _buildProductDetailsSection(),
                    const SizedBox(height: 24),
                    _buildPricingSection(),
                    const SizedBox(height: 24),
                    _buildHazardousMaterialsSection(),
                    const SizedBox(height: 24),
                    _buildWhoCanEnterSection(),
                    const SizedBox(height: 24),
                    _buildOptionalFieldsSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            // TODO: Implement photo picker
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Color(0xFF00BCD4),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add Photos',
                    style: TextStyle(
                      color: Color(0xFF00BCD4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Category
        _buildDropdownField(
          icon: Icons.category_outlined,
          label: 'Category',
          value: _selectedCategory,
          onChanged: (value) {
            setState(() => _selectedCategory = value);
          },
        ),
        const SizedBox(height: 12),
        // Title
        _buildTextField(
          controller: _titleController,
          label: 'Title',
          hint: 'Title',
        ),
        const SizedBox(height: 12),
        // Description
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Description',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        // Quantity Available
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quality Available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_quantityAvailable > 1) {
                      setState(() => _quantityAvailable--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: const Color(0xFF00BCD4),
                ),
                Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$_quantityAvailable',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _quantityAvailable++);
                  },
                  icon: const Icon(Icons.add_circle),
                  color: const Color(0xFF00BCD4),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Variants
        _buildNavigationTile(
          icon: Icons.style_outlined,
          label: 'Variants',
          onTap: () {
            // TODO: Navigate to variants screen
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _quantityController,
          label: 'Quantity',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildNavigationTile(
          icon: Icons.local_shipping_outlined,
          label: 'Shipping Profile',
          onTap: () {
            // TODO: Navigate to shipping profile
          },
        ),
      ],
    );
  }

  Widget _buildHazardousMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hazardous Materials',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: _hazardousMaterials,
          onChanged: (value) {
            setState(() => _hazardousMaterials = value);
          },
          title: const Text('Contains hazardous materials'),
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF00BCD4),
        ),
      ],
    );
  }

  Widget _buildWhoCanEnterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who can enter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildToggleOption('Everyone', _everyoneCanEnter, (value) {
          setState(() => _everyoneCanEnter = value);
        }),
        _buildToggleOption('Followers Only', _followersOnly, (value) {
          setState(() => _followersOnly = value);
        }),
        _buildToggleOption('Buyer Appreciation', _buyerAppreciation, (value) {
          setState(() => _buyerAppreciation = value);
        }),
        _buildToggleOption('International Shipping', _internationalShipping, (value) {
          setState(() => _internationalShipping = value);
        }),
      ],
    );
  }

  Widget _buildOptionalFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Optional Fields',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _costPerItemController,
          label: 'Cost per item',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _skuController,
          label: 'SKU',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Show category picker
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00BCD4)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  fontSize: 16,
                  color: value == null ? Colors.grey[600] : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00BCD4)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00BCD4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Save draft
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Draft saved')),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF00BCD4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Draft',
                style: TextStyle(
                  color: Color(0xFF00BCD4),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Publish product
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product published')),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Publish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
