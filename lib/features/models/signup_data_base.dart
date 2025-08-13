abstract class SignupData {
  // Common fields for all signup flows
  String? fullName;
  String? gender;
  DateTime? dob;
  String? city;

  // KYC Info (Optional)
  String? aadhaarNumber;
  String? panNumber;

  // Emergency Contact
  String? emergencyContactName;
  String? emergencyContactPhone;
  bool emergencyContactConsent = false;
}
