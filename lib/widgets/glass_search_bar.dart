import 'package:flutter/material.dart';
import 'dart:ui'; // برای افکت شیشه‌ای (Blur)

class GlassSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;

  const GlassSearchBar({
    super.key,
    required this.onTap,
    this.hintText = "جستجو ملک یا شهر...",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // گوشه‌های گرد
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // افکت تاری پس‌زمینه
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6), // پس‌زمینه تیره و شفاف
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5), // حاشیه طلایی
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Color(0xFFD4AF37), // آیکون طلایی
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  hintText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8), // متن سفید متمایل به خاکستری
                    fontSize: 16,
                    fontFamily: 'Vazir',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune, // آیکون تنظیمات فیلتر
                    color: Color(0xFFD4AF37),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
