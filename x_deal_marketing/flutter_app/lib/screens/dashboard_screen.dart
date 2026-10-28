import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/transaction_item.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  final List<TransactionItem> transactions;
  final VoidCallback onAddTransaction;
  final Function(int) onDeleteTransaction;

  const DashboardScreen({
    Key? key,
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
  }) : super(key: key);

  void _launchWhatsApp(String phone, String client, String title, String renewal, double debt) async {
    final p = phone.isNotEmpty ? phone.replaceAll(RegExp(r'^0'), '20') : '201021983866';
    var text = 'أهلاً بك يا $client، معاك X Deal Marketing (01021983866).\nبخصوص: $title.\n';
    if (renewal.isNotEmpty) text += 'الموعد: $renewal.\n';
    if (debt > 0) text += 'المتبقي للتحصيل: ${debt.toStringAsFixed(0)} ج.م.\n';
    text += 'يسعدنا دائماً خدمتك وتطوير أعمالك!';

    final uri = Uri.parse('https://wa.me/$p?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = 0;
    double totalCost = 0;
    double totalProfit = 0;
    double totalDebts = 0;

    for (var t in transactions) {
      totalRevenue += t.price;
      totalCost += t.cost;
      totalProfit += t.profit;
      totalDebts += t.debt;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.apps, color: Colors.indigo),
              ),
            ),
            const SizedBox(width: 10),
            const Text('X Deal - لوحة الأرباح'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.electricIndigo, size: 28),
            onPressed: onAddTransaction,
            tooltip: 'تسجيل عملية جديدة',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI Grid
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard('إجمالي المبيعات', '${totalRevenue.toStringAsFixed(0)} ج.م', Colors.white, Icons.attach_money),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard('صافي الربح', '${totalProfit.toStringAsFixed(0)} ج.م', AppTheme.neonEmerald, Icons.rocket_launch),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard('التكاليف', '${totalCost.toStringAsFixed(0)} ج.م', Colors.grey, Icons.trending_down),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard('الديون المعلقة', '${totalDebts.toStringAsFixed(0)} ج.م', AppTheme.neonAmber, Icons.pending_actions),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transactions Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'سجل العمليات والخدمات المباعة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${transactions.length} معاملة',
                    style: const TextStyle(fontSize: 12, color: AppTheme.cyberCyan, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transactions List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final tx = transactions[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo.withOpacity(0.2),
                        child: Text(
                          tx.client.isNotEmpty ? tx.client[0] : 'X',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.client,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                            ),
                            Text(
                              tx.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tx.debt > 0 ? 'متبقي: ${tx.debt.toStringAsFixed(0)} ج.م' : 'خالص تماماً ✅',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: tx.debt > 0 ? AppTheme.neonAmber : AppTheme.neonEmerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${tx.profit.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(color: AppTheme.neonEmerald, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat, color: AppTheme.neonEmerald, size: 20),
                                onPressed: () => _launchWhatsApp(tx.phone, tx.client, tx.title, tx.renewal, tx.debt),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => onDeleteTransaction(tx.id),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
