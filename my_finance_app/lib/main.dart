// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'repository.dart';
import 'security_provider.dart';
import 'currency_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- SETUP DATABASE HIVE ---
  // 1. Inisialisasi Hive
  await Hive.initFlutter();

  // 2. Daftarkan Adapter
  Hive.registerAdapter(MoneyTransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionStatusAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // 3. Buka Box
  await Hive.openBox<MoneyTransaction>('transactions_box');
  await Hive.openBox<Account>('accounts_box');
  await Hive.openBox<Category>('categories_box');

  // --- SETUP REPOSITORY ---
  final repo = Repository();
  
  // !!! PERBAIKAN PENTING DI SINI !!!
  // Wajib panggil init() agar data akun default (Cash, Bank) dibuat otomatis
  // Jika ini tidak dipanggil, Dropdown Akun akan kosong.
  await repo.init(); 
  
  // --- SETUP SECURITY ---
  final security = SecurityProvider();
  await security.init();

  // --- SETUP CURRENCY ---
  final currency = CurrencyProvider(); 

  runApp(MyApp(
    repository: repo, 
    security: security, 
    currency: currency
  ));
}

class MyApp extends StatelessWidget {
  final Repository repository;
  final SecurityProvider security;
  final CurrencyProvider currency;

  const MyApp({
    Key? key,
    required this.repository,
    required this.security,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Repository>.value(value: repository),
        ChangeNotifierProvider<SecurityProvider>.value(value: security),
        ChangeNotifierProvider<CurrencyProvider>.value(value: currency),
      ],
      child: MaterialApp(
        title: 'Rise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF059669),
            brightness: Brightness.light,
            surface: const Color(0xFFECFDF5),
          ),
          scaffoldBackgroundColor: const Color(0xFFECFDF5),
          typography: Typography.material2021(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFECFDF5),
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}