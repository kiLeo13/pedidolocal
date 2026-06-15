import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.pageGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.mutedInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                label: 'Logo Pedido Local',
                child: Container(
                  width: 184,
                  height: 184,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.ink, width: 3),
                    color: AppConstants.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.ink.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flatware_rounded,
                          color: AppConstants.primaryGreen,
                          size: 42,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppConstants.darkGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(Routes.home),
                  child: const Text('Comecar agora'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
