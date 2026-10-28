import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';

class StorageService {
  static const String _txKey = 'x_deal_transactions_storage';

  static final List<TransactionItem> defaultTransactions = [
    TransactionItem(
      id: 1,
      client: 'كافيه الروشة',
      phone: '01012345678',
      activity: 'كافيه ومطعم',
      type: 'shop',
      title: 'باقة دعاية وتصوير شهرية للمحل',
      price: 3500,
      cost: 1200,
      paid: 3500,
      date: '2026-10-20',
      renewal: '2026-11-20',
    ),
    TransactionItem(
      id: 2,
      client: 'مكتبة النجاح',
      phone: '01511223344',
      activity: 'مكتبة وخدمات',
      type: 'maintenance',
      title: 'صيانة 3 أجهزة وتغيير SSD وكيبورد',
      price: 2400,
      cost: 1100,
      paid: 2400,
      date: '2026-10-22',
      renewal: '',
    ),
    TransactionItem(
      id: 3,
      client: 'أ. محمود عبد الرحمن',
      phone: '01055667788',
      activity: 'مهندس / فريلانسر',
      type: 'brokerage',
      title: 'سمسرة بيع لابتوب Dell Precision استيراد',
      price: 14500,
      cost: 13000,
      paid: 14500,
      date: '2026-10-23',
      renewal: '',
    ),
    TransactionItem(
      id: 4,
      client: 'م. أحمد الشريف',
      phone: '01198765432',
      activity: 'مبرمج',
      type: 'ai',
      title: 'اشتراك ChatGPT Plus شهر كامل',
      price: 650,
      cost: 350,
      paid: 650,
      date: '2026-10-24',
      renewal: '2026-11-01',
    ),
    TransactionItem(
      id: 5,
      client: 'براند أزياء وتجارة',
      phone: '01233445566',
      activity: 'محل ملابس',
      type: 'ads',
      title: 'إعلان تيك توك وفيسبوك ممول',
      price: 2000,
      cost: 1200,
      paid: 1500,
      date: '2026-10-26',
      renewal: '2026-11-04',
    ),
    TransactionItem(
      id: 6,
      client: 'عيادة د. سارة',
      phone: '01099887766',
      activity: 'مركز طبي',
      type: 'design',
      title: 'هوية بصرية و8 تصميمات سوشيال',
      price: 1800,
      cost: 200,
      paid: 1800,
      date: '2026-10-27',
      renewal: '',
    ),
  ];

  static Future<List<TransactionItem>> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_txKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((item) => TransactionItem.fromJson(item)).toList();
      }
    } catch (_) {}
    return List.from(defaultTransactions);
  }

  static Future<void> saveTransactions(List<TransactionItem> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(_txKey, encoded);
    } catch (_) {}
  }
}
