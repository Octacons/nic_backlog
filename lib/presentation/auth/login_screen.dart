import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_event.dart';
import 'package:nic_backlog/logic/auth/auth_state.dart';
import 'package:nic_backlog/presentation/auth/register_screen.dart';
import 'package:nic_backlog/presentation/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              const Text(
                "Nic-BackLog",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const Text("Login", style: TextStyle(fontSize: 20)),
              TextFormField(
                controller: _usernameOrEmailController,
                decoration: const InputDecoration(
                  label: Text("Username/Email"),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please Input Username or Email";
                  } else if (value.trim().length < 4) {
                    return "Username or email cannot be less than 4 characters";
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: const Text(
                      "Doesn't have an account? Register Here !",
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
                          builder: (context) => const RegisterScreen(),
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
                        content: Text("Login Berhasil!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
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
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }

                  return ElevatedButton(
                    onPressed: () {
                      if (_loginFormKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          LoginRequested(
                            input: _usernameOrEmailController.text,
                            password: _passwordController.text,
                          ),
                        );
                      }
                    },
                    child: const Text("LOGIN"),
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
