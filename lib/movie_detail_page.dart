import 'package:flutter/material.dart';
import 'package:movies_watchlist/movie.dart';
import 'dart:io';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final Function(Movie) onUpdate;
  final Function() onDelete;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  void _toggleWatched() {
    setState(() {
      widget.movie.isWatched = !widget.movie.isWatched;
    });
    widget.onUpdate(widget.movie);
  }

  void _showRatingDialog() {
    double tempRating = widget.movie.rating;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text('Rate ${widget.movie.title}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < tempRating ? Icons.star : Icons.star_border,
                          color: Colors.red,
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
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.movie.rating = tempRating;
                    });
                    widget.onUpdate(widget.movie);
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.movie.imageUrl != null && widget.movie.imageUrl!.isNotEmpty)
                    Image.network(
                      widget.movie.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.movie, size: 100, color: Colors.grey),
                        );
                      },
                    )
                  else if (widget.movie.imagePath != null)
                    Image.file(
                      File(widget.movie.imagePath!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.movie, size: 100, color: Colors.grey),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.movie.isWatched ? Colors.red : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.movie.isWatched ? 'WATCHED' : 'NOT WATCHED',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.movie.publicRating > 0) ...[
                        const Icon(Icons.star, color: Colors.red, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.movie.publicRating.toStringAsFixed(1)}/10',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showRatingDialog,
                    child: Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.movie.rating ? Icons.star : Icons.star_border,
                          color: Colors.red,
                          size: 32,
                        );
                      }),
                    ),
                  ),
                  if (widget.movie.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleWatched,
                          icon: Icon(
                            widget.movie.isWatched ? Icons.check_circle : Icons.check_circle_outline,
                          ),
                          label: Text(
                            widget.movie.isWatched ? 'Mark as Unwatched' : 'Mark as Watched',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E1E),
                                title: const Text('Delete Movie'),
                                content: const Text('Are you sure you want to delete this movie?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      widget.onDelete();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete Movie'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
