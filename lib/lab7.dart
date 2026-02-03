import 'package:flutter/material.dart';

void main() {
  runApp(const SignupApp());
}

class SignupApp extends StatelessWidget {
  const SignupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const SignupScreen(),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String _fullName = '';
  String _email = '';
  String _password = '';

  bool _isCheckingEmail = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _validateRequired(value, 'Email');
    if (requiredError != null) {
      return requiredError;
    }
    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final requiredError = _validateRequired(value, 'Password');
    if (requiredError != null) {
      return requiredError;
    }
    final password = value!.trim();
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least 1 digit';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final requiredError = _validateRequired(value, 'Confirm password');
    if (requiredError != null) {
      return requiredError;
    }
    if (value != _password) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isCheckingEmail) {
      return;
    }
    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }

    if (!formState.validate()) {
      return;
    }

    formState.save();

    setState(() {
      _isCheckingEmail = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    final emailLower = _email.trim().toLowerCase();

    if (!mounted) {
      return;
    }

    if (emailLower.startsWith('taken')) {
      setState(() {
        _isCheckingEmail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This email is already taken.')),
      );
      return;
    }

    setState(() {
      _isCheckingEmail = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup successful for $_fullName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Signup'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Fill out the form to get started.'),
                const SizedBox(height: 24),
                TextFormField(
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateRequired(value, 'Full name'),
                  onSaved: (value) => _fullName = value!.trim(),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                  onSaved: (value) => _email = value!.trim(),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                  onSaved: (value) => _password = value!.trim(),
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_confirmFocus);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  focusNode: _confirmFocus,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isCheckingEmail ? null : _submit,
                  child: _isCheckingEmail
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
                if (_isCheckingEmail) ...[
                  const SizedBox(height: 12),
                  const Text('Checking email availability...'),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Tip: try an email starting with "taken" to see the async check.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
