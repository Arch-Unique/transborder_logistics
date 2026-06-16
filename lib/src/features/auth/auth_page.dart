import 'dart:math';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/auth/controllers/auth_controller.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_textfield.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transborder_logistics/src/global/ui/widgets/text/app_text.dart';

import '../../app/app_barrel.dart';
import '../../utils/utils_barrel.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Ui.isBigScreen(context)
        ? _DesktopLogin(controller: controller)
        : _MobileLogin(controller: controller);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop Login
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLogin extends StatelessWidget {
  const _DesktopLogin({required this.controller});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left — animated branding panel
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                // Red background
                Container(color: AppColors.primaryColor),

                // Nigeria map silhouette + road network
                const Positioned.fill(child: _NigeriaMapBackground()),

                // Animated trucks
                const Positioned.fill(child: _AnimatedTrucks()),

                // Content overlay
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(Assets.fulllogo, width: 140),
                        ),
                        const Spacer(),

                        // Tagline
                        AppText.bold(
                          'Delivering\nExcellence\nAcross Borders',
                          fontSize: 38,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        AppText.thin(
                          'Real-time logistics management\nfor modern supply chains.',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        const SizedBox(height: 32),

                        // Stats row
                        Row(
                          children: [
                            _StatBadge(label: 'Trips', value: '2K+'),
                            const SizedBox(width: 28),
                            _StatBadge(label: 'Locations', value: '500+'),
                            const SizedBox(width: 28),
                            _StatBadge(label: 'Drivers', value: '50+'),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right — login form
          Expanded(
            flex: 4,
            child: Container(
              color: AppColors.primaryColorBackground,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold('Welcome back', fontSize: 32),
                        const SizedBox(height: 8),
                        AppText.thin(
                          'Sign in to your account to continue',
                          fontSize: 14,
                          color: AppColors.lightTextColor,
                        ),
                        const SizedBox(height: 40),
                        _LoginForm(controller: controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile Login
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLogin extends StatelessWidget {
  const _MobileLogin({required this.controller});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          SizedBox(
            height: Ui.height(context) * 0.42,
            child: Stack(
              children: [
                Container(color: AppColors.primaryColor),
                const Positioned.fill(child: _NigeriaMapBackground()),
                const Positioned.fill(child: _AnimatedTrucks()),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Image.asset(Assets.fulllogo, width: 120),
                      const SizedBox(height: 8),
                      AppText.thin(
                        'Precise. Progressive. People.',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),

                // Form card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColorBackground,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          AppText.bold('Welcome back', fontSize: 26),
                          const SizedBox(height: 6),
                          AppText.thin(
                            'Sign in to continue',
                            fontSize: 13,
                            color: AppColors.lightTextColor,
                          ),
                          const SizedBox(height: 32),
                          _LoginForm(controller: controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nigeria Map Background (SVG-style road network painted)
// ─────────────────────────────────────────────────────────────────────────────

class _NigeriaMapBackground extends StatelessWidget {
  const _NigeriaMapBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NigeriaMapPainter(),
    );
  }
}

class _NigeriaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Nigeria silhouette — simplified outline
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Simplified Nigeria shape path
    final path = Path();
    path.moveTo(w * 0.15, h * 0.35);
    path.cubicTo(w * 0.1, h * 0.25, w * 0.18, h * 0.15, w * 0.28, h * 0.12);
    path.cubicTo(w * 0.38, h * 0.08, w * 0.5, h * 0.06, w * 0.6, h * 0.1);
    path.cubicTo(w * 0.72, h * 0.12, w * 0.82, h * 0.18, w * 0.88, h * 0.28);
    path.cubicTo(w * 0.94, h * 0.38, w * 0.92, h * 0.5, w * 0.88, h * 0.6);
    path.cubicTo(w * 0.84, h * 0.7, w * 0.78, h * 0.78, w * 0.68, h * 0.82);
    path.cubicTo(w * 0.58, h * 0.88, w * 0.5, h * 0.92, w * 0.42, h * 0.9);
    path.cubicTo(w * 0.32, h * 0.88, w * 0.22, h * 0.8, w * 0.16, h * 0.7);
    path.cubicTo(w * 0.1, h * 0.6, w * 0.12, h * 0.48, w * 0.15, h * 0.35);
    path.close();

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);

    // Road network lines
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Major roads (simplified Nigerian highway network)
    final roads = [
      // Lagos - Ibadan - Abuja
      [Offset(w * 0.3, h * 0.78), Offset(w * 0.35, h * 0.65), Offset(w * 0.45, h * 0.55), Offset(w * 0.5, h * 0.45)],
      // Abuja - Kaduna - Kano
      [Offset(w * 0.5, h * 0.45), Offset(w * 0.52, h * 0.35), Offset(w * 0.55, h * 0.22), Offset(w * 0.58, h * 0.15)],
      // Port Harcourt - Enugu - Abuja
      [Offset(w * 0.65, h * 0.78), Offset(w * 0.6, h * 0.65), Offset(w * 0.55, h * 0.55), Offset(w * 0.5, h * 0.45)],
      // Kano - Maiduguri
      [Offset(w * 0.58, h * 0.15), Offset(w * 0.68, h * 0.18), Offset(w * 0.78, h * 0.22)],
      // Lagos - Benin - PH
      [Offset(w * 0.3, h * 0.78), Offset(w * 0.45, h * 0.8), Offset(w * 0.55, h * 0.78), Offset(w * 0.65, h * 0.78)],
      // Cross roads
      [Offset(w * 0.25, h * 0.5), Offset(w * 0.5, h * 0.45), Offset(w * 0.75, h * 0.5)],
    ];

    for (final road in roads) {
      final roadPath = Path();
      roadPath.moveTo(road.first.dx, road.first.dy);
      for (int i = 1; i < road.length; i++) {
        roadPath.lineTo(road[i].dx, road[i].dy);
      }
      canvas.drawPath(roadPath, roadPaint);
    }

    // City dots
    final cityPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final cities = [
      Offset(w * 0.3, h * 0.78),   // Lagos
      Offset(w * 0.5, h * 0.45),   // Abuja
      Offset(w * 0.58, h * 0.15),  // Kano
      Offset(w * 0.65, h * 0.78),  // Port Harcourt
      Offset(w * 0.52, h * 0.35),  // Kaduna
      Offset(w * 0.78, h * 0.22),  // Maiduguri
      Offset(w * 0.35, h * 0.65),  // Ibadan
    ];

    for (final city in cities) {
      canvas.drawCircle(city, 3, cityPaint);
      canvas.drawCircle(city, 6, cityPaint..color = Colors.white.withOpacity(0.1));
    }
  }

  @override
  bool shouldRepaint(_NigeriaMapPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Trucks moving across the map
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedTrucks extends StatefulWidget {
  const _AnimatedTrucks();

  @override
  State<_AnimatedTrucks> createState() => _AnimatedTrucksState();
}

class _AnimatedTrucksState extends State<_AnimatedTrucks>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  // Each truck has a route defined as a list of waypoints (dx, dy as fractions)
  static final _routes = [
    // Truck 1: Lagos → Abuja → Kano (main north route)
    [
      Offset(0.3, 0.78), Offset(0.35, 0.65), Offset(0.45, 0.55),
      Offset(0.5, 0.45), Offset(0.52, 0.35), Offset(0.55, 0.22), Offset(0.58, 0.15),
    ],
    // Truck 2: Port Harcourt → Abuja
    [
      Offset(0.65, 0.78), Offset(0.6, 0.65), Offset(0.55, 0.55), Offset(0.5, 0.45),
    ],
    // Truck 3: Lagos → Ibadan → cross
    [
      Offset(0.15, 0.72), Offset(0.25, 0.68), Offset(0.35, 0.65), Offset(0.45, 0.6),
    ],
    // Truck 4: Kano → Maiduguri
    [
      Offset(0.58, 0.15), Offset(0.65, 0.17), Offset(0.72, 0.19), Offset(0.78, 0.22),
    ],
    // Truck 5: Abuja → Kaduna
    [
      Offset(0.5, 0.45), Offset(0.51, 0.38), Offset(0.52, 0.32), Offset(0.53, 0.26),
    ],
  ];

  static const _speeds = [8000, 10000, 7000, 9000, 11000];
  static const _delays = [0, 2000, 4000, 1500, 3500];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_routes.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _speeds[i]),
      );
    });

    _animations = _controllers.map((c) =>
      CurvedAnimation(parent: c, curve: Curves.linear)
    ).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: _delays[i]), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Offset _interpolateRoute(List<Offset> route, double t) {
    if (route.length < 2) return route.first;
    final segments = route.length - 1;
    final segmentT = t * segments;
    final segIndex = segmentT.floor().clamp(0, segments - 1);
    final localT = segmentT - segIndex;
    return Offset.lerp(route[segIndex], route[segIndex + 1], localT)!;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_routes.length, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            final t = _animations[i].value;
            final pos = _interpolateRoute(_routes[i], t);

            // Calculate direction angle
            double angle = 0;
            if (t < 0.99) {
              final nextT = (t + 0.01).clamp(0.0, 1.0);
              final nextPos = _interpolateRoute(_routes[i], nextT);
              angle = atan2(
                nextPos.dy - pos.dy,
                nextPos.dx - pos.dx,
              );
            }

            return Positioned(
              left: pos.dx * MediaQuery.of(context).size.width - 16,
              top: pos.dy * MediaQuery.of(context).size.height - 11,
              child: Transform.rotate(
                  angle: angle,
                  child: _TruckIcon(index: i),
                ),
            );
          },
        );
      }),
    );
  }
}

class _TruckIcon extends StatelessWidget {
  const _TruckIcon({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final size = index % 2 == 0 ? 28.0 : 22.0;
    return Container(
      width: size + 12,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping,
            color: Colors.white,
            size: size * 0.65,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login Form
// ─────────────────────────────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.controller});
  final AuthController controller;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.controller.authFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium('Email / Phone', fontSize: 13,
              color: AppColors.lightTextColor),
          const SizedBox(height: 8),
          CurvedContainer(
            border: Border.all(color: AppColors.borderColor),
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CustomTextField(
              'johndoe@gmail.com',
              widget.controller.textControllers[0],
              prefix: HugeIcons.strokeRoundedMail01,
              label: '',
            ),
          ),
          const SizedBox(height: 20),
          AppText.medium('PIN', fontSize: 13,
              color: AppColors.lightTextColor),
          const SizedBox(height: 8),
          CurvedContainer(
            border: Border.all(color: AppColors.borderColor),
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CustomTextField(
              '••••',
              widget.controller.textControllers[1],
              prefix: HugeIcons.strokeRoundedLockPassword,
              label: '',
              varl: FPL.password,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => widget.controller.errorText.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFFF1F1F), size: 14),
                      const SizedBox(width: 6),
                      AppText.thin(
                        widget.controller.errorText.value,
                        fontSize: 12,
                        color: AppColors.red,
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 8)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () async =>
                  await widget.controller.onAuthPressed(),
              text: 'Sign In',
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: AppText.thin(
              '© 2026 Transborder Logistics. All rights reserved.',
              fontSize: 11,
              color: AppColors.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat badge for desktop branding panel
// ─────────────────────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bold(value, fontSize: 24, color: Colors.white),
        AppText.thin(label, fontSize: 12,
            color: Colors.white.withOpacity(0.7)),
      ],
    );
  }
}