import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  final int bookingId;
  const ReviewScreen({super.key, required this.bookingId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int    _rating  = 5;
  bool   _loading = false;
  bool   _done    = false;
  final  _commentCtrl = TextEditingController();

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.submitReview(
        bookingId: widget.bookingId,
        rating:    _rating,
        comment:   _commentCtrl.text.trim(),
      );
      if (!mounted) return;
      if (result.containsKey('review')) {
        setState(() => _done = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.toString())),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
        backgroundColor: const Color(0xFF4682B4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _done ? _successView() : _reviewForm(),
      ),
    );
  }

  Widget _reviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How was your experience?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        // Star rating
        const Text('Rating',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
            );
          }),
        ),
        Center(
          child: Text(
            ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][_rating],
            style: const TextStyle(color: Colors.grey),
          ),
        ),

        const SizedBox(height: 24),

        // Comment
        const Text('Comment (optional)',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _commentCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us about your experience...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4682B4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Submit Review',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _successView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 80),
          const SizedBox(height: 16),
          const Text('Review Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Thank you for your feedback',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4682B4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Back to Bookings'),
          ),
        ],
      ),
    );
  }
}
