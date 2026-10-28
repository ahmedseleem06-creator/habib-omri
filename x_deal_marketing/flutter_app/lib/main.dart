import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/transaction_item.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/add_transaction_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const XDealMarketingApp());
}

class XDealMarketingApp extends StatelessWidget {
  const XDealMarketingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X Deal Marketing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'EG'),
      ],
      locale: const Locale('ar', 'EG'),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  List<TransactionItem> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await StorageService.loadTransactions();
    setState(() {
      _transactions = list;
      _isLoading = false;
    });
  }

  void _addTransaction(TransactionItem item) {
    setState(() {
      _transactions.insert(0, item);
    });
    StorageService.saveTransactions(_transactions);
  }

  void _deleteTransaction(int id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
    StorageService.saveTransactions(_transactions);
  }

  void _openAddTransactionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(onSave: _addTransaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.electricIndigo)),
      );
    }

    final screens = [
      DashboardScreen(
        transactions: _transactions,
        onAddTransaction: _openAddTransactionScreen,
        onDeleteTransaction: _deleteTransaction,
      ),
      const OffersScreen(),
      ClientsScreen(transactions: _transactions),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'لوحة الأرباح',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.local_offer),
            label: 'عروض العملاء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'دليل العملاء',
          ),
        ],
      ),
    );
  }
}
