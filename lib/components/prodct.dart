import 'package:flutter/material.dart';
import 'cart.dart'; // added

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

/// Call this helper to show the product dialog:
/// await showProductDialog(context, product);
Future<void> showProductDialog(BuildContext context, Product product) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _ProductDialogContent(product: product),
    ),
  );
}

class _ProductDialogContent extends StatefulWidget {
  final Product product;
  const _ProductDialogContent({Key? key, required this.product}) : super(key: key);

  @override
  State<_ProductDialogContent> createState() => _ProductDialogContentState();
}

class _ProductDialogContentState extends State<_ProductDialogContent> {
  bool isFavorite = false; // default white heart

  void _toggleFavorite() => setState(() => isFavorite = !isFavorite);

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
              // top row: back + favorite
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // product image
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.asset(
                    widget.product.image,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // title + price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.product.title,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(widget.product.price,
                      style: const TextStyle(color: Color(0xFFFFC72C), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              // rating
              Row(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(Icons.star,
                          size: 18, color: i < widget.product.rating.round() ? Colors.yellow[700] : Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviews} Review)',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              // Details header
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Details',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              // description
              Text(
                widget.product.description,
                style: TextStyle(color: Colors.grey[300], fontSize: 13),
              ),
              const SizedBox(height: 18),
              // Add to cart button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // add to cart then close
                    Cart.instance.add(widget.product);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC72C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add to Cart', style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}