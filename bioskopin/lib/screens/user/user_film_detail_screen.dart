import 'dart:convert';

import 'package:bioskopin/screens/user/user_film_booking_ticket_screen.dart';
import 'package:bioskopin/utils/format_date.dart';
import 'package:bioskopin/utils/format_price.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:bioskopin/widgets/overlay_loader.dart';
import 'package:flutter/material.dart';

class UserFilmDetailScreen extends StatefulWidget {
  final String filmId;

  const UserFilmDetailScreen({super.key, required this.filmId});

  @override
  State<UserFilmDetailScreen> createState() => _UserFilmDetailScreenState();
}

class _UserFilmDetailScreenState extends State<UserFilmDetailScreen> {
  bool isLoading = true;

  late Future<Map<String, dynamic>> detail;

  @override
  void initState() {
    super.initState();

    detail = fetchDetail();
  }

  Future<Map<String, dynamic>> fetchDetail() async {
    try {
      final response = await HttpService.get(
        'film/detail.php?id=${widget.filmId}',
        headers: {},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Film not found');
      } else {
        throw Exception('Failed to load films');
      }
    } catch (e) {
      throw Exception('Error fetching films: $e');
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
        title: const Text('Detail Film'),
      ),
      body: SafeArea(
        child: OverlayLoader(
          isLoading: isLoading,
          child: Visibility(
            visible: !isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                future: detail,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['data'].isEmpty) {
                    return Center(child: Text('Film tidak ditemukan'));
                  } else {
                    var film = snapshot.data!['data'];

                    var price = film['price'];

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            film['image'],
                            width: double.infinity,
                            height: 180.0,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            film['title'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                  color: Color.fromRGBO(224, 224, 224, 1),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Genre',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  film['genre'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                  color: Color.fromRGBO(224, 224, 224, 1),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Harga',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  FormatPriceUtil.formatPrice(price),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                  color: Color.fromRGBO(224, 224, 224, 1),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Durasi',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  '${film['duration']} menit',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                  color: Color.fromRGBO(224, 224, 224, 1),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Tayang',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  FormatDateUtil.formatDateTime(
                                    film['showtime'],
                                  ),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            'Deskripsi Film',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            film['description'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: detail,
        builder: (context, snapshot) {
          bool hasData = snapshot.hasData && snapshot.data!['data'] != null;

          return Visibility(
            visible: hasData,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                label: 'Pesan Tiket Film',
                borderRadius: 10.0,
                textColor: Colors.white,
                onPressed: () {
                  var film = snapshot.data!['data'];

                  // Navigasi ke halaman booking
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserFilmBookingTicketScreen(
                        filmId: film['id'].toString(),
                        filmTitle: film['title'],
                        filmPrice: film['price'],
                        filmShowtime: film['showtime'],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
