import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () => context.read<AuthBloc>().add(SignInWithGoogleRequested()),
          icon: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.g_mobiledata_rounded, size: 28),
          label: Text(AppLocalizations.of(context)!.continueWithGoogle),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      },
    );
  }
}
