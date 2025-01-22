import 'package:bioskopin/screens/user/user_home_screen.dart';
import 'package:bioskopin/utils/form_validator.dart';
import 'package:bioskopin/utils/format_date.dart';
import 'package:bioskopin/utils/format_price.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/utils/shared_preferences.dart';
import 'package:bioskopin/utils/snackbar.dart';
import 'package:bioskopin/widgets/button.dart';
import 'package:bioskopin/widgets/input.dart';
import 'package:bioskopin/widgets/overlay_loader.dart';
import 'package:flutter/material.dart';

class UserFilmBookingTicketScreen extends StatefulWidget {
  final String filmId;
  final String filmTitle;
  final String filmPrice;
  final String filmShowtime;

  const UserFilmBookingTicketScreen({
    super.key,
    required this.filmId,
    required this.filmTitle,
    required this.filmPrice,
    required this.filmShowtime,
  });

  @override
  State<UserFilmBookingTicketScreen> createState() =>
      _UserFilmBookingTicketScreenState();
}

class _UserFilmBookingTicketScreenState
    extends State<UserFilmBookingTicketScreen> {
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  double totalPrice = 0.0;

  final ticketQtyController = TextEditingController();

  @override
  void initState() {
    _updateTotalPrice();

    super.initState();
  }

  @override
  void dispose() {
    ticketQtyController.dispose();
    super.dispose();
  }

  void _updateTotalPrice() {
    final qty = int.tryParse(ticketQtyController.text) ?? 1;

    setState(() {
      totalPrice = double.parse(widget.filmPrice) * qty;
    });
  }


  Future<void> handleBooking() async {
    try {
      setState(() {
        isLoading = true;
      });

      var userId = SharedPreferencesService().getString('userId');

      final response = await HttpService.post(
        'booking/create.php?id=${widget.filmId}',
        body: {
          'user_id': userId,
          'film_id': widget.filmId,
          'quantity': ticketQtyController.text,
        },
        isJson: true,
      );

      if (response.statusCode == 201) {
        if (!mounted) return;

        SnackbarHelper.showSnackbarSuccess(
          context,
          'Pemesanan tiket film berhasil!',
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
          (_) => false,
        );
      } else {
        if (!mounted) return;

        SnackbarHelper.showSnackbarError(
          context,
          'Pemesanan tiket film gagal!',
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
        title: const Text('Pemesanan Tiket'),
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
                  const Text(
                    'Judul Film',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    widget.filmTitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
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
                  Text(
                    FormatDateUtil.formatDateTime(widget.filmShowtime),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Total Harga',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    FormatPriceUtil.formatPrice(totalPrice.toString()),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomInput(
                          label: 'Jumlah tiket yang akan dipesan',
                          controller: ticketQtyController,
                          hint: 'Jumlah Tiket',
                          inputType: TextInputType.number,
                          validator: FormValidator.validateTicket,
                          onChanged: (_) {
                            _updateTotalPrice();
                          },
                        ),
                        const SizedBox(height: 30.0),
                        CustomButton(
                          label: 'Pesan Sekarang',
                          borderRadius: 10.0,
                          textColor: Colors.white,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              FocusManager.instance.primaryFocus?.unfocus();

                              handleBooking();
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
