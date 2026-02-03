import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const Lab8App());
}

class Lab8App extends StatelessWidget {
  const Lab8App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostListScreen(),
    );
  }
}

class Post {
  final int id;
  final String title;
  final String body;

  const Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Map<String, String> _defaultHeaders = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Android) Lab8',
  };

  String _trimBody(String body) {
    const maxLength = 120;
    if (body.length <= maxLength) {
      return body;
    }
    return '${body.substring(0, maxLength)}...';
  }

  Future<List<Post>> fetchPosts() async {
    try {
      final uri = Uri.parse('$baseUrl/posts');
      final response = await http.get(uri, headers: _defaultHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw HttpException(
        'HTTP ${response.statusCode}: ${_trimBody(response.body)}',
      );
    } on SocketException catch (e) {
      throw Exception('No internet / DNS error: ${e.message}');
    } on HttpException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<Post> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        ..._defaultHeaders,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'title': title, 'body': body, 'userId': 1}),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Failed to create post (${response.statusCode})');
  }
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = apiService.fetchPosts();
  }

  void _retry() {
    setState(() {
      futurePosts = apiService.fetchPosts();
    });
  }

  Future<void> _openCreatePostDialog() async {
    final created = await showDialog<Post>(
      context: context,
      builder: (dialogContext) {
        return _CreatePostDialog(apiService: apiService);
      },
    );
    if (!mounted || created == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created post #${created.id}')),
    );
    _retry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts'), centerTitle: true),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Something went wrong',
                      style: TextStyle(fontSize: 16),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text(post.id.toString())),
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePostDialog,
        icon: const Icon(Icons.add),
        label: const Text('POST'),
      ),
    );
  }
}

class _CreatePostDialog extends StatefulWidget {
  const _CreatePostDialog({required this.apiService});

  final ApiService apiService;

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final created = await widget.apiService.createPost(
        _titleController.text.trim(),
        _bodyController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(created);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Body is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
