import 'package:flutter/material.dart';
import '../models/architect_profile.dart';
import 'wallet_helpers.dart';

/// Dart port of the Kotlin `RateAndReviewDialog`. Shown to a client once a
/// project is complete, producing a [Review] appended to the architect's
/// public profile.
class RateAndReviewDialog extends StatefulWidget {
  const RateAndReviewDialog({
    super.key,
    required this.projectTitle,
    required this.clientName,
  });

  final String projectTitle;
  final String clientName;

  @override
  State<RateAndReviewDialog> createState() => _RateAndReviewDialogState();
}

class _RateAndReviewDialogState extends State<RateAndReviewDialog> {
  int _rating = 5;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate & Review Architect', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${widget.projectTitle}', style: const TextStyle(fontSize: 12, color: slateMuted)),
            const SizedBox(height: 8),
            Text('Overall Rating ($_rating/5)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Icons.star : Icons.star_border,
                    color: star <= _rating ? safariGold : slateMuted,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your Review / Feedback',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kenyaGreenPrimary)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel', style: TextStyle(color: slateMuted))),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kenyaGreenPrimary),
          onPressed: () => Navigator.of(context).pop(Review(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            clientName: widget.clientName,
            rating: _rating.toDouble(),
            comment: _reviewController.text.trim().isEmpty ? 'No written feedback provided.' : _reviewController.text.trim(),
            date: DateTime.now(),
          )),
          child: const Text('Submit Review'),
        ),
      ],
    );
  }
}