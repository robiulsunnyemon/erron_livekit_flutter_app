import 'package:get_storage/get_storage.dart';
import 'app/core/theme/app_colors.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync(() => AuthService().init());
  
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
      theme: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color:  AppColors.secondaryPrimary,
        )
      ),
    ),
  );
}



