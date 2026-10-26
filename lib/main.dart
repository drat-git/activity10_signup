import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 🧓 Great-Grandparent
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack Club Signup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // 🔑 The Global Key - acts like a remote control for the form
  final _formKey = GlobalKey<FormState>();

  // 📝 Controllers to track what the user types
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _tipCategory = 'password_help';
  final Map<String, List<String>> _tips = {
    'password_help': [
      'Use a long password that you do not use for another account.',
      'A password manager can help you create and remember different passwords.',
      'Avoid using your name, birthday, or other easy-to-guess details in a password.',
    ],
  };
  int _nextTip = 0;
  bool _tipLoading = false;
  bool _tipError = false;
  String? _tip;

  Future<void> _getTip({bool testError = false}) async {
    if (_tipLoading) return;
    setState(() {
      _tipLoading = true;
      _tipError = false;
      _tip = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Tips only use the fixed category, never the form controllers.
    final tips = testError ? <String>[] : (_tips[_tipCategory] ?? <String>[]);
    setState(() {
      if (tips.isEmpty) {
        _tipError = true;
      } else {
        _tip = tips[_nextTip];
        _nextTip = (_nextTip + 1) % tips.length;
      }
      _tipLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👨 Parent
      appBar: AppBar(
        title: const Text('Snack Club'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // 👶 Child
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.cookie, color: Colors.purple, size: 36),
              const SizedBox(height: 8),
              const Text(
                'Join the Snack Club',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 👤 Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 📧 Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔒 Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 🚀 Sign Up Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demo signup complete — your form passed validation!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Text(
                'Local signup tips',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Preset demo content. No live AI model is called. '
                'Tips do not check or approve your signup.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _tipLoading ? null : () => _getTip(),
                child: const Text('Get a signup tip'),
              ),
              TextButton(
                onPressed: _tipLoading ? null : () => _getTip(testError: true),
                child: const Text('Test tip error'),
              ),
              if (_tipLoading) ...[
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
                const Text('Loading demo tip...'),
              ],
              if (_tip != null) ...[
                const SizedBox(height: 12),
                Text(_tip!, key: const Key('tipText')),
              ],
              if (_tipError) ...[
                const SizedBox(height: 12),
                const Text(
                  'Demo tip could not load. Tap Retry to try again.',
                  style: TextStyle(color: Colors.red),
                ),
                OutlinedButton(
                  onPressed: () => _getTip(),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
