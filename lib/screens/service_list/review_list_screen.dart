import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/review/db_review.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({
    Key? key,
    required this.placeId,
    required this.serviceId,
  }) : super(key: key);

  final String placeId;
  final String serviceId;

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  Stream<QuerySnapshot<DbReview>>? reviewListStream;

  @override
  void initState() {
    reviewListStream = FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .collection('services')
        .doc(widget.serviceId)
        .collection('reviews')
        .withConverter<DbReview>(
          fromFirestore: (snapshot, _) => DbReview.fromJson(snapshot.data()!),
          toFirestore: (review, _) => review.toJson(),
        )
        .orderBy('created_at', descending: true)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: AppBar(title: Text('Ratings & Reviews')),
      body: SafeArea(
        child: Center(
          child: Material(
            child: StreamBuilder<QuerySnapshot<DbReview>>(
              stream: reviewListStream!,
              builder: (_, snapshot) {
                if (snapshot.hasError)
                  return const Text('Something went wrong');

                if (snapshot.connectionState == ConnectionState.waiting)
                  return const CircularProgressIndicator.adaptive();

                final reviewList = snapshot.data?.docs ?? [];
                if (reviewList.isEmpty)
                  return const Text('No reviews are found');
                return Scrollbar(child: _ReviewListView(reviewList: reviewList));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewListView extends StatelessWidget {
  const _ReviewListView({
    Key? key,
    required this.reviewList,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<DbReview>> reviewList;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: reviewList.length,
      itemBuilder: (_, index) {
        final reviewData = reviewList[index].data();
        return ListTile(
          key: ValueKey(reviewList[index].id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: const Icon(Icons.account_circle),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reviewData.creatorName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Row(
                children: [
                  RatingBarIndicator(
                    rating: reviewData.rating,
                    itemCount: 5,
                    itemSize: 10,
                    itemBuilder: (_, __) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${reviewData.rating}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              )
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reviewData.text != null) Text(reviewData.text!),
              const SizedBox(height: 8),
              Text(DateFormat('dd-MM-yyyy HH:mm').format(
                reviewData.createdAt.toDate(),
              ))
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}
