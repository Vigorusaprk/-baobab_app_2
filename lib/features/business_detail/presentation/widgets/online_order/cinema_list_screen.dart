import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/movie.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/movie_api_service.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'movie_detail_screen.dart';

class CinemaListScreen extends StatefulWidget {
  final Business cinema;
  const CinemaListScreen({super.key, required this.cinema});

  @override
  State<CinemaListScreen> createState() => _CinemaListScreenState();
}

class _CinemaListScreenState extends State<CinemaListScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final service = MovieApiService();
    try {
      final movies = await service.getMoviesByCinema(widget.cinema.id);
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.cinema.name,
          style: const TextStyle(color: AppColors.scaffoldBackground),
        ),
        backgroundColor: AppColors.primary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur : $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMovies,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _movies.isEmpty
          ? const Center(child: Text('Aucun film disponible'))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(
                    cinema: widget.cinema,
                    movie: movie,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: movie.posterUrl != null
                          ? Image.network(
                        movie.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 40),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 40),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (movie.genre != null)
                            Text(
                              movie.genre!,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                movie.rating.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}