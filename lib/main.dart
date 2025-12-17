import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'movie.dart';
import 'tmdb_service.dart';
import 'movie_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies Watchlist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.red,
        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.red,
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
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
  String _sortBy = 'dateAdded';
  bool _sortAscending = false;
  bool _showFilters = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final moviesJson = prefs.getString('movies');
    
    if (moviesJson != null) {
      final List<dynamic> decoded = json.decode(moviesJson);
      setState(() {
        _movies.clear();
        _movies.addAll(decoded.map((m) => Movie.fromJson(m)).toList());
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final moviesJson = json.encode(_movies.map((m) => m.toJson()).toList());
    await prefs.setString('movies', moviesJson);
  }

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
        case 'publicRating':
          comparison = a.publicRating.compareTo(b.publicRating);
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
    _saveMovies();
  }

  void _updateMovie(Movie movie) {
    setState(() {});
    _saveMovies();
  }

  void _deleteMovie(Movie movie) {
    setState(() {
      _movies.remove(movie);
    });
    _saveMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movies Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _showFilters ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search your movies...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sort, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Sort by:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _sortAscending = !_sortAscending;
                          });
                        },
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSortChip('Date Added', 'dateAdded'),
                        _buildSortChip('Title', 'title'),
                        _buildSortChip('Your Rating', 'rating'),
                        _buildSortChip('Public Rating', 'publicRating'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.filter_alt, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        _buildFilterChip('Watched', 'watched'),
                        _buildFilterChip('Unwatched', 'unwatched'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                : _filteredMovies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              size: 100,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _movies.isEmpty
                                  ? 'No movies yet.\nTap + to add one!'
                                  : 'No movies found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _filteredMovies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailPage(
                                movie: movie,
                                onUpdate: _updateMovie,
                                onDelete: () => _deleteMovie(movie),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (movie.imageUrl != null && movie.imageUrl!.isNotEmpty)
                                      Image.network(
                                        movie.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[900],
                                            child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                                          );
                                        },
                                      )
                                    else if (movie.imagePath != null)
                                      Image.file(
                                        File(movie.imagePath!),
                                        fit: BoxFit.cover,
                                      )
                                    else
                                      Container(
                                        color: Colors.grey[900],
                                        child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                                      ),
                                    if (movie.isWatched)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
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
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (movie.rating > 0) ...[
                                            const Icon(Icons.star, color: Colors.red, size: 14),
                                            const SizedBox(width: 2),
                                            Text(
                                              movie.rating.toStringAsFixed(1),
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                          if (movie.publicRating > 0) ...[
                                            if (movie.rating > 0) const SizedBox(width: 8),
                                            Icon(Icons.public, color: Colors.grey[600], size: 14),
                                            const SizedBox(width: 2),
                                            Text(
                                              movie.publicRating.toStringAsFixed(1),
                                              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                            ),
                                          ],
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMovieOptions(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMovieOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.search, color: Colors.red),
                  ),
                  title: const Text('Search Online Database'),
                  subtitle: const Text('Find movies from TMDB'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSearchDialog();
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.red),
                  ),
                  title: const Text('Add Manually'),
                  subtitle: const Text('Create a custom movie entry'),
                  onTap: () {
                    Navigator.pop(context);
                    _showManualAddDialog();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Search Movies'),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter movie name...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          setDialogState(() {
                            isLoading = true;
                          });
                          final results = await TMDBService.searchMovies(value);
                          setDialogState(() {
                            searchResults = results;
                            isLoading = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.red))
                          : searchResults.isEmpty
                              ? Center(
                                  child: Text(
                                    'Search for movies',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final result = searchResults[index];
                                    final posterPath = result['poster_path'];
                                    final imageUrl = posterPath != null
                                        ? TMDBService.getImageUrl(posterPath)
                                        : null;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: imageUrl != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 50,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 50,
                                                      height: 75,
                                                      color: Colors.grey[800],
                                                      child: const Icon(Icons.movie, size: 30),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container(
                                                width: 50,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[800],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Icon(Icons.movie, size: 30),
                                              ),
                                        title: Text(
                                          result['title'] ?? 'Unknown',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          result['release_date'].length >= 4 ? result['release_date']?.substring(0, 4) ?? '' : '',
                                          style: TextStyle(color: Colors.grey[400]),
                                        ),
                                        trailing: const Icon(Icons.add, color: Colors.red),
                                        onTap: () {
                                          _addMovie(Movie(
                                            id: DateTime.now().toString(),
                                            title: result['title'] ?? 'Unknown',
                                            imageUrl: imageUrl,
                                            description: result['overview'] ?? '',
                                            publicRating: (result['vote_average'] ?? 0.0).toDouble(),
                                          ));
                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManualAddDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? imagePath;
    double publicRating = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Add Movie Manually'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Movie Title *',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Public Rating: '),
                        Expanded(
                          child: Slider(
                            value: publicRating,
                            min: 0,
                            max: 10,
                            divisions: 100,
                            activeColor: Colors.red,
                            label: publicRating.toStringAsFixed(1),
                            onChanged: (value) {
                              setDialogState(() {
                                publicRating = value;
                              });
                            },
                          ),
                        ),
                        Text(publicRating.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imagePath!),
                          height: 150,
                          width: double.infinity,
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
                      label: Text(imagePath == null ? 'Pick Image' : 'Change Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      _addMovie(Movie(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        imagePath: imagePath,
                        description: descriptionController.text,
                        publicRating: publicRating,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _sortBy = value;
          });
        },
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: Colors.red.withOpacity(0.3),
        checkmarkColor: Colors.red,
        labelStyle: TextStyle(
          color: isSelected ? Colors.red : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? Colors.red : Colors.grey[800]!,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = value;
          });
        },
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: Colors.red.withOpacity(0.3),
        checkmarkColor: Colors.red,
        labelStyle: TextStyle(
          color: isSelected ? Colors.red : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? Colors.red : Colors.grey[800]!,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
