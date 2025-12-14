import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // If approved → AuthLoggedOut (redirects to login)
          if (state is AuthLoggedOut) {
            Navigator.pushReplacementNamed(context, "/login");
          }

          // If rejected → show rejection message
          if (state is AuthRejected) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text("Registration Denied"),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }

          // If error
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            // Loading state
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Rejected state - show rejection message
            if (state is AuthRejected) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      child: const Text("Go to Login"),
                    ),
                  ],
                ),
              );
            }

            // Normal state (Pending Approval)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
                  const SizedBox(height: 20),
                  const Text(
                    "Your account is pending approval.\nPlease wait for the administrator.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    child: const Text("Refresh Status"),
                    onPressed: () {
                      context.read<AuthCubit>().checkStatus();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
