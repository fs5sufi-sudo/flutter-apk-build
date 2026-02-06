import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final String? avatarUrl; // اگر عکس پروفایل داشت

  const CustomAppBar({
    super.key,
    this.onAvatarTap,
    this.onNotificationTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2746), // پس‌زمینه تیره
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24), // گوشه‌های گرد پایین
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- دکمه نوتیفیکیشن (چپ) ---
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1), // حاشیه طلایی
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFFD4AF37), // آیکون طلایی
                    size: 24,
                  ),
                ),
              ),

              // --- لوگو (وسط) ---
              Image.asset(
                'assets/images/mensta.png', // لوگوی شما
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Text(
                  "MENSTA",
                  style: TextStyle(
                    color: Color(0xFFD4AF37), // متن طلایی اگر عکس نبود
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // --- آواتار کاربر (راست) ---
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  padding: const EdgeInsets.all(2), // فاصله برای حاشیه
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 2), // حاشیه طلایی ضخیم‌تر
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); // ارتفاع هدر
}
