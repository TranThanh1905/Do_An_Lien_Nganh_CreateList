import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // thư viện dùng định dạng ngày tháng

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  var _firstName = '';
  var _lastName = '';
  var _birthdate = DateTime.now();
  var _gender = 'Male';

  bool isLoginPage = false;

  final _birthdateController = TextEditingController();

  @override
  void dispose() {
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _birthdateController.text = DateFormat('dd/MM/yyyy').format(_birthdate);
  }

  startAuthentication() {
    final validity = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (validity ?? false) {
      _formKey.currentState?.save();
      submitForm(_email, _password, _username, _firstName, _lastName,
          _birthdate, _gender);
    }
  }

  submitForm(String email, String password, String username, String firstName,
      String lastName, DateTime birthdate, String gender) async {
    final auth = FirebaseAuth.instance;
    try {
      late UserCredential authResult;
      if (isLoginPage) {
        authResult = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        showSuccessMessage(context, 'Login successful');
      } else {
        final existingUser =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        if (existingUser.isNotEmpty) {
          showFailureMessage(context,
              'This email is already in use. Please use a different email.');
          return;
        }

        authResult = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String uid = authResult.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': username,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'birthdate': birthdate,
          'gender': gender,
        });

        showSuccessMessage(context, 'Registration successful');
      }
    } catch (err) {
      print(err);
      String errorMessage = 'Authentication failed. Please try again.';
      if (err is FirebaseAuthException) {
        errorMessage = err.message!;
      } else if (err is FirebaseException) {
        errorMessage = err.message!;
      }
      showFailureMessage(context, errorMessage);
    }
  }

  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showFailureMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLoginPage) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            key: ValueKey('firstName'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _firstName = value!;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              labelText: "First Name",
                              labelStyle: GoogleFonts.roboto(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            key: ValueKey('lastName'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _lastName = value!;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              labelText: "Last Name",
                              labelStyle: GoogleFonts.roboto(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      readOnly: true, // Set readOnly to true
                      controller: _birthdateController, // Assign controller
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _birthdate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _birthdate = selectedDate;
                            _birthdateController.text =
                                DateFormat('dd/MM/yyyy').format(_birthdate);
                          });
                        }
                      },
                      key: ValueKey('birthdate'),
                      validator: (value) {
                        if (_birthdate == null) {
                          return 'Please select your birthdate';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        labelText: "Birthdate",
                        labelStyle: GoogleFonts.roboto(),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey('gender'),
                      value: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        labelText: "Gender",
                        labelStyle: GoogleFonts.roboto(),
                      ),
                      items: <String>['Male', 'Female', 'Other']
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Incorrect Email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      labelText: "Enter Email",
                      labelStyle: GoogleFonts.roboto(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    obscureText: true,
                    keyboardType: TextInputType.emailAddress,
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Incorrect Password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      labelText: "Enter Password",
                      labelStyle: GoogleFonts.roboto(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 70,
                    child: ElevatedButton(
                      child: isLoginPage
                          ? Text(
                              "LOGIN",
                              style: GoogleFonts.roboto(),
                            )
                          : Text("SIGN UP", style: GoogleFonts.roboto()),
                      onPressed: () {
                        startAuthentication();
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          isLoginPage = !isLoginPage;
                        });
                      },
                      child: isLoginPage
                          ? Text('Not a member? Sign up here',
                              style: TextStyle(
                                  decoration: TextDecoration.underline))
                          : Text('Already have an account? Login here',
                              style: TextStyle(
                                  decoration: TextDecoration.underline)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
