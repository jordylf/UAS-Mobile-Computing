import 'dart:convert';
import 'dart:io';

import 'package:bioskopin/utils/dialog.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/utils/snackbar.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:bioskopin/widgets/card.dart';
import 'package:bioskopin/widgets/input.dart';
import 'package:bioskopin/widgets/overlay_loader.dart';
import 'package:bioskopin/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AdminManageFilmScreen extends StatefulWidget {
  const AdminManageFilmScreen({super.key});

  @override
  State<AdminManageFilmScreen> createState() => _AdminManageFilmScreenState();
}

class _AdminManageFilmScreenState extends State<AdminManageFilmScreen> {
  late Future<Map<String, dynamic>> films;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    films = fetchFilms();
  }

  Future<Map<String, dynamic>> fetchFilms() async {
    try {
      final response = await HttpService.get('film/get.php', headers: {});

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load films');
      }
    } catch (e) {
      throw Exception('Error fetching films: $e');
    }
  }

  Future<void> refreshFilms() async {
    setState(() {
      films = fetchFilms();
    });
  }

  Future<void> showAddFilmDialog(
    BuildContext context,
    Function({
      XFile? pickedImage,
      required String title,
      required String genre,
    required String price,
      required String duration,
      required String description,
      required String showTime,
    }) callback,
  ) async {
    await Permission.photos.request();
    await Permission.camera.request();
    await Permission.storage.request();

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DialogFormAddFilm(callback: callback);
      },
    );
  }

  Future<void> handleAddFilm({
    XFile? pickedImage,
    required String title,
    required String genre,
    required String price,
    required String duration,
    required String description,
    required String showTime,
  }) async {
    try {
      Navigator.pop(context);

      setState(() {
        isLoading = true;
      });

      var uri = Uri.parse('${HttpService.baseUrl}/film/create.php');

      // Siapkan body data
      var request = http.MultipartRequest('POST', uri);

      // Menambahkan field teks
      request.fields['title'] = title;
      request.fields['genre'] = genre;
      request.fields['price'] = price;
      request.fields['duration'] = duration;
      request.fields['description'] = description;
      request.fields['showtime'] = showTime;

      // Jika ada gambar, tambahkan ke request
      if (pickedImage != null) {
        // Mendeteksi MIME type dari file gambar
        final mimeType = lookupMimeType(pickedImage.path);
        final file = await http.MultipartFile.fromPath(
          'image', // Sesuaikan dengan field yang diinginkan di server
          pickedImage.path,
          contentType: mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('application', 'octet-stream'),
        );
        request.files.add(file);
      }

      // Mengirimkan request
      var response = await request.send();

      final responseBody = response.stream.bytesToString();

      // Menangani respons
      if (response.statusCode == 201) {
        // Menangani sukses

        if (!mounted) return;
        SnackbarHelper.showSnackbarSuccess(
          context,
          'Film berhasil ditambahkan',
        );

        refreshFilms();
      } else {
        // Menangani kegagalan
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Film gagal ditambahkan',
        );
        // Tampilkan pesan error jika diperlukan
      }
    } catch (e) {
      if (!mounted) return;

      SnackbarHelper.showSnackbarError(context, e.toString());
      // Menangani error, misalnya tampilkan pesan error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showEditFilmDialog(
    int id,
    String title,
    String price,
    String description,
    Function({
      required int id,
      required String title,
    required String price,
      required String description,
    }) callback,
  ) async {
    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DialogFormEditFilm(
          id: id,
          title: title,
          price: price,
          description: description,
          callback: callback,
        );
      },
    );
  }

  Future<void> handleEditFilm({
    required int id,
    required String title,
    required String price,
    required String description,
  }) async {
    try {
      Navigator.pop(context);

      setState(() {
        isLoading = true;
      });

      final response = await HttpService.put(
        'film/update.php',
        body: {
          'id': id.toString(),
          'title': title,
          'price': price,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Film berhasil diedit',
        );

        refreshFilms();
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Film gagal diedit',
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

  Future<void> handleDeleteFilm({required int filmId}) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await HttpService.delete('film/delete.php?id=$filmId');

      if (response.statusCode == 200) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Film berhasil dihapus',
        );

        refreshFilms();
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Film gagal dihapus',
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
        title: const Text('Kelola Film'),
      ),
      body: OverlayLoader(
        isLoading: isLoading,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FutureBuilder(
              future: films,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 10,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      return CardFilmSkeleton();
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
                  List films = snapshot.data!['data'];

                  return RefreshIndicator(
                    onRefresh: () async {
                      refreshFilms();
                    },
                    child: ListView.builder(
                      itemCount: films.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemBuilder: (context, index) {
                        final film = films[index];

                        return CardFilm(
                          imageUrl: film['image'],
                          title: film['title'],
                          description: film['description'],
                          onEdit: () {
                            showEditFilmDialog(
                              film['id'],
                              film['title'],
                              film['price'].toString(),
                              film['description'],
                              handleEditFilm,
                            );
                          },
                          onDelete: () async {
                            bool isConfirm =
                                await DialogHelper.showDeleteDialog(context);

                            if (isConfirm) {
                              handleDeleteFilm(filmId: film['id']);
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
          showAddFilmDialog(context, handleAddFilm);
        },
      ),
    );
  }
}

class CardFilm extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final Function() onEdit;
  final Function() onDelete;

  const CardFilm({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: Colors.white,
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 60.0,
          height: 60.0,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported_outlined,
              size: 60.0,
              color: Colors.grey,
            );
          },
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          description,
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

class CardFilmSkeleton extends StatelessWidget {
  const CardFilmSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSkeleton(
      containersColor: Colors.white,
      child: CustomCard(
        color: Colors.white,
        child: ListTile(
          leading: Container(
            width: 60.0,
            height: 60.0,
            color: Colors.grey,
          ),
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

class DialogFormAddFilm extends StatefulWidget {
  final Function({
    XFile? pickedImage,
    required String title,
    required String genre,
  required String price,
    required String duration,
    required String description,
    required String showTime,
  }) callback;

  const DialogFormAddFilm({super.key, required this.callback});

  @override
  State<DialogFormAddFilm> createState() => _DialogFormAddFilmState();
}

class _DialogFormAddFilmState extends State<DialogFormAddFilm> {
  final formKey = GlobalKey<FormState>();

  final picker = ImagePicker();
  XFile? pickedImage;
  final titleController = TextEditingController();
  final genreController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedDate = '';

  @override
  void dispose() {
    titleController.dispose();
    genreController.dispose();
    priceController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Film',
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
                Text(
                  '*Semua field wajib diisi',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () async {
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      if (context.mounted) {
                        setState(() {
                          pickedImage = pickedFile;
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 180.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: pickedImage == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey,
                          )
                        : Image.file(
                            File(pickedImage!.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 180.0,
                                color: Colors.red,
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 20.0),
                CustomInput(
                  label: 'Judul Film',
                  controller: titleController,
                ),
                const SizedBox(height: 10.0),
                CustomInput(
                  label: 'Genre Film',
                  controller: genreController,
                ),
                const SizedBox(height: 10.0),
                CustomInput(
                  label: 'Harga',
                  controller: priceController,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 10.0),
                CustomInput(
                  label: 'Durasi Film',
                  controller: durationController,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 10.0),
                CustomInput(
                  label: 'Deskripsi Film',
                  controller: descriptionController,
                  maxLines: 5,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Tanggal Tayang',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0XFFD6D6D6),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF277FBF),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0XFFB71B1B),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0XFFB71B1B),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: selectedDate != ''
                        ? DateFormat('yyyy-MM-dd').format(
                            DateTime.parse(selectedDate).toLocal(),
                          )
                        : 'Tanggal Tayang',
                    hintStyle: TextStyle(
                      color: selectedDate != ''
                          ? Colors.black
                          : Colors.black.withValues(alpha: 0.5),
                      fontSize: 14.0,
                    ),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      helpText: 'Pilih Tanggal',
                      fieldLabelText: 'Tanggal',
                      cancelText: 'Batal',
                      confirmText: 'Konfirmasi',
                    ).then((pickedDate) {
                      if (pickedDate != null) {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          helpText: 'Pilih Waktu',
                          cancelText: 'Batal',
                          confirmText: 'Konfirmasi',
                        ).then((pickedTime) {
                          if (pickedTime != null) {
                            final combinedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            setState(() {
                              selectedDate = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);
                            });
                          }
                        });
                      }
                    });
                  },
                ),
                const SizedBox(height: 30.0),
                CustomButton(
                  label: 'Simpan',
                  borderRadius: 10.0,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (pickedImage != null ||
                          titleController.text.isNotEmpty ||
                          genreController.text.isNotEmpty ||
                          durationController.text.isNotEmpty ||
                          descriptionController.text.isNotEmpty ||
                          selectedDate.isNotEmpty) {
                        widget.callback(
                          pickedImage: pickedImage,
                          title: titleController.text,
                          genre: genreController.text,
                          price: priceController.text,
                          duration: durationController.text,
                          description: descriptionController.text,
                          showTime: selectedDate,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DialogFormEditFilm extends StatefulWidget {
  final int id;
  final String title;
  final String price;
  final String description;

  final Function({
    required int id,
    required String title,
  required String price,
    required String description,
  }) callback;

  const DialogFormEditFilm({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.callback,
  });

  @override
  State<DialogFormEditFilm> createState() => _DialogFormEditFilmState();
}

class _DialogFormEditFilmState extends State<DialogFormEditFilm> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.title;
    priceController.text = widget.price;
    descriptionController.text = widget.description;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Film',
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
                Text(
                  '*Semua field wajib diisi',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                CustomInput(
                  label: 'Judul Film',
                  controller: titleController,
                ),
                const SizedBox(height: 10.0),
                CustomInput(
                  label: 'Harga',
                  controller: priceController,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 10.0),
                CustomInput(
                  label: 'Deskripsi Film',
                  controller: descriptionController,
                  maxLines: 5,
                ),
                const SizedBox(height: 30.0),
                CustomButton(
                  label: 'Simpan',
                  borderRadius: 10.0,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (titleController.text.isNotEmpty ||
                          descriptionController.text.isNotEmpty) {
                        widget.callback(
                          id: widget.id,
                          title: titleController.text,
                          price: priceController.text,
                          description: descriptionController.text,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
