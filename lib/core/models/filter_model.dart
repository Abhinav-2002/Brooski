import 'package:flutter/material.dart';

class FilterModel {
  final RangeValues priceRange;
  final double distance;
  final bool showUrgentOnly;
  final bool mySkillsOnly;
  final String timePosted;
  final String sortBy;
  final Set<String> selectedSubCategories;

  FilterModel({
    required this.priceRange,
    required this.distance,
    required this.showUrgentOnly,
    required this.mySkillsOnly,
    required this.timePosted,
    required this.sortBy,
    required this.selectedSubCategories,
  });
}
