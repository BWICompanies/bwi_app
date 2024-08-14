//nagigator runs .signIn method if the route is /signin and sends to correct page.
import 'package:flutter/material.dart';

class Credentials {
  final String email;
  final String password;

  Credentials(this.email, this.password);
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignIn;

  const SignInScreen({
    required this.onSignIn,
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Alt method
  //String _email;
  //String _password;
  //String _errorMessage = '';

  /*
  Future<void> submitForm() async {
    setState(() {
      _errorMessage = '';
    });
    bool result = await ProductstoreAuthScope.of<AuthProvider>(context, listen: false).login(_email, _password);
    if (result == false) {
      setState(() {
        _errorMessage = 'There was a problem with your credentials.';
      });
    }
  }

  //When form button clicked run this submitForm(); function onPressed
  //For simple validation can check out this example. https://github.com/unlikenesses/sanctum-flutter-app/blob/master/lib/login.dart
  */

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Card(
            child: Container(
              constraints: BoxConstraints.loose(const Size(600, 600)),
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logogreen.png', height: 85),
                  Text('Sign in',
                      style: Theme.of(context).textTheme.headlineMedium),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    controller: _emailController,
                    /*
                    onChanged: (text) {
                      setState(() {
                        _displayText = text;
                      });
                    },
                    */
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () async {
                        widget.onSignIn(Credentials(_emailController.value.text,
                            _passwordController.value.text));
                      },
                      child: const Text('Sign in',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
