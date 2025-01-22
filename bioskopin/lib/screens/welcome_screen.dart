import 'package:bioskopin/screens/login_screen.dart';
import 'package:bioskopin/screens/register_screen.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 200.0),
              const SizedBox(height: 20.0),
              const Text(
                'Selamat Datang di Bioskopin',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Bioskopin adalah aplikasi pemesanan tiket bioskop yang memudahkan Anda untuk melihat jadwal film dan membeli tiket secara online.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              CustomButton(
                label: 'Masuk',
                borderRadius: 10.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const LoginScreen();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20.0),
              CustomButton(
                label: 'Daftar',
                textColor: Color(0xFF277FBF),
                borderRadius: 10.0,
                borderColor: Color(0xFF277FBF),
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const RegisterScreen();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
