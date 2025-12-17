import 'dart:io';
import 'package:flutter/material.dart';
import 'movie.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies Watchlist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MoviesWatchlistPage(),
    );
  }
}

class MoviesWatchlistPage extends StatefulWidget {
  const MoviesWatchlistPage({super.key});

  @override
  State<MoviesWatchlistPage> createState() => _MoviesWatchlistPageState();
}

class _MoviesWatchlistPageState extends State<MoviesWatchlistPage> {
  final List<Movie> _movies = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  String _filterStatus = 'all';
  double _minRating = 0.0;
  
  String _sortBy = 'dateAdded';
  bool _sortAscending = true;

  List<Movie> get _filteredMovies {
    var filtered = _movies.where((movie) {
      if (_searchQuery.isNotEmpty &&
          !movie.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      
      if (_filterStatus == 'watched' && !movie.isWatched) {
        return false;
      }
      if (_filterStatus == 'unwatched' && movie.isWatched) {
        return false;
      }
      
      if (movie.rating < _minRating) {
        return false;
      }
      
      return true;
    }).toList();
    
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'dateAdded':
        default:
          comparison = a.id.compareTo(b.id);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    return filtered;
  }

  void _addMovie(Movie movie) {
    setState(() {
      _movies.add(movie);
    });
  }

  void _toggleWatched(Movie movie) {
    setState(() {
      movie.isWatched = !movie.isWatched;
    });
  }

  void _updateRating(Movie movie, double rating) {
    setState(() {
      movie.rating = rating;
    });
  }

  void _deleteMovie(Movie movie) {
    setState(() {
      _movies.remove(movie);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Movies Watchlist'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All'),
                          ),
                          DropdownMenuItem(
                            value: 'watched',
                            child: Text('Watched'),
                          ),
                          DropdownMenuItem(
                            value: 'unwatched',
                            child: Text('Unwatched'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        value: _minRating,
                        decoration: const InputDecoration(
                          labelText: 'Min Rating',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0.0,
                            child: Text('Any'),
                          ),
                          DropdownMenuItem(
                            value: 1.0,
                            child: Text('1+ ★'),
                          ),
                          DropdownMenuItem(
                            value: 2.0,
                            child: Text('2+ ★'),
                          ),
                          DropdownMenuItem(
                            value: 3.0,
                            child: Text('3+ ★'),
                          ),
                          DropdownMenuItem(
                            value: 4.0,
                            child: Text('4+ ★'),
                          ),
                          DropdownMenuItem(
                            value: 5.0,
                            child: Text('5 ★'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _minRating = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'dateAdded',
                            child: Text('Date Added'),
                          ),
                          DropdownMenuItem(
                            value: 'title',
                            child: Text('Title'),
                          ),
                          DropdownMenuItem(
                            value: 'rating',
                            child: Text('Rating'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                      tooltip: _sortAscending ? 'Ascending' : 'Descending',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: _filteredMovies.isEmpty
                ? const Center(
                    child: Text('No movies yet. Add one!'),
                  )
                : ListView.builder(
                    itemCount: _filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _filteredMovies[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: movie.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(movie.imagePath!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.movie, size: 50),
                          title: Text(movie.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Rating: '),
                                  ...List.generate(5, (i) {
                                    return Icon(
                                      i < movie.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 16,
                                      color: Colors.amber,
                                    );
                                  }),
                                ],
                              ),
                              Text(
                                movie.isWatched ? 'Watched' : 'Not watched',
                                style: TextStyle(
                                  color: movie.isWatched
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  movie.isWatched
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: movie.isWatched
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () => _toggleWatched(movie),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => _deleteMovie(movie),
                              ),
                            ],
                          ),
                          onTap: () => _showRatingDialog(movie),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMovieDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMovieDialog() {
    final titleController = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Movie'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Movie Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePath!),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setDialogState(() {
                          imagePath = pickedFile.path;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      _addMovie(Movie(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        imagePath: imagePath,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRatingDialog(Movie movie) {
    double tempRating = movie.rating;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Rate ${movie.title}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < tempRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            tempRating = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _updateRating(movie, tempRating);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
