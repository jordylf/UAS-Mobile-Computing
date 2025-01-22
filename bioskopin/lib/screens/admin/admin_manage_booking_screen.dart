import 'dart:convert';

import 'package:bioskopin/utils/dialog.dart';
import 'package:bioskopin/utils/format_date.dart';
import 'package:bioskopin/utils/format_price.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/utils/snackbar.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:bioskopin/widgets/card.dart';
import 'package:bioskopin/widgets/overlay_loader.dart';
import 'package:bioskopin/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class AdminManageBookingScreen extends StatefulWidget {
  const AdminManageBookingScreen({super.key});

  @override
  State<AdminManageBookingScreen> createState() =>
      _AdminManageBookingScreenState();
}

class _AdminManageBookingScreenState extends State<AdminManageBookingScreen> {
  bool isLoading = false;

  late Future<Map<String, dynamic>> bookings;

  @override
  void initState() {
    super.initState();

    bookings = fetchBookings();
  }

  Future<Map<String, dynamic>> fetchBookings() async {
    try {
      final response = await HttpService.get('booking/get.php', headers: {});

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

  Future<void> showEditStatusBookingDialog(
    int id,
    String status,
    Function({
      required int id,
      required String status,
    }) callback,
  ) async {
    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DialogFormEditBooking(
          id: id,
          status: status,
          callback: callback,
        );
      },
    );
  }

  Future<void> handleEditStatusBooking({
    required int id,
    required String status,
  }) async {
    try {
      Navigator.pop(context);

      setState(() {
        isLoading = true;
      });

      final response = await HttpService.put(
        'booking/update.php?id=$id',
        body: {
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Status pesanan berhasil diedit',
        );

        refreshBookings();
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Status pesanan gagal diedit',
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

  Future<void> handleDeleteBooking({required int bookingId}) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response =
          await HttpService.delete('booking/delete.php?id=$bookingId');

      if (response.statusCode == 200) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Pesanan berhasil dihapus',
        );

        refreshBookings();
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Pesanan gagal dihapus',
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
        title: const Text('Kelola Pesanan'),
      ),
      body: OverlayLoader(
        isLoading: isLoading,
        child: SafeArea(
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
                  child: Center(child: Text('Tidak ada pesanan')),
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
                        onEdit: () {
                          showEditStatusBookingDialog(
                            booking['id'],
                            booking['status'],
                            handleEditStatusBooking,
                          );
                        },
                        onDelete: () async {
                          bool confirmed =
                              await DialogHelper.showDeleteDialog(context);
                          if (confirmed) {
                            handleDeleteBooking(bookingId: booking['id']);
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
    );
  }
}

class CardBooking extends StatelessWidget {
  final String title;
  final String bookingCount;
  final String totalPrice;
  final String date;
  final String status;
  final Function() onEdit;
  final Function() onDelete;

  const CardBooking({
    super.key,
    required this.title,
    required this.bookingCount,
    required this.totalPrice,
    required this.date,
    required this.status,
    required this.onEdit,
    required this.onDelete,
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
        child: Row(
          children: [
            Flexible(
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

class DialogFormEditBooking extends StatefulWidget {
  final int id;
  final String status;

  final Function({
    required int id,
    required String status,
  }) callback;

  const DialogFormEditBooking({
    super.key,
    required this.id,
    required this.status,
    required this.callback,
  });

  @override
  State<DialogFormEditBooking> createState() => _DialogFormEditBookingState();
}

class _DialogFormEditBookingState extends State<DialogFormEditBooking> {
  String? status;

  @override
  void initState() {
    super.initState();
    // Initialize the status with the initial value from widget
    status = widget.status;
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
                    'Edit Status Pesanan',
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
              const Text(
                'Pilih Status',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              DropdownButton<String>(
                value: status,
                isExpanded: true,
                hint: const Text('Pilih status'),
                items: ['pending', 'confirmed', 'canceled'].map((statusValue) {
                  return DropdownMenuItem<String>(
                    value: statusValue,
                    child: Text(statusValue),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    status = newValue;
                  });
                },
              ),
              const SizedBox(height: 30.0),
              CustomButton(
                label: 'Simpan',
                borderRadius: 10.0,
                onPressed: () {
                  if (status != null) {
                    widget.callback(
                      id: widget.id,
                      status: status!,
                    );
                  } else {
                    SnackbarHelper.showSnackbarError(
                      context,
                      'Status belum dipilih',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
