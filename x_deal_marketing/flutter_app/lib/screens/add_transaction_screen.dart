import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(TransactionItem) onSave;

  const AddTransactionScreen({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _paidController = TextEditingController();
  final _renewalController = TextEditingController();

  String _selectedType = 'shop';

  double _calculatedProfit = 0.0;
  double _calculatedDebt = 0.0;

  void _recalc() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final cost = double.tryParse(_costController.text) ?? 0.0;
    final paid = double.tryParse(_paidController.text) ?? 0.0;

    setState(() {
      _calculatedProfit = price - cost;
      _calculatedDebt = (price - paid) > 0 ? (price - paid) : 0.0;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final cost = double.tryParse(_costController.text) ?? 0.0;
      final paid = double.tryParse(_paidController.text) ?? 0.0;

      final newItem = TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch,
        client: _clientController.text.trim(),
        phone: _phoneController.text.trim(),
        activity: 'عميل وكالة',
        type: _selectedType,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'خدمة منفذة',
        price: price,
        cost: cost,
        paid: paid,
        date: DateTime.now().toIso8601String().split('T')[0],
        renewal: _renewalController.text.trim(),
      );

      widget.onSave(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل معاملة بيع جديدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _clientController,
                decoration: InputDecoration(
                  labelText: 'اسم العميل / المحل *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'يرجى كتابة اسم العميل' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم هاتف العميل (واتساب)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'نوع الخدمة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'shop', child: Text('🏪 دعاية وباقات محلات')),
                  DropdownMenuItem(value: 'maintenance', child: Text('🛠️ تقديم صيانة أجهزة')),
                  DropdownMenuItem(value: 'brokerage', child: Text('💻 سمسرة بيع أجهزة')),
                  DropdownMenuItem(value: 'ai', child: Text('🤖 اشتراك ذكاء اصطناعي')),
                  DropdownMenuItem(value: 'ads', child: Text('📢 إعلانات ممولة')),
                  DropdownMenuItem(value: 'design', child: Text('🎨 تصميم وهوية بصرية')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'وصف الخدمة / الجهاز',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Auto-Calculation Financial Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _recalc(),
                            decoration: const InputDecoration(labelText: 'سعر البيع (ج.م) *'),
                            validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _recalc(),
                            decoration: const InputDecoration(labelText: 'تكلفتك الفعلية (ج.م) *'),
                            validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _paidController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalc(),
                      decoration: const InputDecoration(labelText: 'المبلغ المحصل الآن (ج.م) *'),
                      validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('صافي الربح: ${_calculatedProfit.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonEmerald)),
                        Text('المتبقي: ${_calculatedDebt.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonAmber)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _renewalController,
                decoration: InputDecoration(
                  labelText: 'تاريخ التجديد القادم (اختياري)',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.electricIndigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submit,
                child: const Text('حفظ المعاملة وتحديث الأرباح', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
