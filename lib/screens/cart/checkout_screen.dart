import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController(text: '742 Evergreen Terrace, Suite 4B, New York, NY 10001');
  String selectedPayment = 'Credit Card';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    final orderNotifier = ref.read(orderProvider.notifier);
    final order = await orderNotifier.placeOrder(
      shippingAddress: _addressController.text.trim(),
      paymentMethod: selectedPayment,
    );

    if (order != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.accentGold, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: ${order.id}\nThank you for shopping with Parfumerie. Your luxury fragrance is being prepared with white-glove care.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'BACK TO HOME',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Section
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'Enter your delivery address',
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method Section
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPaymentOption('Credit Card', Icons.credit_card),
            _buildPaymentOption('Apple Pay / Google Pay', Icons.account_balance_wallet_outlined),
            _buildPaymentOption('Cash on Delivery', Icons.payments_outlined),

            const SizedBox(height: 24),

            // Order Summary items list
            const Text(
              'Items Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ...cartState.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            Expanded(
                              child: Text(
                                item.product?.name ?? 'Perfume',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '\$${cartState.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: 'PLACE ORDER • \$${cartState.total.toStringAsFixed(2)}',
              isLoading: orderState.isLoading,
              onPressed: _placeOrder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSel = selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => selectedPayment = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? AppColors.primary : AppColors.border,
            width: isSel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSel ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSel)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
