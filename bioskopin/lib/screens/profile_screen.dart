import 'package:bioskopin/utils/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String email;

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<void> getData() async {
    name = SharedPreferencesService().getString('fullName') ?? '';
    email = SharedPreferencesService().getString('email') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                email,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
              shape: const Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Color.fromRGBO(224, 224, 224, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
