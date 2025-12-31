import 'package:adati_mobile_app/components/payment_sheet.dart';
import 'package:flutter/material.dart';
import 'cart.dart';

class Product {
  final String title;
  final String price;
  final String image;
  final String description;
  final double rating;
  final int reviews;

  Product({
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    this.rating = 5.0,
    this.reviews = 0,
  });
}

Future<void> showProductDialog(BuildContext context, Product product) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => GestureDetector(
      // عند الضغط على الخلفية الشفافة سيتم إغلاق الديالوج
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: GestureDetector(
          // نستخدم GestureDetector ثاني هنا لمنع إغلاق الديالوج عند الضغط "داخل" المحتوى
          onTap: () {},
          child: _ProductDialogContent(product: product),
        ),
      ),
    ),
  );
}

class _ProductDialogContent extends StatefulWidget {
  final Product product;
  const _ProductDialogContent({Key? key, required this.product})
    : super(key: key);

  @override
  State<_ProductDialogContent> createState() => _ProductDialogContentState();
}

class _ProductDialogContentState extends State<_ProductDialogContent> {
  bool isFavorite = false;

  // دالة للتحقق إذا كان المنتج موجود في السلة أم لا
  bool get isInCart {
    return Cart.instance.items.value.any(
      (item) => item.title == widget.product.title,
    );
  }

  // دالة لفتح الصورة في شاشة كاملة مع إمكانية الزووم
  void _showFullScreenImage(BuildContext context) {
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
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.product.image,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => setState(() => isFavorite = !isFavorite),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // صورة المنتج مع خاصية الضغط للتكبير
              GestureDetector(
                onTap: () => _showFullScreenImage(context),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.product.image,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.white,
                      ),
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
                          text: "per hour",
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
                        size: 25,
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

              // زر الإضافة للسلة / الحذف
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    // زر Add to Cart / Remove from Cart
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isInCart) {
                              // إذا كان موجود، نبحث عنه ونحذفه
                              final index = Cart.instance.items.value
                                  .indexWhere(
                                    (item) =>
                                        item.title == widget.product.title,
                                  );
                              if (index != -1) Cart.instance.removeAt(index);
                            } else {
                              // إذا مش موجود نضيفه
                              Cart.instance.add(widget.product);
                            }
                          });
                        },
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            // يتغير اللون للأحمر إذا كان المنتج مضافاً للسلة
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
                              isInCart ? 'Remove from Cart' : 'Add to Cart',
                              style: TextStyle(
                                color: isInCart ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // فاصل عمودي شفاف يشق الزرين
                    Container(
                      width: 1.5,
                      height: 55,
                      color: const Color(0xFF1E1E1E),
                    ),

                    // زر Rent Now (الأيمن - أصفر)
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          showPaymentMethodSheet(
                            context,
                            amount: Cart.instance.totalPrice(),
                            onPaid: () {
                              Navigator.of(context).pop();
                              Cart.instance.clear();
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
