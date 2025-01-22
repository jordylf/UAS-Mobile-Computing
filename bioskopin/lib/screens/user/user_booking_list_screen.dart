import 'dart:convert';

import 'package:bioskopin/utils/format_date.dart';
import 'package:bioskopin/utils/format_price.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/utils/shared_preferences.dart';
import 'package:bioskopin/widgets/card.dart';
import 'package:bioskopin/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class UserBookingListScreen extends StatefulWidget {
  const UserBookingListScreen({super.key});

  @override
  State<UserBookingListScreen> createState() => _UserBookingListScreenState();
}

class _UserBookingListScreenState extends State<UserBookingListScreen> {
  late Future<Map<String, dynamic>> bookings;

  @override
  void initState() {
    super.initState();

    bookings = fetchBookings();
  }

  Future<Map<String, dynamic>> fetchBookings() async {
    try {
      var userId = SharedPreferencesService().getString('userId');

      final response =
          await HttpService.get('booking/get.php?user_id=$userId', headers: {});

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load films');
      }
    } catch (e) {
      throw Exception('Error fetching films: $e');
    }
  }

  Future<void> refreshBookings() async {
    setState(() {
      bookings = fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan Saya'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: bookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 10,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  return CardBookingSkeleton();
                },
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            } else if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text('Tidak ada pesanan saya')),
              );
            } else {
              List bookings = snapshot.data!['data'];

              return RefreshIndicator(
                onRefresh: () async {
                  await refreshBookings();
                },
                child: ListView.builder(
                  itemCount: bookings.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];

                    return CardBooking(
                      title: booking['title'],
                      bookingCount: booking['ticket_quantity'].toString(),
                      totalPrice: booking['total_price'].toString(),
                      date: booking['created_at'],
                      status: booking['status'],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class CardBooking extends StatelessWidget {
  final String title;
  final String bookingCount;
  final String totalPrice;
  final String date;
  final String status;

  const CardBooking({
    super.key,
    required this.title,
    required this.bookingCount,
    required this.totalPrice,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'confirmed':
          return Colors.green;
        case 'canceled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return CustomCard(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Jumlah Pesanan: $bookingCount',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Total Harga: ${FormatPriceUtil.formatPrice(totalPrice)}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Tanggal Pemesanan: ${FormatDateUtil.formatDateTime(date)}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Status: ${status.toUpperCase()}',
              style: TextStyle(
                fontSize: 12.0,
                color: getStatusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardBookingSkeleton extends StatelessWidget {
  const CardBookingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSkeleton(
      containersColor: Colors.white,
      child: CustomCard(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lorem, ipsum dolor. Lorem, ipsum dolor.',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Lorem, ipsum dolor.',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Lorem, ipsum dolor.',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Lorem, ipsum.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
