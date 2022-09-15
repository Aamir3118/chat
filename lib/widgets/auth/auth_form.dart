import 'dart:io';

import 'package:chat/widgets/picker/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);
  final bool isLoading;
  final void Function(String email, String password, String username,
      File image, bool isLogin, BuildContext ctx) submitFn;
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _UsernameFocus = FocusNode();
  final _PasswordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  File _userImageFile = File('');
  void _imgFun(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_userImageFile.path.isEmpty && !_isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Please pick an image."),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();

      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _userImageFile,
        _isLogin,
        context,
      );
      /*print(_userEmail);
      print(_userName);
      print(_userPassword);*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (!_isLogin) UserImagePicker(_imgFun),
                    TextFormField(
                      key: ValueKey('email'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter email.';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoration('Email address'),
                      onSaved: (value) {
                        _userEmail = value!;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if (!_isLogin)
                      TextFormField(
                        key: ValueKey('username'),
                        focusNode: !_isLogin ? _UsernameFocus : null,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Username.';
                          } else if (value.length < 3) {
                            return 'Please enter a valid0 Username.';
                          }
                          return null;
                        },
                        decoration: _decoration('Username'),
                        onSaved: (value) {
                          _userName = value!;
                        },
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      key: ValueKey('password'),
                      focusNode: _PasswordFocus,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Password.';
                        } else if (value.length < 7) {
                          return 'Password should be greater than 7.';
                        }
                        return null;
                      },
                      decoration: _decoration('Password'),
                      obscureText: true,
                      onSaved: (value) {
                        _userPassword = value!;
                      },
                    ),
                    SizedBox(height: 12),
                    if (widget.isLoading) CircularProgressIndicator(),
                    if (!widget.isLoading)
                      RaisedButton(
                        child: Text(_isLogin ? 'Login' : 'Signup'),
                        onPressed: _trySubmit,
                      ),
                    if (!widget.isLoading)
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        child: Text(_isLogin
                            ? 'Create new account'
                            : 'Already have an account?'),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(hintTexts) {
    return InputDecoration(
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          )),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          )),
      hintText: hintTexts,
    );
  }
}
