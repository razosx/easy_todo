import 'dart:async';

import 'package:easy_todo/features/auth/domain/usecases/check_username_available.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _UsernameStatus { idle, checking, available, taken }

class EmailSignInForm extends StatefulWidget {
  final bool isSignUp;

  const EmailSignInForm({super.key, this.isSignUp = false});

  @override
  State<EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _obscurePassword = true;
  _UsernameStatus _usernameStatus = _UsernameStatus.idle;
  Timer? _debounce;

  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim().toLowerCase();

    if (trimmed.length < 3 || !_usernameRegex.hasMatch(trimmed)) {
      setState(() => _usernameStatus = _UsernameStatus.idle);
      return;
    }

    setState(() => _usernameStatus = _UsernameStatus.checking);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final checkUseCase = context.read<CheckUsernameAvailable>();
      final result = await checkUseCase(trimmed);
      if (!mounted) return;
      result.fold(
        (_) => setState(() => _usernameStatus = _UsernameStatus.idle),
        (available) => setState(
          () => _usernameStatus = available
              ? _UsernameStatus.available
              : _UsernameStatus.taken,
        ),
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.isSignUp && _usernameStatus != _UsernameStatus.available) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (widget.isSignUp) {
      context.read<AuthBloc>().add(
        SignUpWithEmailRequested(
          email: email,
          password: password,
          name: _nameController.text.trim(),
          username: _usernameController.text.trim().toLowerCase(),
        ),
      );
    } else {
      context.read<AuthBloc>().add(
        SignInWithEmailRequested(email: email, password: password),
      );
    }
  }

  Widget _buildUsernameStatus(AppLocalizations l10n) {
    return switch (_usernameStatus) {
      _UsernameStatus.checking => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.usernameChecking,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      _UsernameStatus.available => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            l10n.usernameAvailable,
            style: const TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ),
      _UsernameStatus.taken => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            l10n.usernameTaken,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
      _UsernameStatus.idle => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final l10n = AppLocalizations.of(context)!;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSignUp) ...[
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.nameLabel,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.nameEmptyError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      onChanged: _onUsernameChanged,
                      decoration: InputDecoration(
                        labelText: l10n.usernameLabel,
                        prefixIcon: const Icon(Icons.alternate_email),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return l10n.usernameEmptyError;
                        if (v.length < 3) return l10n.usernameTooShortError;
                        if (!_usernameRegex.hasMatch(v)) {
                          return l10n.usernameInvalidError;
                        }
                        if (_usernameStatus == _UsernameStatus.taken) {
                          return l10n.usernameTaken;
                        }
                        return null;
                      },
                    ),
                    if (_usernameStatus != _UsernameStatus.idle)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: _buildUsernameStatus(l10n),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.emailEmptyError;
                  }
                  if (!value.contains('@')) {
                    return l10n.emailInvalidError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.passwordEmptyError;
                  }
                  if (value.length < 6) {
                    return l10n.passwordTooShortError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.isSignUp
                              ? l10n.signUpButton
                              : l10n.signInButton,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
