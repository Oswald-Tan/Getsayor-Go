import 'package:getsayor/core/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/data/services/connectivity_service.dart';
import 'package:getsayor/data/services/navigation_service.dart';
import 'package:getsayor/presentation/providers/cart_provider.dart';
import 'package:getsayor/presentation/providers/favorite_provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/presentation/providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/pages/splash.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/routes.dart';
import 'presentation/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi OnePref
  await OnePref.init();

  // HAPUS BARIS INI SETELAH TESTING SELESAI!
  // await OnePref.setBool('first_run', true);

  // Kunci orientasi ke portrait saja
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();
  await NotificationService.setupFCM();

  final authProvider = AuthProvider();
  await authProvider.initialize();

  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('first_run', true);

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final ConnectivityService _connectivityService = ConnectivityService();

  MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        StreamProvider<bool>(
          create: (_) => _connectivityService.connectivityStatus,
          initialData: true,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Getsayor',
        theme: AppTheme.lightTheme(context),
        routes: routes,
        initialRoute: SplashScreen.routeName,
        navigatorKey: navigatorKey, // Gunakan navigatorKey yang sama
        builder: (context, child) {
          return InternetConnectionListener(
            navigatorKey: navigatorKey,
            connectivityService: _connectivityService,
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}

class InternetConnectionListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final ConnectivityService connectivityService;

  const InternetConnectionListener({
    super.key,
    required this.child,
    required this.navigatorKey,
    required this.connectivityService,
  });

  @override
  State<InternetConnectionListener> createState() =>
      _InternetConnectionListenerState();
}

class _InternetConnectionListenerState
    extends State<InternetConnectionListener> {
  bool _isBottomSheetVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.connectivityService.initialize();
      _setupConnectivityListener();
    });
  }

  void _setupConnectivityListener() {
    widget.connectivityService.connectivityStatus.listen((hasConnection) {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasConnection) {
          _dismissBottomSheet();
        } else {
          _showBottomSheet();
        }
      });
    });
  }

  void _showBottomSheet() {
    final context = widget.navigatorKey.currentContext;
    if (context == null || _isBottomSheetVisible) return;

    // Jangan tampilkan saat di splash screen
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == SplashScreen.routeName) return;

    _isBottomSheetVisible = true;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const PopScope(
        canPop: true,
        child: NoInternetBottomSheet(),
      ),
    ).then((_) => _isBottomSheetVisible = false);
  }

  void _dismissBottomSheet() {
    if (_isBottomSheetVisible && widget.navigatorKey.currentContext != null) {
      Navigator.of(widget.navigatorKey.currentContext!).pop();
      _isBottomSheetVisible = false;
    }
  }

  @override
  void dispose() {
    widget.connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class NoInternetBottomSheet extends StatelessWidget {
  const NoInternetBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/no-internet.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 30),
          const Text(
            'Koneksi Internet Terputus\natau Lemah',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF363636),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Koneksi internet Anda sedang tidak aktif atau terlalu lemah. Pastikan data seluler atau wifi Anda aktif dan memiliki sinyal yang cukup agar aplikasi berjalan dengan baik.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF797979),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
