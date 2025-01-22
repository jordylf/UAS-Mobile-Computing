import 'dart:convert';

import 'package:bioskopin/screens/user/user_film_detail_screen.dart';
import 'package:bioskopin/utils/http.dart';
import 'package:bioskopin/widgets/card.dart';
import 'package:bioskopin/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class UserFilmListScreen extends StatefulWidget {
  const UserFilmListScreen({super.key});

  @override
  State<UserFilmListScreen> createState() => _UserFilmListScreenState();
}

class _UserFilmListScreenState extends State<UserFilmListScreen> {
  late Future<Map<String, dynamic>> films;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Film'),
      ),
      body: SafeArea(
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
            } else if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserFilmDetailScreen(
                              filmId: film['id'].toString(),
                            ),
                          ),
                        );
                      },
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

class CardFilm extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final Function() onTap;

  const CardFilm({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 180.0,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 180.0,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 180.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Lorem ipsum',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Lorem ipsum dolor sit amet consectetur adipisicing elit. Id, iste!',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
