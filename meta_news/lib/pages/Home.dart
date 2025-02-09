import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'NewsDetail.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase import
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<dynamic> articles = [];
  List<String> categories = [
    'general',
    'sports',
    'technology',
    'politics',
    'business',
    'breaking',
  ];
  String selectedCategory = 'general'; // Default category
  late TabController _tabController;

  final CacheManager cacheManager = CacheManager(
    Config(
      'newsCache',
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 50,
    ),
  );

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    fetchNews();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedCategory = categories[_tabController.index];
          fetchNews();
        });
      }
    });
  }

  Future<void> fetchNews() async {
    const String apiKey = 'pub_629653854ea62a0322f7f405196b655ce5b7b';
    const String apiUrl = 'https://newsdata.io/api/1/news';

    try {
      // Check if the category is "breaking" (fetch fresh data)
      if (selectedCategory == 'breaking') {
        await fetchFreshNews(apiUrl, apiKey);
        return;
      }

      // Try to get cached data
      final cachedFile = await cacheManager.getFileFromCache(selectedCategory);

      if (cachedFile != null) {
        // Use cached data
        final cachedData = json.decode(await cachedFile.file.readAsString());
        setState(() {
          articles = cachedData['results'] ?? [];
        });
      } else {
        // If no cached data, fetch fresh data and cache it
        await fetchFreshNews(apiUrl, apiKey);
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  Future<void> fetchFreshNews(String apiUrl, String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?apiKey=$apiKey&category=$selectedCategory&language=en'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data['results'] ?? [];
        });

        if (selectedCategory != 'breaking') {
          await cacheManager.putFile(
            selectedCategory,
            response.bodyBytes,
            fileExtension: '.json',
          );
        }
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print("Error fetching fresh news: $e");
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/Login');
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Future<void> _manageAccount() async {
    Navigator.pushNamed(context, '/AccountSettings');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getBackgroundImageForCategory(String category) {
    switch (category) {
      case 'general':
        return 'images/general.png';
      case 'sports':
        return 'images/sports.jpg';
      case 'technology':
        return 'images/technology.jpg';
      case 'politics':
        return 'images/politics.png';
      case 'business':
        return 'images/business.png';
      case 'breaking':
        return 'images/breaking-news.png';
      default:
        return 'images/general.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "META News",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 4.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage(getBackgroundImageForCategory(selectedCategory)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(221, 8, 8, 8),
        iconTheme: IconThemeData(
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 4.0,
              color: Colors.black,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Logout button
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _manageAccount, // Manage account button
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              labelStyle: GoogleFonts.lato(
                textStyle: TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              unselectedLabelColor: Colors.lightBlue[200],
              unselectedLabelStyle: GoogleFonts.lato(
                textStyle: TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              indicatorColor: Colors.white,
              tabs: categories
                  .map((String category) => Tab(
                        text: category.capitalize(),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((String category) {
          return Container(
            child: articles.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ListTile(
                        leading: article['image_url'] != null &&
                                article['image_url'].isNotEmpty
                            ? Image.network(
                                article['image_url'],
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.broken_image,
                                        size: 50, color: Colors.grey),
                              )
                            : Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                        title: Text(
                          article['title'] ?? 'No Title',
                          style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          article['description'] ?? 'No Description',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetail(article: article),
                            ),
                          );
                        },
                      );
                    },
                  ),
          );
        }).toList(),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
