import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp(
    apiKey: 'putyou api key her',
  ));
}

class MyApp extends StatefulWidget {
  final String apiKey;

  const MyApp({super.key, required this.apiKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sentiment Analysis & Chat',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(
        apiKey: widget.apiKey,
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String apiKey;
  final VoidCallback toggleTheme;

  const HomePage({super.key, required this.apiKey, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const String _baseUrl =
      'https://honeybee-prime-supposedly.ngrok-free.app';

  static final List<Widget> _pages = [
    const HomeScreen(),
    const PredictSentimentScreen(baseUrl: _baseUrl),
    const AddCommentScreen(baseUrl: _baseUrl),
    const ViewCommentsScreen(baseUrl: _baseUrl),
    const ChatScreen(apiKey: 'AIzaSyDJGOnTagZ2tc3yxrV_cOI6_LGuZGfyGJk'),
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
        title: const Text(
          '🚀 Sentiment Analysis & Chat with Gemini',
          style: TextStyle(
            fontFamily: 'Orbitron', // Futuristic font
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
              color: Colors.black,
            ),
            onPressed: () {
              widget.toggleTheme(); // Call toggleTheme from MyApp
            },
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        selectedItemColor: Colors.blueAccent, // Set the color here
        unselectedItemColor:
            Colors.grey, // This will set the color for unselected items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied, size: 28),
            label: 'Predict Sentiment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_comment, size: 28),
            label: 'Add Comment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment, size: 28),
            label: 'View Comments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 28),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          Text(
            '🌌 Explore the Cosmos with Gemini',
            style: TextStyle(
              fontFamily: 'Orbitron', // Futuristic font
              fontSize: 26,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.blueAccent
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: Icon(Icons.star,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.blueAccent
                    : Colors.white),
            title: Text(
              '🔮 Predict the sentiment of a given comment',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.blueAccent
                    : Colors.white),
            title: Text(
              '➕ Add a new comment to the database',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.blueAccent
                    : Colors.white),
            title: Text(
              '📢 View all comments in the database with sentiment',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 100),
          Text(
            'To get started, please select an option from the navigation bar.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class PredictSentimentScreen extends StatefulWidget {
  final String baseUrl;

  const PredictSentimentScreen({super.key, required this.baseUrl});

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
            '🌟 Sentiment Predictor',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter a comment for sentiment analysis',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                maxLines: 5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _predictSentiment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '🔍 Predict Sentiment',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 16),
          if (_predictedLabel.isNotEmpty)
            Text(
              _predictedLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _predictedLabel == 'positive'
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
            ),
        ],
      ),
    );
  }
}

class AddCommentScreen extends StatefulWidget {
  final String baseUrl;

  const AddCommentScreen({super.key, required this.baseUrl});

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
          content: Text('🚀 Comment added successfully!'),
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
            '🌟 Add Comment to Database',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '🪐 Enter your comment',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '👤 Enter your name',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '➕ Add Comment',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewCommentsScreen extends StatefulWidget {
  final String baseUrl;

  const ViewCommentsScreen({super.key, required this.baseUrl});

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
        _positiveCount = _comments
            .where((comment) => comment.prediction == 'positive')
            .length;
        _negativeCount = _comments
            .where((comment) => comment.prediction == 'negative')
            .length;
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
          Text(
            '🚀 View Comments from Database',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.blueAccent
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retrieveComments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '🔄 Refresh Comments',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 16),
          Text('👍 Positive Comments: $_positiveCount',
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white)),
          Text('👎 Negative Comments: $_negativeCount',
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white)),
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

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (comment.prediction) {
      case 'positive':
        color = Colors.greenAccent;
        break;
      case 'negative':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.yellow;
    }
    return Card(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 ${comment.commenterName}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.blueAccent
                      : Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '💬 ${comment.commentText}',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
            ),
            const SizedBox(height: 8),
            Text('🚀 Sentiment: ${comment.prediction}',
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(
              '🕒 Time: ${comment.creationTime}',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String apiKey;

  const ChatScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GenerativeModel model;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize the generative model
    model = GenerativeModel(
      model: 'gemini-1.0-pro',
      apiKey: widget.apiKey,
    );
  }

  Future<String> generateContent(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text ?? 'No response'; // Handle nullable text
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.insert(0, {
        'role': 'user',
        'content': _controller.text
      }); // Insert message at the beginning
      _isLoading = true;
    });

    try {
      final response = await generateContent(_controller.text);
      setState(() {
        _messages.insert(0, {
          'role': 'bot',
          'content': response
        }); // Insert response at the beginning
      });
    } catch (e) {
      setState(() {
        _messages.insert(0, {
          'role': 'bot',
          'content': 'Error: $e'
        }); // Insert error message at the beginning
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    _controller.clear();
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Theme(
      data: ThemeData(
        colorScheme: const ColorScheme.light(), // Set light mode color scheme
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(color: Colors.black87), // Text color for light mode
          bodyMedium:
              TextStyle(color: Colors.black87), // Text color for light mode
        ),
      ),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUserMessage = message['role'] == 'user';
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Colors.grey.shade300
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: isUserMessage
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Text(
                                isUserMessage ? '' : '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor:
                                    isUserMessage ? Colors.blue : Colors.green,
                                maxRadius: 6,
                                minRadius: 0.1,
                                child: Text(
                                  isUserMessage ? '' : '',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (message['role'] == 'bot')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message['content']!.startsWith(
                                    '```')) // Check if message is code
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      HighlightView(
                                        message['content']!.replaceAll('```',
                                            ''), // Remove code block indicator
                                        language: 'dart',
                                        theme: monokaiSublimeTheme,
                                        padding: const EdgeInsets.all(8),
                                        textStyle: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => _copyToClipboard(
                                            message['content']!
                                                .replaceAll('```dart\n', '')
                                                .replaceAll('```',
                                                    '')), // Extract code content
                                        child: const Text('Copy Code'),
                                      ),
                                    ],
                                  )
                                else
                                  MarkdownBody(
                                    data: message[
                                        'content']!, // Display normal text
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(
                                          fontSize:
                                              14), // Style for normal text
                                    ),
                                  ),
                              ],
                            )
                          else
                            Text(
                              message['content']!,
                              style: const TextStyle(
                                  fontSize: 14), // Style for user messages
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message . . .',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintStyle: const TextStyle(color: Colors.black87),
                      ),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
