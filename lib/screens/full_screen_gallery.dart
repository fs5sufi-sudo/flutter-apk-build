import 'package:flutter/material.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _nextPage() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. نمایشگر عکس‌ها (با قابلیت زوم)
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.white, size: 50),
                  ),
                ),
              );
            },
          ),

          // 2. دکمه بستن (بالا راست)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. شمارنده عکس (بالا وسط)
          Positioned(
            top: 45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // 4. دکمه قبلی (چپ) - فقط اگر عکس اول نباشد
          if (_currentIndex > 0)
            Positioned(
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 40),
                onPressed: _prevPage,
              ),
            ),

          // 5. دکمه بعدی (راست) - فقط اگر عکس آخر نباشد
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
                onPressed: _nextPage,
              ),
            ),
        ],
      ),
    );
  }
}
