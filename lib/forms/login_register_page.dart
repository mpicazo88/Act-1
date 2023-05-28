import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage;
  bool isLogin = true;
  bool isPasswordVisible = false;

  final TextEditingController _conEmail = TextEditingController();
  final TextEditingController _conPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _conEmail.text,
        password: _conPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _conEmail.text,
        password: _conPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        final credential = FacebookAuthProvider.credential(accessToken!.token);

        await FirebaseAuth.instance.signInWithCredential(credential);

        // User logged in successfully
        // Navigate to the home screen or perform any other actions
        print('User logged in with Facebook');
      } else if (result.status == LoginStatus.cancelled) {
        // Handle the case when the user cancels the Facebook login process
        print('Facebook login cancelled');
      } else {
        // Handle the case when the Facebook login fails
        setState(() {
          errorMessage = 'An error occurred during Facebook login.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred during Facebook login: $e';
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // User logged in successfully
      // Navigate to the home screen or perform any other actions
      print('User logged in with Google');
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred during Google login: $e';
      });
    }
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _entryField(String title, TextEditingController con, bool isPassword) {
    return TextField(
      controller: con,
      obscureText: isPassword ? !isPasswordVisible : false,
      decoration: InputDecoration(
        labelText: title,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _errorMessage() {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return SizedBox.shrink();
    }

    return Text(
      errorMessage!,
      style: TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          errorMessage = null; // Reset error message when switching between login and register
        });
      },
      child: Text(isLogin ? 'Register' : 'Login Instead'),
    );
  }

  Widget _facebookLoginButton() {
    return ElevatedButton(
      onPressed: signInWithFacebook,
      child: Text('Login with Facebook'),
    );
  }

  Widget _googleLoginButton() {
    return ElevatedButton(
      onPressed: signInWithGoogle,
      child: Text('Login with Google'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255), // Set the background color
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _entryField('Email', _conEmail, false),
            SizedBox(height: 10), // Add spacing between email and password fields
            _entryField('Password', _conPassword, true),
            SizedBox(height: 10), // Add spacing between password and error message
            _errorMessage(),
            SizedBox(height: 10), // Add spacing between error message and submit button
            _submitButton(),
            SizedBox(height: 10), // Add spacing between submit button and login/register button
            _loginOrRegisterButton(),
            SizedBox(height: 10), // Add spacing between login/register button and social login buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _facebookLoginButton(),
                SizedBox(width: 10), // Add spacing between Facebook and Google login buttons
                _googleLoginButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
