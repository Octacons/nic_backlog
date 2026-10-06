import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _loginFormKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Nic-BackLog",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Text("Login", style: TextStyle(fontSize: 20)),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(label: Text("Username")),
                validator: (value) {
                  if (value == null || value.trim() == "") {
                    return "Please Input Username";
                  } else if (value.length > 4) {
                    return "Username cant lower than 4 characters";
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(label: Text("Password")),
                validator: (value) {
                  if (value == null || value.trim() == "") {
                    return "Please Input Password";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: Text(
                      "Doesnt have account? Register Here !",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_loginFormKey.currentState!.validate()) {}
                },
                child: Text("LOGIN"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
