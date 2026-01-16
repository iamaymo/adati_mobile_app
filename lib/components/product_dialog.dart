import 'package:adati_mobile_app/components/payment_sheet.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';
import 'cart.dart';

class Product {
  final int id; // أضفنا الـ ID للتعامل مع السيرفر
  final int ownerId;
  final String title;
  final String price;
  final List<String> images; // changed to multiple images
  final String description;
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.price,
    required this.images,
    required this.description,
    this.rating = 5.0,
    this.reviews = 0,
  });
}

Future<void> showProductDialog(
  BuildContext context,
  Product product,
  int? currentUserId,
) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: GestureDetector(
          onTap: () {},
          child: _ProductDialogContent(
            product: product,
            currentUserId: currentUserId,
          ),
        ),
      ),
    ),
  );
}

class _ProductDialogContent extends StatefulWidget {
  final Product product;
  final int? currentUserId;
  const _ProductDialogContent({
    Key? key,
    required this.product,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<_ProductDialogContent> createState() => _ProductDialogContentState();
}

class _ProductDialogContentState extends State<_ProductDialogContent> {
  bool isFavorite = false;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    checkIfFavorite();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // التحقق من حالة المفضلة عند فتح الديالوج
  Future<void> checkIfFavorite() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8000/api/favorites/check/${widget.product.id}/',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => isFavorite = data['is_favorite']);
      }
    } catch (e) {
      debugPrint("Error checking favorite: $e");
    }
  }

  // تغيير حالة المفضلة في السيرفر
  Future<void> toggleFavorite() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/favorites/toggle/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'tool_id': widget.product.id}),
      );
      if (response.statusCode == 200) {
        setState(() => isFavorite = !isFavorite);
      }
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
    }
  }

  bool get isInCart {
    return Cart.instance.items.value.any(
      (item) => item.title == widget.product.title,
    );
  }

  void _showFullScreenImage(BuildContext context) {
    final images = widget.product.images;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: StatefulBuilder(
              builder: (context, setStateFull) {
                final pageCtrl = PageController(initialPage: _currentPage);
                return Stack(
                  children: [
                    PageView.builder(
                      controller: pageCtrl,
                      itemCount: images.isNotEmpty ? images.length : 1,
                      onPageChanged: (p) {
                        setStateFull(() {});
                      },
                      itemBuilder: (ctx, idx) {
                        if (images.isEmpty) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.white,
                            ),
                          );
                        }
                        return InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            images[idx],
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.white,
                                ),
                          ),
                        );
                      },
                    ),
                    // left arrow
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: FutureBuilder(
                        future: Future.value(true),
                        builder: (_, __) {
                          final visible =
                              (pageCtrl.hasClients
                                  ? pageCtrl.page?.round() ?? _currentPage
                                  : _currentPage) >
                              0;
                          return Visibility(
                            visible: visible,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final cur = pageCtrl.hasClients
                                    ? (pageCtrl.page?.round() ?? _currentPage)
                                    : _currentPage;
                                if (cur > 0)
                                  pageCtrl.previousPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                  );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // right arrow
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: FutureBuilder(
                        future: Future.value(true),
                        builder: (_, __) {
                          final cur = pageCtrl.hasClients
                              ? (pageCtrl.page?.round() ?? _currentPage)
                              : _currentPage;
                          final visible = images.isNotEmpty
                              ? cur < (images.length - 1)
                              : false;
                          return Visibility(
                            visible: visible,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final cur2 = pageCtrl.hasClients
                                    ? (pageCtrl.page?.round() ?? _currentPage)
                                    : _currentPage;
                                if (images.isNotEmpty &&
                                    cur2 < images.length - 1) {
                                  pageCtrl.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // dots indicator
                    if (images.isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (i) => AnimatedBuilder(
                              animation: pageCtrl,
                              builder: (context, child) {
                                final page = pageCtrl.hasClients
                                    ? (pageCtrl.page ??
                                          pageCtrl.initialPage.toDouble())
                                    : pageCtrl.initialPage.toDouble();
                                final selected = (page.round() == i);
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: selected ? 10 : 6,
                                  height: selected ? 10 : 6,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white54,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ], // نهاية Stack children
                );
              }, // نهاية Builder
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // السطر العلوي: رجوع ومفضلة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: toggleFavorite,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // منطقة صور المنتج - تم تعديل الـ Stack هنا
              GestureDetector(
                onTap: () => _showFullScreenImage(context),
                child: SizedBox(
                  height: 220, // زيادة الارتفاع قليلاً ليكون أوضح
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // 1. عرض الصور (PageView)
                        PageView.builder(
                          controller: _pageController,
                          itemCount: images.isNotEmpty ? images.length : 1,
                          onPageChanged: (p) {
                            setState(() {
                              _currentPage = p;
                            });
                          },
                          itemBuilder: (ctx, idx) {
                            if (images.isEmpty) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              );
                            }
                            return Image.network(
                              images[idx],
                              fit: BoxFit.contain,
                              width: double.infinity,
                              // إضافة Loading Indicator لكل صورة
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                            );
                          },
                        ),

                        // 2. سهم التنقل لليسار
                        if (images.length > 1 && _currentPage > 0)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),

                        // 3. سهم التنقل لليمين
                        if (images.length > 1 &&
                            _currentPage < images.length - 1)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),

                        // 4. مؤشر النقاط (Dots)
                        if (images.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  height: 8,
                                  width: _currentPage == index ? 12 : 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == index
                                        ? Colors.white
                                        : Colors.white38,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // العنوان والسعر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${widget.product.price} ",
                          style: const TextStyle(
                            color: Color(0xFFFFC72C),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: "YER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // التقييم
              Row(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star,
                        size: 20,
                        color: i < widget.product.rating.round()
                            ? Colors.yellow[700]
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.product.rating} (${widget.product.reviews} Review)',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // تفاصيل المنتج
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.product.description,
                  style: TextStyle(color: Colors.grey[300], fontSize: 15),
                ),
              ),
              const SizedBox(height: 24),

              // أزرار التحكم (تصميم مدمج)
              widget.product.ownerId == widget.currentUserId
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Text(
                          "You are the owner of this tool",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isInCart) {
                                    final index = Cart.instance.items.value
                                        .indexWhere(
                                          (item) =>
                                              item.title ==
                                              widget.product.title,
                                        );
                                    if (index != -1)
                                      Cart.instance.removeAt(index);
                                  } else {
                                    Cart.instance.add(widget.product);
                                  }
                                });
                              },
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: isInCart
                                      ? Colors.red[700]
                                      : Theme.of(context).colorScheme.primary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    isInCart
                                        ? 'Remove from Cart'
                                        : 'Add to Cart',
                                    style: TextStyle(
                                      color: isInCart
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 55,
                            color: const Color(0xFF1E1E1E),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                showPaymentMethodSheet(
                                  context,
                                  amount: 0,
                                  onPaid: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment successful'),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Rent Now',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
