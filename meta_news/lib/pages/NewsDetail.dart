import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewsDetail extends StatefulWidget {
  final dynamic article;
  const NewsDetail({Key? key, required this.article}) : super(key: key);

  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  bool isSaved = false;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email ?? 'unknown';
  }

  Future<void> saveArticle() async {
    try {
      await FirebaseFirestore.instance
          .collection(userEmail)
          .add(widget.article);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article Saved successfully')),
      );
      setState(() {
        isSaved = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article['title'] ?? 'News Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.article['title'] ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Author/Creator
              Text(
                (widget.article['creator'] is List)
                    ? (widget.article['creator'] as List).join(', ')
                    : (widget.article['creator'] ?? 'Unknown'),
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              // Published Date
              Text(
                widget.article['pubDate'] ?? 'Unknown Date',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16),

              // Description or Fallback for Missing Content
              Text(
                widget.article['description'] ??
                    'Full content not available in the free version. Please visit the source link below for more details.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Source Link
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Open Full Article'),
                onPressed: () async {
                  final url = widget.article['source_url'];
                  if (url != null && await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid or missing URL')),
                    );
                  }
                },
              ),
              SizedBox(height: 16),

              // Save Article Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      isSaved ? Colors.grey : Colors.green, // text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSaved ? null : saveArticle,
                child: Text(isSaved ? 'Article Saved' : 'Save Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
