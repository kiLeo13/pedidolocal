import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          children: [
            Text(
              'Acesso do cliente',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty || !text.contains('@')) {
                  return 'Informe um e-mail valido.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Senha'),
              validator: (value) {
                if ((value ?? '').length < AppConstants.passwordMinLength) {
                  return 'Informe sua senha.';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            if (auth.error case final error?) ...[
              const SizedBox(height: AppConstants.spacingMd),
              Text(error, style: const TextStyle(color: AppConstants.danger)),
            ],
            const SizedBox(height: AppConstants.spacingLg),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
            TextButton(
              onPressed: auth.isLoading
                  ? null
                  : () => Navigator.of(context).pushNamed(Routes.register),
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.login(_emailController.text.trim(), _passwordController.text);
    if (!mounted || !auth.isAuthenticated) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }
}
