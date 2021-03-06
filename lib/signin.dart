import 'package:allewellyn4fanpage0/auth_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'register.dart';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignIn();
}

class _SignIn extends State<SignInPage> {
  // const SignInPage({ Key? key }) : super(key: key);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((fbUser) {
      if (fbUser != null) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
        body: _loading
            ? LoadingPage()
            : Center(
                child: Form(
                    key: _formKey,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Andrew Llewellyn Fans",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Username or Email',
                                ),
                                controller: _email,
                                validator: (String? text) {
                                  if (text == null || text.isEmpty) {
                                    return "your email can't be empty";
                                  } else if (!text.contains('@')) {
                                    return "please enter valid email";
                                  }
                                })),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Password',
                                ),
                                controller: _password,
                                validator: (String? text) {
                                  if (text == null || text.length < 6) {
                                    return "Your password cant be empty";
                                  }
                                  return null;
                                })),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              logIn(context);
                            });
                          },
                          child: const Text("Log In"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RegisterPage()));
                          },
                          child: const Text("Register"),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          icon: FaIcon(FontAwesomeIcons.google),
                          label: Text('Sign in with Google'),
                          onPressed: () => authBloc.loginGoogle(),

                          //child: const Text("Log in with Google"),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password"),
                        ),
                      ],
                    )))));
  }

  void logIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: _email.text, password: _password.text);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "wrong-password" || e.code == "no-email") {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Incorrect email/password")));
        } else {
          setState(() {
            _loading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
