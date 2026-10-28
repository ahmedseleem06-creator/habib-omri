class TransactionItem {
  final int id;
  final String client;
  final String phone;
  final String activity;
  final String type; // shop, maintenance, brokerage, ai, ads, design
  final String title;
  final double price;
  final double cost;
  final double paid;
  final String date;
  final String renewal;

  TransactionItem({
    required this.id,
    required this.client,
    required this.phone,
    required this.activity,
    required this.type,
    required this.title,
    required this.price,
    required this.cost,
    required this.paid,
    required this.date,
    required this.renewal,
  });

  double get profit => price - cost;
  double get debt => (price - paid) > 0 ? (price - paid) : 0.0;
  bool get isPaidFully => debt <= 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'client': client,
    'phone': phone,
    'activity': activity,
    'type': type,
    'title': title,
    'price': price,
    'cost': cost,
    'paid': paid,
    'date': date,
    'renewal': renewal,
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    id: json['id'] as int,
    client: json['client'] as String,
    phone: json['phone'] as String? ?? '',
    activity: json['activity'] as String? ?? 'عميل وكالة',
    type: json['type'] as String,
    title: json['title'] as String,
    price: (json['price'] as num).toDouble(),
    cost: (json['cost'] as num).toDouble(),
    paid: (json['paid'] as num).toDouble(),
    date: json['date'] as String? ?? '',
    renewal: json['renewal'] as String? ?? '',
  );
}
