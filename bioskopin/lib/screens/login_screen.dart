import 'dart:convert';

import 'package:bioskopin/screens/admin/admin_home_screen.dart';
import 'package:bioskopin/screens/user/user_home_screen.dart';
import 'package:bioskopin/utils/form_validator.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/utils/shared_preferences.dart';
import 'package:bioskopin/utils/snackbar.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:bioskopin/widgets/input.dart';
import 'package:bioskopin/widgets/input_password.dart';
import 'package:bioskopin/widgets/overlay_loader.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await HttpService.post(
        'auth/login.php',
        body: {
          'email': emailController.text,
          'password': passwordController.text,
        },
        isJson: true,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['data']['role'] == 'user') {
          await SharedPreferencesService()
              .setString('userId', data['data']['userId']);
          await SharedPreferencesService()
              .setString('fullName', data['data']['fullname']);
          await SharedPreferencesService()
              .setString('email', data['data']['email']);

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
            (_) => false,
          );
        } else {
          await SharedPreferencesService()
              .setString('userId', data['data']['userId']);
          await SharedPreferencesService()
              .setString('fullName', data['data']['fullname']);
          await SharedPreferencesService()
              .setString('email', data['data']['email']);

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            (_) => false,
          );
        }
      } else if (response.statusCode == 401) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Email atau kata sandi salah. Silakan coba lagi.',
        );
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Terjadi kesalahan. Silakan coba lagi.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      SnackbarHelper.showSnackbarError(context, e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk'),
      ),
      body: SafeArea(
        child: OverlayLoader(
          isLoading: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100.0,
                    ),
                  ),
                  const Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Silakan masuk untuk melanjutkan',
                    style: TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                  const SizedBox(height: 20.0),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomInput(
                          label: 'Email',
                          controller: emailController,
                          inputType: TextInputType.emailAddress,
                          validator: FormValidator.validateEmail,
                        ),
                        const SizedBox(height: 10.0),
                        CustomInputPassword(
                          label: 'Kata Sandi',
                          controller: passwordController,
                          validator: FormValidator.validatePassword,
                        ),
                        const SizedBox(height: 30.0),
                        CustomButton(
                          label: 'Masuk',
                          borderRadius: 10.0,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              FocusManager.instance.primaryFocus?.unfocus();

                              handleLogin();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
