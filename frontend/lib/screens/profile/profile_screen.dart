import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isAuthenticated = auth.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fullName ?? 'Cliente Pedido Local',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(user?.email ?? 'Entre para sincronizar seus pedidos.'),
            if (auth.isAdmin && isAuthenticated) ...[
              const SizedBox(height: AppConstants.spacingLg),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.adminProduct),
                icon: const Icon(Icons.add_business_outlined),
                label: const Text('Cadastrar produto'),
              ),
            ],
            const Spacer(),
            if (isAuthenticated)
              OutlinedButton.icon(
                onPressed: () => _logout(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sair'),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(Routes.login),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Entrar'),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.register),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Criar conta'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }
}
