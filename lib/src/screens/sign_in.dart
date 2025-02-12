//nagigator runs .signIn method if the route is /signin and sends to correct page.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

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

  final Uri forgotPasswordUrl =
      Uri.parse('https://www.bwicompanies.com/forgot-password');
  final signupUrl = Uri.parse('https://www.bwicompanies.com/register');
  final contactUsUrl = Uri.parse('https://www.bwicompanies.com/contact');

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
                    onSubmitted: (value) async {
                      widget.onSignIn(Credentials(_emailController.value.text,
                          _passwordController.value.text));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () async {
                        widget.onSignIn(Credentials(_emailController.value.text,
                            _passwordController.value.text));
                      },
                      child: const Text('SIGN IN',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style, // Use default text style
                        children: [
                          TextSpan(
                              text: 'Forgot your password? ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                              )),
                          TextSpan(
                            text: 'Reset it.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunchUrl(forgotPasswordUrl)) {
                                  await launchUrl(forgotPasswordUrl);
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style, // Use default text style
                        children: [
                          TextSpan(
                              text: 'Don\'t have an account?* ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                              )),
                          TextSpan(
                            text: 'Sign up.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunchUrl(signupUrl)) {
                                  await launchUrl(signupUrl);
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style, // Use default text style
                        children: [
                          TextSpan(
                              text:
                                  '*You will need to get an Account Number from us before you register a new account. To request an Account Number, ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                              )),
                          TextSpan(
                            text: 'Contact Us.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunchUrl(contactUsUrl)) {
                                  await launchUrl(contactUsUrl);
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
