import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../stream/start_stream_screen.dart';

/// New Show Screen - Schedule/Start a live show
class NewShowScreen extends StatefulWidget {
  const NewShowScreen({super.key});

  @override
  State<NewShowScreen> createState() => _NewShowScreenState();
}

class _NewShowScreenState extends State<NewShowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _showNameController = TextEditingController();
  final _moderatorsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  String _repeatOption = 'Does not repeat';
  String _sellingFormat = 'Format';
  String _primaryBrand = 'Brand';
  String _primaryLanguage = 'English';
  String _discoverability = 'Public';
  
  bool _freePickup = true;
  bool _explicitContent = false;
  bool _promoteShow = false;

  final List<String> _selectedCategories = ['Streetwear', 'Everything Else', 'Makeup'];
  final List<String> _selectedTags = ['Resale', "Women's", 'Makeup'];
  final List<String> _mutedWords = ['Fake', 'Replica'];

  @override
  void dispose() {
    _showNameController.dispose();
    _moderatorsController.dispose();
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
        title: const Text('Start a Live Show'),
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
                    _buildShowNameSection(),
                    const SizedBox(height: 16),
                    _buildModeratorsSection(),
                    const SizedBox(height: 16),
                    _buildRepeatsSection(),
                    const SizedBox(height: 24),
                    _buildMediaSection(),
                    const SizedBox(height: 24),
                    _buildPrimaryCategorySection(),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    _buildSellingFormatDropdown(),
                    const SizedBox(height: 24),
                    _buildPrimaryTagsSection(),
                    const SizedBox(height: 16),
                    _buildTagsDropdown(),
                    const SizedBox(height: 16),
                    _buildBrandDropdown(),
                    const SizedBox(height: 24),
                    _buildShippingSettings(),
                    const SizedBox(height: 24),
                    _buildContentSettings(),
                    const SizedBox(height: 16),
                    _buildMutedWordsSection(),
                    const SizedBox(height: 16),
                    _buildLanguageDropdown(),
                    const SizedBox(height: 24),
                    _buildDiscoverabilitySection(),
                    const SizedBox(height: 24),
                    _buildPromoteShowSection(),
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

  Widget _buildShowNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name Your Show',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _showNameController,
          decoration: InputDecoration(
            hintText: 'Name Your Show',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('dd MMMM, yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeratorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Moderators',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _moderatorsController,
          decoration: InputDecoration(
            hintText: 'Excellent',
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeats',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          value: _repeatOption,
          items: ['Does not repeat', 'Daily', 'Weekly', 'Monthly'],
          onChanged: (value) {
            setState(() => _repeatOption = value!);
          },
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMediaButton(
                icon: Icons.image_outlined,
                label: 'Add a Thumbnail',
                onTap: () {
                  // TODO: Pick thumbnail
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMediaButton(
                icon: Icons.videocam_outlined,
                label: 'Add a Video',
                onTap: () {
                  // TODO: Pick video
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF00BCD4)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF00BCD4),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Optional',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedCategories.map((category) {
            return Chip(
              label: Text(category),
              backgroundColor: const Color(0xFF00BCD4),
              labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdownField(
      value: 'Category',
      items: ['Category', 'Fashion', 'Electronics', 'Home & Garden', 'Sports'],
      onChanged: (value) {},
    );
  }

  Widget _buildSellingFormatDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Selling Format',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          value: _sellingFormat,
          items: ['Format', 'Auction', 'Fixed Price', 'Best Offer'],
          onChanged: (value) {
            setState(() => _sellingFormat = value!);
          },
        ),
      ],
    );
  }

  Widget _buildPrimaryTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Tags',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedTags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: const Color(0xFFE3F2FD),
              labelStyle: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsDropdown() {
    return _buildDropdownField(
      value: 'Tags',
      items: ['Tags', 'New', 'Vintage', 'Limited Edition', 'Sale'],
      onChanged: (value) {},
    );
  }

  Widget _buildBrandDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Brand',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          value: _primaryBrand,
          items: ['Brand', 'Nike', 'Adidas', 'Puma', 'Gucci'],
          onChanged: (value) {
            setState(() => _primaryBrand = value!);
          },
        ),
      ],
    );
  }

  Widget _buildShippingSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Settings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Free Pickup', style: TextStyle(fontSize: 14)),
            Row(
              children: [
                const Text('On', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Switch(
                  value: _freePickup,
                  onChanged: (value) {
                    setState(() => _freePickup = value);
                  },
                  activeColor: const Color(0xFF00BCD4),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content Settings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Explicit Content', style: TextStyle(fontSize: 14)),
            Switch(
              value: _explicitContent,
              onChanged: (value) {
                setState(() => _explicitContent = value);
              },
              activeColor: const Color(0xFF00BCD4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMutedWordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Muted Words',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          value: _mutedWords.join(', '),
          items: [_mutedWords.join(', ')],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Language',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          value: _primaryLanguage,
          items: ['English', 'Spanish', 'French', 'German', 'Italian'],
          onChanged: (value) {
            setState(() => _primaryLanguage = value!);
          },
        ),
      ],
    );
  }

  Widget _buildDiscoverabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Show Discoverability',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'Public',
                groupValue: _discoverability,
                onChanged: (value) {
                  setState(() => _discoverability = value!);
                },
                title: const Text('Public', style: TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF00BCD4),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: 'Private',
                groupValue: _discoverability,
                onChanged: (value) {
                  setState(() => _discoverability = value!);
                },
                title: const Text('Private', style: TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF00BCD4),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromoteShowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promote Show',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enable promotion', style: TextStyle(fontSize: 14)),
            Switch(
              value: _promoteShow,
              onChanged: (value) {
                setState(() => _promoteShow = value);
              },
              activeColor: const Color(0xFF00BCD4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
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
                  const SnackBar(content: Text('Show draft saved')),
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
                  // Navigate to Start Stream screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StartStreamScreen(),
                    ),
                  );
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
                'Go Live',
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
