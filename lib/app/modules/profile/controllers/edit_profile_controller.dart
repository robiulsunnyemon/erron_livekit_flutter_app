import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  final AuthService _authService = AuthService.to;
  final ImagePicker _picker = ImagePicker();
  
  final isLoading = false.obs;
  final isUploading = false.obs;
  
  // Controllers
  final bioController = TextEditingController();
  final nameController = TextEditingController(); // We will split this for first/last name
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController(); // Read-only usually
  
  final selectedGender = "".obs;
  final selectedCountry = "".obs;
  
  final genders = ["Male", "Female", "Other"];
  final countries = ["USA", "UK", "Bangladesh", "India", "Canada", "Australia"];

  var user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    // Load current user data
    final profileCtrl = Get.find<ProfileController>();
    if (profileCtrl.user.value != null) {
      user.value = profileCtrl.user.value;
      _populateFields();
    }
  }

  void _populateFields() {
    final u = user.value!;
    bioController.text = u.bio ?? "";
    nameController.text = u.fullName;
    dobController.text = u.dob ?? "";
    phoneController.text = u.phoneNumber ?? "";
    emailController.text = u.email;
    selectedGender.value = u.gender ?? "Male";
    selectedCountry.value = u.country ?? "USA";
  }

  Future<void> pickAndUploadImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    isUploading.value = true;
    try {
      bool success = false;
      if (isProfile) {
        success = await _authService.uploadProfileImage(image.path);
      } else {
        success = await _authService.uploadCoverImage(image.path);
      }

      if (success) {
        // Refresh local user and global profile
        final updatedUser = await _authService.getMyProfile();
        if (updatedUser != null) {
          user.value = updatedUser;
          Get.find<ProfileController>().user.value = updatedUser;
        }
        Get.snackbar("Success", "${isProfile ? 'Profile' : 'Cover'} image updated successfully");
      }
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4C4DDC),
              onPrimary: Colors.white,
              surface: Color(0xFF161621),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> saveProfile() async {
    isLoading.value = true;
    try {
      // Split name into first and last
      String firstName = nameController.text.trim();
      String lastName = "";
      if (firstName.contains(" ")) {
        final parts = firstName.split(" ");
        firstName = parts[0];
        lastName = parts.sublist(1).join(" ");
      }

      final data = {
        "first_name": firstName,
        "last_name": lastName,
        "bio": bioController.text.trim(),
        "country": selectedCountry.value,
        "gender": selectedGender.value,
        "date_of_birth": dobController.text.trim(),
        "phone_number": phoneController.text.trim(),
      };

      final success = await _authService.updateProfile(data);
      if (success) {
        final updatedUser = await _authService.getMyProfile();
        if (updatedUser != null) {
          Get.find<ProfileController>().user.value = updatedUser;
        }
        Get.back();
        Get.snackbar("Success", "Profile updated successfully");
      }
    } finally {
      isLoading.value = false;
    }
  }
}
