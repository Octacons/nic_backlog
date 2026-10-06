import 'package:flutter/material.dart';
import 'package:nic_backlog/ui/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registerFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _validatePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _registerFormKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Nic-BackLog",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Text("Register", style: TextStyle(fontSize: 20)),
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
                controller: _emailController,
                decoration: InputDecoration(label: Text("Email")),
                validator: (value) {
                  if (value == null || value.trim() == "") {
                    return "Please Input Email";
                  } else if (!value.contains("@")) {
                    return "Please input email format";
                  } else if (value.length > 4) {
                    return "Email cant lower than 4 characters";
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
              TextFormField(
                controller: _validatePasswordController,
                decoration: InputDecoration(label: Text("Re-Input Password")),
                validator: (value) {
                  if (value == null || value.trim() == "") {
                    return "Please Input Password";
                  } else if (_passwordController.text != value) {
                    return "Please Recheck again your password";
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
                      "You have the account? Login Here !",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_registerFormKey.currentState!.validate()) {}
                },
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
