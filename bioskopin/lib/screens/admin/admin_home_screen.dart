import 'package:bioskopin/screens/admin/admin_manage_booking_screen.dart';
import 'package:bioskopin/screens/admin/admin_manage_film_screen.dart';
import 'package:bioskopin/screens/admin/admin_manage_user_screen.dart';
import 'package:bioskopin/screens/profile_screen.dart';
import 'package:bioskopin/utils/dialog.dart';
import 'package:bioskopin/widgets/card.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }

        DialogHelper.showLogoutDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bioskopin Admin'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo Admin, Selamat Datang!',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'Berikut adalah beberapa menu yang tersedia untuk Admin.',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  CustomCard(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminManageFilmScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.movie,
                            size: 40.0,
                            color: Colors.blueAccent,
                          ),
                          title: const Text(
                            'Kelola Film',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: const Text(
                            'Kelola daftar film yang telah dibuat',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  CustomCard(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminManageBookingScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.calendar_month,
                            size: 40.0,
                            color: Colors.orange,
                          ),
                          title: const Text(
                            'Kelola Pesanan Tiket',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: const Text(
                            'Kelola daftar pesanan tiket yang telah dibuat',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  CustomCard(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminManageUserScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.people,
                            size: 40.0,
                            color: Colors.green,
                          ),
                          title: const Text(
                            'Kelola Pengguna',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: const Text(
                            'Kelola daftar pengguna yang terdaftar',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  CustomCard(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            size: 40.0,
                            color: Colors.green,
                          ),
                          title: const Text(
                            'Profil Saya',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: const Text(
                            'Lihat profil pengguna Anda',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          label: const Text('Keluar'),
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => DialogHelper.showLogoutDialog(context),
        ),
      ),
    );
  }
}
