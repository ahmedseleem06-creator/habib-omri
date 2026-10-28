import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_offer.dart';
import '../theme/app_theme.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({Key? key}) : super(key: key);

  static final List<ServiceOffer> offersList = [
    ServiceOffer(
      id: '1',
      title: 'باقة نمو المحل الشاملة 🏪',
      category: 'shop',
      description: '12 بوست شهرياً + إعلان ممول مستهدف + إدارة وتحسين الصفحات',
      price: 3500,
      originalPrice: 4500,
      badge: 'الأكثر طلباً للمحلات',
      features: [
        '12 بوست احترافي بتصاميم ومحتوى إبداعي',
        'إدارة حملة ممولة مستهدفة لمنطقة المحل',
        'تعديل وتحسين صفحة فيسبوك وانستجرام',
      ],
    ),
    ServiceOffer(
      id: '2',
      title: 'صيانة لابتوبات وشبكات محلات 🛠️',
      category: 'maintenance',
      description: 'كشف وصيانة فورية لأجهزة الكمبيوتر والكاشير بالضمان',
      price: 0,
      badge: 'كشف وصيانة سريعة',
      features: [
        'تغيير شاشات، بطاريات، وهاردات SSD',
        'تنزيل ويندوز وبرامج الجرافيك الأصلية',
        'ربط وتجهيز شبكات المحلات والكاشير',
      ],
    ),
    ServiceOffer(
      id: '3',
      title: 'سمسرة وأجهزة استيراد بيزنس 💻',
      category: 'brokerage',
      description: 'أجهزة لابتوب استيراد فرز أول للشغل والمحلات بأسعار الجملة',
      price: 6500,
      badge: 'فرز أول بالضمان',
      features: [
        'أجهزة بحالة الزيرو ومختبرة بالكامل',
        'مناسبة للمصممين والمحاسبين والمطاعم',
        'Dell • HP • Lenovo مع ضمان الاستبدال',
      ],
    ),
    ServiceOffer(
      id: '4',
      title: 'اشتراك ChatGPT Plus أصلي 🤖',
      category: 'ai',
      description: 'حساب مفعل كامل الصلاحيات مع ضمان شهر كامل',
      price: 650,
      originalPrice: 1100,
      badge: 'تسليم في 5 دقائق',
      features: [
        'وصول لـ GPT-4o وتوليد صور DALL-E',
        'تحليل الملفات والمساعدة البرمجية',
        'ضمان ودعم فني طوال مدة الاشتراك',
      ],
    ),
  ];

  void _bookViaWhatsApp(String offerTitle) async {
    final text = 'مرحباً X Deal Marketing (01021983866)، أود الاستفسار وطلب: $offerTitle.';
    final uri = Uri.parse('https://wa.me/201021983866?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 باقات وعروض العملاء'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: offersList.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          final o = offersList[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        o.badge,
                        style: const TextStyle(color: AppTheme.neonAmber, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      o.price > 0 ? '${o.price.toStringAsFixed(0)} ج.م' : 'حسب العطل',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  o.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  o.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...o.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.neonEmerald, size: 14),
                      const SizedBox(width: 6),
                      Text(f, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                )),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.electricIndigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _bookViaWhatsApp(o.title),
                    child: const Text('طلب الباقة الآن عبر واتساب 💬', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
