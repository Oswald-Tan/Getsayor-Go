import 'package:getsayor/presentation/pages/home/home_screen.dart';
import 'package:getsayor/presentation/pages/onboarding_screen.dart';
import 'package:getsayor/presentation/pages/produk/components/order_page.dart';
import 'package:flutter/widgets.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';
import 'package:getsayor/presentation/pages/login_register/register_screen.dart';
import 'package:getsayor/presentation/pages/top_up/components/buy_points.dart';
import 'pages/splash.dart';
import 'pages/reset_password/reset_password.dart';
import 'pages/init_screen.dart';

final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  OnboardingScreen.routeName: (context) => const OnboardingScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  RegisterScreen.routeName: (context) => const RegisterScreen(),
  ResetPasswordScreen.routeName: (context) => const ResetPasswordScreen(),
  BuyPoints.routeName: (context) => const BuyPoints(),
  OrderPage.routeName: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as int;
    return OrderPage(userId: args);
  },
};
