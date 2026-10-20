import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_event.dart';
import 'package:nic_backlog/logic/auth/auth_state.dart';
import 'package:nic_backlog/presentation/auth/login_screen.dart';
import 'package:nic_backlog/utils/app_theme.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _registerFormKey,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: AppColors.secondary, width: 4),
                    left: BorderSide(color: AppColors.borderStrong, width: 2),
                    right: BorderSide(color: AppColors.borderStrong, width: 2),
                    bottom: BorderSide(color: AppColors.borderStrong, width: 2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "NEW MEMBER REGISTRATION",
                      style: AppTextStyles.overline,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "REGISTER",
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "JOIN NIC-BACKLOG EDITORIAL ARCHIVE",
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                      color: AppColors.borderStrong,
                      thickness: 2,
                      height: 2,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: "USERNAME",
                        hintText: "Minimum 4 characters",
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: "EMAIL",
                        hintText: "name@example.com",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please Input Email";
                        } else if (!value.contains("@")) {
                          return "Please input valid email format";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: "PASSWORD",
                        hintText: "Enter password",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please Input Password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _validatePasswordController,
                      obscureText: true,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: "RE-INPUT PASSWORD",
                        hintText: "Confirm password",
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
                    const SizedBox(height: 24),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        switch (state) {
                          case AuthInitial():
                          case AuthLoading():
                            break;
                          case AuthSuccess():
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "REGISTER BERHASIL! SILAKAN LOGIN.",
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          case AuthFailure(:final error):
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: AppColors.error,
                              ),
                            );
                        }
                      },
                      builder: (context, state) {
                        return switch (state) {
                          AuthLoading() => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          AuthInitial() ||
                          AuthSuccess() ||
                          AuthFailure() => ElevatedButton(
                            onPressed: () {
                              if (_registerFormKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  RegisterRequested(
                                    username: _usernameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            },
                            child: const Text("REGISTER"),
                          ),
                        };
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("BACK TO LOGIN"),
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
}
