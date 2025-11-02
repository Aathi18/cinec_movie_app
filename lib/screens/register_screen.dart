import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart'; // Ensure this path is correct

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Instance of FirebaseAuth and FirebaseFirestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _fullName = '';
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        // 1. Register user with Firebase Authentication
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email, 
          password: _password
        );

        // Ensure user is created before proceeding to Firestore
        if (userCredential.user != null) {
          final User user = userCredential.user!;
          
          // 2. Create UserModel instance
          final UserModel newUser = UserModel(
            uid: user.uid, 
            email: _email, 
            fullName: _fullName
          );
          
          // 3. Save additional profile data to Firestore 'users' collection
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

          // FIX: Guard BuildContext usage with a mounted check after an await.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration Successful! Please log in.'))
            );
            Navigator.of(context).pop(); // Go back to login screen
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists for that email.';
        } else {
          message = 'Registration failed: ${e.message}';
        }
        // FIX: Guard BuildContext usage with a mounted check after an await.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (e) {
        // Handle generic errors (e.g., network issues, Firestore write failures)
        // FIX: Guard BuildContext usage with a mounted check after an await.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unknown error occurred: $e')));
        }
      } finally {
        if(mounted) {
            setState(() => _isLoading = false);
        }
      }
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cinec Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Full Name Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter your full name' : null,
                  onSaved: (value) => _fullName = value!.trim(),
                ),
                const SizedBox(height: 16),
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
                  validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 30),
                // Registration Button or Loader
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.deepPurple)
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Register', style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}