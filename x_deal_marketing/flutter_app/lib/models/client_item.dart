import 'transaction_item.dart';

class ClientItem {
  final String name;
  final String phone;
  final String activity;
  double totalSpent;
  double totalProfit;
  double totalDebt;
  final List<TransactionItem> orders;

  ClientItem({
    required this.name,
    required this.phone,
    required this.activity,
    this.totalSpent = 0.0,
    this.totalProfit = 0.0,
    this.totalDebt = 0.0,
    List<TransactionItem>? orders,
  }) : orders = orders ?? [];

  void recalculate(List<TransactionItem> allTx) {
    totalSpent = 0.0;
    totalProfit = 0.0;
    totalDebt = 0.0;
    orders.clear();

    for (var tx in allTx) {
      if (tx.client.trim().toLowerCase() == name.trim().toLowerCase()) {
        orders.add(tx);
        totalSpent += tx.price;
        totalProfit += tx.profit;
        totalDebt += tx.debt;
      }
    }
  }
}
