import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final String? avatarUrl; 
  final bool showBackButton;
  final int unreadCount; 

  const CustomAppBar({
    super.key,
    this.onAvatarTap,
    this.onNotificationTap,
    this.avatarUrl,
    this.showBackButton = false,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                  ),
                )
              else
                // ✅ دکمه نوتیفیکیشن با Badge اصلاح شده
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Stack(
                    clipBehavior: Clip.none, // اجازه می‌دهد بج بیرون بزند
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Color(0xFFD4AF37), size: 24),
                      ),
                      
                      // نمایش بج فقط اگر عدد > 0 باشد
                      if (unreadCount > 0)
                        Positioned(
                          right: -4, // کمی بیرون‌تر
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5), // حاشیه سفید برای تمایز
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              SizedBox(
                height: 32,
                child: Image.asset(
                  'assets/images/mensta.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("MENSTA", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2));
                  },
                ),
              ),

              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 2)),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
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
  Size get preferredSize => const Size.fromHeight(80);
}
