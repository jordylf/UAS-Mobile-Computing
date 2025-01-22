import 'dart:convert';

import 'package:bioskopin/utils/dialog.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/utils/snackbar.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:bioskopin/widgets/card.dart';
import 'package:bioskopin/widgets/input.dart';
import 'package:bioskopin/widgets/input_password.dart';
import 'package:bioskopin/widgets/overlay_loader.dart';
import 'package:bioskopin/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class AdminManageUserScreen extends StatefulWidget {
  const AdminManageUserScreen({super.key});

  @override
  State<AdminManageUserScreen> createState() => _AdminManageUserScreenState();
}

class _AdminManageUserScreenState extends State<AdminManageUserScreen> {
  late Future<Map<String, dynamic>> users;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    users = fetchUsers();
  }

  Future<Map<String, dynamic>> fetchUsers() async {
    try {
      final response = await HttpService.get('user/get.php', headers: {});

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<void> refreshUsers() async {
    setState(() {
      users = fetchUsers();
    });
  }

  Future<void> showAddUserDialog(
    BuildContext context,
    Function({
      required String name,
      required String email,
      required String password,
    }) callback,
  ) async {
    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DialogFormAddUser(callback: callback);
      },
    );
  }

  Future<void> handleAddUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      Navigator.pop(context);

      setState(() {
        isLoading = true;
      });

      final response = await HttpService.post(
        'user/create.php',
        body: {
          'fullname': name,
          'email': email,
          'password': password,
        },
        isJson: true,
      );

      if (response.statusCode == 201) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Pengguna berhasil dibuat!',
        );

        refreshUsers();
      } else if (response.statusCode == 409) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Email sudah terdaftar!',
        );
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Pengguna gagal dibuat!',
        );
      }
    } catch (e) {
      if (!mounted) return;

      SnackbarHelper.showSnackbarError(context, 'Terjadi kesalahan!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showEditUserDialog(
    int id,
    String name,
    String email,
    Function({
      required int id,
      required String name,
      required String email,
      required String password,
    }) callback,
  ) async {
    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DialogFormEditUser(
          id: id,
          name: name,
          email: email,
          callback: callback,
        );
      },
    );
  }

  Future<void> handleEditUser({
    required int id,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      Navigator.pop(context);

      setState(() {
        isLoading = true;
      });

      final response = await HttpService.put(
        'user/update.php',
        body: {
          'id': id.toString(),
          'fullname': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Pengguna berhasil diedit',
        );

        refreshUsers();
      } else if (response.statusCode == 409) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Email sudah terdaftar!',
        );
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Pengguna gagal diedit',
        );
      }
    } catch (e) {
      if (!mounted) return;

      SnackbarHelper.showSnackbarError(context, 'Terjadi kesalahan!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleDeleteUser({required int userId}) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await HttpService.delete('user/delete.php?id=$userId');

      if (response.statusCode == 200) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Pengguna berhasil dihapus',
        );

        refreshUsers();
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Pengguna gagal dihapus',
        );
      }
    } catch (e) {
      if (!mounted) return;

      SnackbarHelper.showSnackbarError(context, 'Terjadi kesalahan!');
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
        title: const Text('Kelola Pengguna'),
      ),
      body: OverlayLoader(
        isLoading: isLoading,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FutureBuilder(
              future: users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 10,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      return CardUserSkeleton();
                    },
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data!['data'].isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text('Tidak ada film yang tersedia')),
                  );
                } else {
                  List users = snapshot.data!['data'];

                  return RefreshIndicator(
                    onRefresh: () async {
                      refreshUsers();
                    },
                    child: ListView.builder(
                      itemCount: users.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return CardUser(
                          name: user['fullname'],
                          email: user['email'],
                          onEdit: () {
                            showEditUserDialog(
                              user['id'],
                              user['fullname'],
                              user['email'],
                              handleEditUser,
                            );
                          },
                          onDelete: () async {
                            bool isConfirm =
                                await DialogHelper.showDeleteDialog(context);

                            if (isConfirm) {
                              handleDeleteUser(userId: user['id']);
                            }
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF277FBF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showAddUserDialog(context, handleAddUser);
        },
      ),
    );
  }
}

class CardUser extends StatelessWidget {
  final String name;
  final String email;
  final Function() onEdit;
  final Function() onDelete;

  const CardUser({
    super.key,
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: Colors.white,
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          email,
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class CardUserSkeleton extends StatelessWidget {
  const CardUserSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSkeleton(
      containersColor: Colors.white,
      child: CustomCard(
        color: Colors.white,
        child: ListTile(
          title: Container(
            width: 150.0,
            height: 12.0,
            color: Colors.grey,
          ),
          subtitle: Container(
            width: 150.0,
            height: 12.0,
            color: Colors.grey,
          ),
          trailing: Container(
            width: 100.0,
            height: 40.0,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class DialogFormAddUser extends StatefulWidget {
  final Function({
    required String name,
    required String email,
    required String password,
  }) callback;

  const DialogFormAddUser({
    super.key,
    required this.callback,
  });

  @override
  State<DialogFormAddUser> createState() => _DialogFormAddUserState();
}

class _DialogFormAddUserState extends State<DialogFormAddUser> {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Pengguna',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              CustomInput(
                label: 'Nama Lengkap',
                controller: nameController,
              ),
              const SizedBox(height: 10.0),
              CustomInput(
                label: 'Email',
                controller: emailController,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10.0),
              CustomInputPassword(
                label: 'Password',
                controller: passwordController,
              ),
              const SizedBox(height: 30.0),
              CustomButton(
                label: 'Simpan',
                borderRadius: 10.0,
                onPressed: () {
                  widget.callback(
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
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

class DialogFormEditUser extends StatefulWidget {
  final int id;
  final String name;
  final String email;
  final Function({
    required int id,
    required String name,
    required String email,
    required String password,
  }) callback;

  const DialogFormEditUser({
    super.key,
    required this.id,
    required this.name,
    required this.email,
    required this.callback,
  });

  @override
  State<DialogFormEditUser> createState() => _DialogFormEditUserState();
}

class _DialogFormEditUserState extends State<DialogFormEditUser> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.name;
    emailController.text = widget.email;
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Pengguna',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              CustomInput(
                label: 'Nama Lengkap',
                controller: nameController,
              ),
              const SizedBox(height: 10.0),
              CustomInput(
                label: 'Email',
                controller: emailController,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10.0),
              CustomInputPassword(
                label: 'Password',
                controller: passwordController,
              ),
              const SizedBox(height: 30.0),
              CustomButton(
                label: 'Simpan',
                borderRadius: 10.0,
                onPressed: () {
                  widget.callback(
                    id: widget.id,
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
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
