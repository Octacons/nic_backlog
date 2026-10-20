import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_event.dart';
import 'package:nic_backlog/logic/auth/auth_state.dart';
import 'package:nic_backlog/presentation/auth/register_screen.dart';
import 'package:nic_backlog/presentation/home/home_screen.dart';
import 'package:nic_backlog/utils/app_theme.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _loginFormKey,
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
                      "GAMING ARCHIVE // VOL. 01",
                      style: AppTextStyles.overline,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "NIC-BACKLOG",
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "SIGN IN TO YOUR PERSONAL BACKLOG",
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
                      controller: _usernameOrEmailController,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: "USERNAME OR EMAIL",
                        hintText: "Enter username or email",
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
                                content: Text("LOGIN BERHASIL!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                              (route) => false,
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
                          ),
                        };
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text("CREATE AN ACCOUNT"),
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
