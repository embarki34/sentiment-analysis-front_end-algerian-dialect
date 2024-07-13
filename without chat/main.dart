import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sentiment Analysis System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const String _baseUrl = 'https://honeybee-prime-supposedly.ngrok-free.app'; // Define _baseUrl here

  static final List<Widget> _pages = [
    const HomeScreen(),
    PredictSentimentScreen(baseUrl: _baseUrl), // Pass _baseUrl to PredictSentimentScreen
    AddCommentScreen(baseUrl: _baseUrl), // Pass _baseUrl to AddCommentScreen
    ViewCommentsScreen(baseUrl: _baseUrl), // Pass _baseUrl to ViewCommentsScreen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analysis System'),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
  items: <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.blue : Colors.grey), // Adjust color here
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.sentiment_satisfied, color: _selectedIndex == 1 ? Colors.blue : Colors.grey), // Adjust color here
      label: 'Predict Sentiment',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_comment, color: _selectedIndex == 2 ? Colors.blue : Colors.grey), // Adjust color here
      label: 'Add Comment',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.comment, color: _selectedIndex == 3 ? Colors.blue : Colors.grey), // Adjust color here
      label: 'View Comments',
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
),

    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // This will make the column take up minimum space
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 100),
            const Text('- 🔮 Predict the sentiment of a given comment'),
            const SizedBox(height: 25),
            const Text('- ➕ Add a new comment to the database'),
            const SizedBox(height: 25),
            const Text('- 📢 View all comments in the database with sentiment '),
            const SizedBox(height: 200),
            const Text('To get started, please select an option from the navigation bar.'),
          ],
        ),
      ),
    );
  }
}

class PredictSentimentScreen extends StatefulWidget {
  final String baseUrl;

  const PredictSentimentScreen({Key? key, required this.baseUrl}) : super(key: key);

  @override
  State<PredictSentimentScreen> createState() => _PredictSentimentScreenState();
}

class _PredictSentimentScreenState extends State<PredictSentimentScreen> {
  final TextEditingController _commentController = TextEditingController();
  String _predictedLabel = '';

  Future<void> _predictSentiment() async {
    final response = await http.post(
      Uri.parse('${widget.baseUrl}/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': _commentController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        _predictedLabel = result['prediction_label'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔮 Predict Sentiment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Enter a comment for sentiment analysis',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _predictSentiment,
            child: const Text('Predict 🔍'),
          ),
          const SizedBox(height: 16),
          if (_predictedLabel.isNotEmpty)
            Text(
              _predictedLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                         color: _predictedLabel == 'positive' ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}

class AddCommentScreen extends StatefulWidget {
  final String baseUrl;

  const AddCommentScreen({Key? key, required this.baseUrl}) : super(key: key);

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _addComment() async {
    final response = await http.post(
      Uri.parse('${widget.baseUrl}/add_comment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'comment_text': _commentController.text,
        'commenter_name': _nameController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully. 🎉'),
        ),
      );
      _commentController.clear();
      _nameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '➕ Add Comment to Database',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Enter a comment to add to the database',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addComment,
            child: const Text('Add Comment ✍️'),
          ),
        ],
      ),
    );
  }
}

class ViewCommentsScreen extends StatefulWidget {
  final String baseUrl;

  const ViewCommentsScreen({Key? key, required this.baseUrl}) : super(key: key);

  @override
  State<ViewCommentsScreen> createState() => _ViewCommentsScreenState();
}

class _ViewCommentsScreenState extends State<ViewCommentsScreen> {
  late List<Comment> _comments = [];
  late int _positiveCount = 0;
  late int _negativeCount = 0;

  @override
  void initState() {
    super.initState();
    _retrieveComments();
  }

  Future<void> _retrieveComments() async {
    final response = await http.get(Uri.parse('${widget.baseUrl}/comments'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        _comments = jsonData.map((data) => Comment.fromJson(data)).toList();
        _positiveCount = _comments.where((comment) => comment.prediction == 'positive').length;
        _negativeCount = _comments.where((comment) => comment.prediction == 'negative').length;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📢 View Comments from Database',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retrieveComments,
            child: const Text('Retrieve Comments 🔄'),
          ),
          const SizedBox(height: 16),
          Text('Positive Comments: $_positiveCount'),
          Text('Negative Comments: $_negativeCount'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return CommentCard(comment: comment);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Comment {
  final String commenterName;
  final String commentText;
  final String prediction;
  final String creationTime;

  Comment({
    required this.commenterName,
    required this.commentText,
    required this.prediction,
    required this.creationTime,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commenterName: json['commenter_name'],
      commentText: json['comment_text'],
      prediction: json['prediction'],
      creationTime: json['creation_time'],
    );
  }
}

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (comment.prediction) {
      case 'positive':
        color = Colors.green;
        break;
      case 'negative':
        color = Colors.red;
        break;
      default:
        color = Colors.yellow;
    }
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${comment.commenterName}'),
            Text('Comment: ${comment.commentText}'),
            Text('Sentiment: ${comment.prediction}'),
            Text('Time: ${comment.creationTime}'),
          ],
        ),
      ),
    );
  }
}
