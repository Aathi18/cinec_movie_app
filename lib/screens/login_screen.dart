import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
          // Attempt to sign in with timeout
          await _auth.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw FirebaseAuthException(
                code: 'timeout',
                message: 'Login request timed out. Please try again.',
              );
            },
          );
          
          // On successful login, navigate to home screen
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        // No BuildContext is used here, so no 'mounted' check is needed for the success case.
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          message = 'Invalid email or password.';
        } else {
          message = 'Login failed: ${e.message}';
        }
        // FIX: Guard BuildContext usage with a mounted check after an await.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (e) {
        // FIX: Guard BuildContext usage with a mounted check after an await.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(' Error : $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cinec Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Welcome to Cinec Booking',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                // Email Field
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
                  onSaved: (value) => _email = value!.trim(),
                ),
                const SizedBox(height: 16),
                // Password Field
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter your password' : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 30),
                // Login Button or Loader
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.deepPurple)
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Login', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _goToRegister,
                            child: const Text('Don\'t have an account? Register here.', style: TextStyle(color: Colors.lightBlue)),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}