import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_event.dart';
import 'package:nic_backlog/logic/auth/auth_state.dart';
import 'package:nic_backlog/presentation/auth/login_screen.dart';

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
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _validatePasswordController.dispose();
    super.dispose();
  }

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
              const Text(
                "Nic-BackLog",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const Text("Register", style: TextStyle(fontSize: 20)),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(label: Text("Username")),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please Input Username";
                  } else if (value.trim().length < 4) {
                    // Disesuaikan minimal 4 karakter
                    return "Username cannot be less than 4 characters";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(label: Text("Email")),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please Input Email";
                  } else if (!value.contains("@")) {
                    return "Please input valid email format";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(label: Text("Password")),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please Input Password";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _validatePasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text("Re-Input Password"),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please Input Password";
                  } else if (_passwordController.text != value) {
                    return "Please recheck your password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: const Text(
                      "You have an account? Login Here !",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Register Berhasil! Silakan Login."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // Rebuild UI sesuai State
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }

                  return ElevatedButton(
                    onPressed: () {
                      if (_registerFormKey.currentState!.validate()) {
                        // KIRIM EVENT KE BLOC
                        context.read<AuthBloc>().add(
                          RegisterRequested(
                            username: _usernameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                      }
                    },
                    child: const Text("Register"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
