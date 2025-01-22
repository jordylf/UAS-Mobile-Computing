import 'package:bioskopin/screens/login_screen.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/utils/snackbar.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:bioskopin/widgets/input.dart';
import 'package:bioskopin/widgets/input_password.dart';
import 'package:bioskopin/widgets/overlay_loader.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await HttpService.post(
        'auth/register.php',
        body: {
          'fullname': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        },
        isJson: true,
      );

      if (response.statusCode == 201) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Pendaftaran berhasil!',
        );
      } else if (response.statusCode == 409) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Email sudah terdaftar.',
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
        title: const Text('Daftar'),
      ),
      body: SafeArea(
        child: SafeArea(
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
                      'Daftar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Silakan daftar untuk melanjutkan pendaftaran sebagai pengguna',
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                    const SizedBox(height: 20.0),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomInput(
                            label: 'Nama',
                            controller: nameController,
                          ),
                          const SizedBox(height: 16.0),
                          CustomInput(
                            label: 'Email',
                            controller: emailController,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16.0),
                          CustomInputPassword(
                            label: 'Kata Sandi',
                            controller: passwordController,
                          ),
                          const SizedBox(height: 30.0),
                          CustomButton(
                            label: 'Daftar',
                            borderRadius: 10.0,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                FocusManager.instance.primaryFocus?.unfocus();

                                handleRegister();
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
      ),
    );
  }
}
