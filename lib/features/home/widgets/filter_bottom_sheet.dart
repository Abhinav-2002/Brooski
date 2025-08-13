import 'package:brooski_app/core/models/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterModel initialFilters;
  final Function(FilterModel) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // State
  late RangeValues _priceRange;
  late double _distance;
  late bool _showUrgentOnly;
  late bool _mySkillsOnly;
  late String _timePosted;
  late String _sortBy;
  late Set<String> _selectedSubCategories;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialFilters.priceRange;
    _distance = widget.initialFilters.distance;
    _showUrgentOnly = widget.initialFilters.showUrgentOnly;
    _mySkillsOnly = widget.initialFilters.mySkillsOnly;
    _timePosted = widget.initialFilters.timePosted;
    _sortBy = widget.initialFilters.sortBy;
    _selectedSubCategories = Set.from(widget.initialFilters.selectedSubCategories);
  }

  // Data from worker_step_2_role_info.dart
  final Map<String, List<String>> _categories = {
    'Home & Maintenance': ['Plumbing', 'Electrical', 'Carpentry', 'Painting', 'Cleaning', 'Pest Control', 'HVAC', 'Handyman'],
    'Professional Services': ['Accounting', 'Legal Advice', 'Digital Marketing', 'Graphic Design', 'Photography', 'Content Writing', 'Translation'],
    'Personal Care & Wellness': ['Beauty & Salon', 'Massage Therapy', 'Fitness Training', 'Yoga Instruction', 'Diet/Nutrition Coaching'],
    'Education & Coaching': ['Academic Tutoring (Math, Science, Languages)', 'Test Prep', 'Music Lessons', 'Art Classes', 'Career Coaching'],
    'Delivery & Transport': ['Parcel Delivery', 'Grocery Shopping', 'Ride-Hailing', 'Vehicle Repair', 'Bike/Motorbike Courier'],
    'Events & Hospitality': ['Catering', 'Event Planning', 'DJ/MC', 'Photography/Videography', 'Decorations', 'Venue Setup'],
    'Industrial & Technical': ['Machine Maintenance', 'Welding', 'Electrical Fitting', 'Fabrication', 'Quality Inspection', 'Factory Clean-up'],
    'Healthcare & Home Care': ['Elderly Care', 'Baby Sitting', 'Physiotherapy', 'Medical Equipment Repair', 'Lab Sample Pickup'],
    'Agriculture & Outdoors': ['Farm Labor', 'Harvesting', 'Landscaping', 'Gardening', 'Livestock Care'],
    'IT & Emerging Tech': ['App Development', 'Web Development', 'IoT Device Installation', 'Drone Operations', 'Robotics Maintenance']
  };

  final Map<String, IconData> _categoryIcons = {
    'Home & Maintenance': Icons.home_repair_service_outlined,
    'Professional Services': Icons.work_outline,
    'Personal Care & Wellness': Icons.spa_outlined,
    'Education & Coaching': Icons.school_outlined,
    'Delivery & Transport': Icons.local_shipping_outlined,
    'Events & Hospitality': Icons.celebration_outlined,
    'Industrial & Technical': Icons.precision_manufacturing_outlined,
    'Healthcare & Home Care': Icons.medical_services_outlined,
    'Agriculture & Outdoors': Icons.eco_outlined,
    'IT & Emerging Tech': Icons.computer_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildMySkillsFilter(),
                const SizedBox(height: 24),
                _buildSectionTitle('Job Type / Category'),
                _buildCategoryFilter(),
                const SizedBox(height: 24),
                _buildSectionTitle('Distance (km)'),
                _buildDistanceFilter(),
                const SizedBox(height: 24),
                _buildSectionTitle('Price Range (₹)'),
                _buildPriceRangeFilter(),
                const SizedBox(height: 24),
                _buildUrgencyFilter(),
                const SizedBox(height: 24),
                _buildSectionTitle('Time Posted'),
                _buildTimePostedFilter(),
                const SizedBox(height: 24),
                _buildSectionTitle('Sort By'),
                _buildSortByFilter(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Filters', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600));
  }

  Widget _buildCategoryFilter() {
    return Column(
      children: _categories.keys.map((category) {
        return ExpansionTile(
          leading: Icon(_categoryIcons[category] ?? Icons.work, color: const Color(0xFF2ECC71)),
          title: Text(category, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _categories[category]!.map((subcategory) {
                  final isSelected = _selectedSubCategories.contains(subcategory);
                  return FilterChip(
                    label: Text(subcategory),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSubCategories.add(subcategory);
                        } else {
                          _selectedSubCategories.remove(subcategory);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF2ECC71).withAlpha(51),
                    checkmarkColor: const Color(0xFF2ECC71),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDistanceFilter() {
    return Slider(
      value: _distance,
      min: 0,
      max: 10,
      divisions: 10,
      label: '${_distance.toStringAsFixed(1)} km',
      activeColor: const Color(0xFF2ECC71),
      onChanged: (value) {
        setState(() {
          _distance = value;
        });
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    return RangeSlider(
      values: _priceRange,
      min: 100,
      max: 2000,
      divisions: 19,
      labels: RangeLabels('₹${_priceRange.start.round()}', '₹${_priceRange.end.round()}'),
      activeColor: const Color(0xFF2ECC71),
      onChanged: (values) {
        setState(() {
          _priceRange = values;
        });
      },
    );
  }

  Widget _buildUrgencyFilter() {
    return SwitchListTile(
      title: Text('Show only Urgent Jobs 🔥', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500)),
      value: _showUrgentOnly,
      onChanged: (value) {
        setState(() {
          _showUrgentOnly = value;
        });
      },
      activeColor: const Color(0xFF2ECC71),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMySkillsFilter() {
    return SwitchListTile(
      title: Text('Show only jobs I’m eligible for', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text('Based on your profile skills', style: GoogleFonts.lato()),
      value: _mySkillsOnly,
      onChanged: (value) {
        setState(() {
          _mySkillsOnly = value;
        });
      },
      activeColor: const Color(0xFF2ECC71),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTimePostedFilter() {
    return Wrap(
      spacing: 8.0,
      children: ['All', 'Last 1 hour', 'Today'].map((time) {
        return ChoiceChip(
          label: Text(time),
          selected: _timePosted == time,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _timePosted = time;
              });
            }
          },
          selectedColor: const Color(0xFF2ECC71).withAlpha(51),
        );
      }).toList(),
    );
  }

  Widget _buildSortByFilter() {
    return Wrap(
      spacing: 8.0,
      children: ['Recommended', 'Price (High → Low)', 'Distance (Near → Far)', 'Newest'].map((sort) {
        return ChoiceChip(
          label: Text(sort),
          selected: _sortBy == sort,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _sortBy = sort;
              });
            }
          },
          selectedColor: const Color(0xFF2ECC71).withAlpha(51),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _priceRange = const RangeValues(100, 2000);
                _distance = 5.0;
                _showUrgentOnly = false;
                _mySkillsOnly = false;
                _timePosted = 'All';
                _sortBy = 'Recommended';
                _selectedSubCategories.clear();
              });
            },
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              final newFilters = FilterModel(
                priceRange: _priceRange,
                distance: _distance,
                showUrgentOnly: _showUrgentOnly,
                mySkillsOnly: _mySkillsOnly,
                timePosted: _timePosted,
                sortBy: _sortBy,
                selectedSubCategories: _selectedSubCategories,
              );
              widget.onApply(newFilters);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}
