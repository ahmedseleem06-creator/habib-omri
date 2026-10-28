import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/transaction_item.dart';
import '../models/client_item.dart';
import '../theme/app_theme.dart';

class ClientsScreen extends StatelessWidget {
  final List<TransactionItem> transactions;

  const ClientsScreen({Key? key, required this.transactions}) : super(key: key);

  List<ClientItem> _getClients() {
    final Map<String, ClientItem> map = {};
    for (var tx in transactions) {
      final key = tx.client.trim().toLowerCase();
      if (!map.containsKey(key)) {
        map[key] = ClientItem(
          name: tx.client,
          phone: tx.phone,
          activity: tx.activity,
        );
      }
    }
    final list = map.values.toList();
    for (var c in list) {
      c.recalculate(transactions);
    }
    return list;
  }

  void _chatWhatsApp(String phone, String name, double debt) async {
    final p = phone.isNotEmpty ? phone.replaceAll(RegExp(r'^0'), '20') : '201021983866';
    var text = 'أهلاً بك يا $name، معاك X Deal Marketing (01021983866).\nيسعدنا دائماً التعاون معك في خدمات التسويق، الصيانة، وتجهيز الأجهزة!';
    if (debt > 0) {
      text += '\nنود التذكير بوجود مبلغ متبقي قدره: ${debt.toStringAsFixed(0)} ج.م.';
    }

    final uri = Uri.parse('https://wa.me/$p?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = _getClients();

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 دليل العملاء وحساباتهم'),
      ),
      body: clients.isEmpty
          ? const Center(child: Text('لا يوجد عملاء مسجلين بعد', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final c = clients[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.purple.withOpacity(0.2),
                        child: Text(
                          c.name.isNotEmpty ? c.name[0] : 'C',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                            ),
                            Text(
                              '${c.activity} • ${c.phone}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إجمالي المشتريات: ${c.totalSpent.toStringAsFixed(0)} ج.م',
                              style: const TextStyle(fontSize: 11, color: AppTheme.cyberCyan, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${c.totalProfit.toStringAsFixed(0)} ج.م ربح',
                            style: const TextStyle(color: AppTheme.neonEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          IconButton(
                            icon: const Icon(Icons.chat, color: AppTheme.neonEmerald, size: 22),
                            onPressed: () => _chatWhatsApp(c.phone, c.name, c.totalDebt),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
