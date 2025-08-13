import 'package:brooski_app/core/models/signup_data_base.dart';

class WorkerSignupData extends SignupData {
  // Worker-specific fields
  String? jobCategory;
  String? subCategory;
  String? experienceLevel;

  List<String> skills = [];
  List<String> languages = [];
}
