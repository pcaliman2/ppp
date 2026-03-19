import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:owa_flutter/api/checkout_repository.dart';
import 'package:owa_flutter/api/external_payment_redirect.dart';
import 'package:owa_flutter/api/http_checkout_repository.dart';
import 'package:owa_flutter/api/mock_checkout_repository.dart';
import 'package:owa_flutter/cart/cart_scope.dart';
import 'package:owa_flutter/cart/cart_store.dart';
import 'package:owa_flutter/config/api_config.dart';
import 'package:owa_flutter/models/checkout_item.dart';
import 'package:owa_flutter/models/checkout_request.dart';
import 'package:owa_flutter/models/checkout_response.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/action_button.dart';
import 'package:owa_flutter/widgets/owa_nav_bar.dart';

class CompleteSalePage extends StatefulWidget {
  const CompleteSalePage({super.key});

  @override
  State<CompleteSalePage> createState() => _CompleteSalePageState();
}

class _CompleteSalePageState extends State<CompleteSalePage> {
  late final CheckoutRepository _repository;
  bool _isLoading = false;

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)} MXN';

  @override
  void initState() {
    super.initState();
    _repository = useMockBackend
        ? const MockCheckoutRepository()
        : const HttpCheckoutRepository();
  }

  Future<void> _pay() async {
    if (_isLoading) return;

    final cartStore = CartScope.of(context);
    if (cartStore.items.isEmpty) {
      _showError('Your cart is empty.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = CheckoutRequest(
      items: cartStore.items
          .map(
            (item) => CheckoutItem(
              type: item.type,
              id: item.id,
              title: item.name,
              price: item.price,
              qty: item.qty,
            ),
          )
          .toList(),
      // TODO(auth/profile): replace placeholders with current user profile data.
      buyerName: 'OWA Client',
      buyerEmail: 'client@owa.local',
      buyerPhone: '0000000000',
      buyerCountry: null,
      returnUrl: '/redirect',
      cancelUrl: '/redirect?status=cancelled',
    );

    try {
      final response = await _repository.createCheckout(request);
      if (!mounted) return;

      if (response.paymentUrl != null) {
        if (kIsWeb) {
          final opened = await openExternalPaymentUrl(response.paymentUrl!);
          if (opened) return;
        }
        _goToRedirect(
          status: CheckoutStatus.pending,
          message: 'Open payment portal',
          transactionId: response.transactionId,
        );
        return;
      }

      _goToRedirect(
        status: response.status,
        message: response.message,
        transactionId: response.transactionId,
      );
    } catch (_) {
      if (!mounted) return;
      _showError('Checkout is not available yet.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToRedirect({
    required CheckoutStatus status,
    required String message,
    String? transactionId,
  }) {
    final redirectUri = Uri(
      path: '/redirect',
      queryParameters: {
        'status': status.name,
        'message': message,
        if (transactionId != null && transactionId.isNotEmpty)
          'transactionId': transactionId,
      },
    ).toString();
    Navigator.of(context).pushNamed(redirectUri);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartStore = CartScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final subtotal = cartStore.subtotal;
    final fees = subtotal * 0.045;
    final total = subtotal + fees;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 900;

                  if (isDesktop) {
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox.expand(
                            child: Image.asset(
                              'assets/follow_us_2.png',
                              fit: BoxFit.cover,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: colors.backgroundColor,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                SizeConfig.w(28),
                                SizeConfig.h(36),
                                SizeConfig.w(28),
                                SizeConfig.h(36),
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 800),
                                  child: _buildCheckoutContent(
                                    textTheme: textTheme,
                                    cartStore: cartStore,
                                    subtotal: subtotal,
                                    fees: fees,
                                    total: total,
                                    showTopImage: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const OWANavBar(
                          useWhiteForeground: false,
                          variant: OWANavBarVariant.home,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            SizeConfig.w(24),
                            SizeConfig.h(30),
                            SizeConfig.w(24),
                            SizeConfig.h(36),
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: _buildCheckoutContent(
                                textTheme: textTheme,
                                cartStore: cartStore,
                                subtotal: subtotal,
                                fees: fees,
                                total: total,
                                showTopImage: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_isLoading,
            child: AnimatedOpacity(
              opacity: _isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic,
              child: Container(
                color: const Color(0xFF1D1D1D).withValues(alpha: 0.16),
                alignment: Alignment.center,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFCFC8BE)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C2C2C)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutContent({
    required TextTheme textTheme,
    required CartStore cartStore,
    required double subtotal,
    required double fees,
    required double total,
    required bool showTopImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTopImage) ...[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: SizedBox(
              height: 90,
              child: Image.asset(
                'assets/follow_us_2.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.h(40)),
        ],
        Text(
          'Complete Sale',
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            fontSize: 40,
            color: const Color(0xFF242424),
            fontWeight: FontWeight.w500,
            height: 1.05,
          ),
        ),
        SizedBox(height: SizeConfig.h(14)),
        Text(
          'Review your order and confirm payment.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF4B4B4B),
            fontSize: 17,
          ),
        ),
        SizedBox(height: SizeConfig.h(48)),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 18),
                child: child,
              ),
            );
          },
          child: _buildSummary(
            cartStore,
            subtotal,
            fees,
            total,
            textTheme,
          ),
        ),
        SizedBox(height: SizeConfig.h(40)),
        _buildPayButton(total, textTheme),
        const SizedBox(height: 24),
        /* TODO: REMOVE LATER - BOTONES DE PRUEBA
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton(
              onPressed: () {
                OwaFlash.showSuccess(
                  context,
                  'Booking/Purchase Successful: Check your User Dashboard for details.',
                );
              },
              child: const Text('Test Success'),
            ),
            OutlinedButton(
              onPressed: () {
                OwaFlash.showFailure(
                  context,
                  'Payment failed: Please verify your card details and try again.',
                );
              },
              child: const Text('Test Error'),
            ),
            OutlinedButton(
              onPressed: () {
                OwaFlash.showCancellation(
                  context,
                  'Payment cancelled: Your reservation was not completed.',
                );
              },
              child: const Text('Test Cancel'),
            ),
          ],
        ),
        */
      ],
    );
  }

  Widget _buildSummary(
    CartStore cartStore,
    double subtotal,
    double fees,
    double total,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Order Summary', textTheme),
        SizedBox(height: SizeConfig.h(18)),
        ...cartStore.items.map<Widget>(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.h(14)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
                Text(
                  _formatCurrency(item.price * item.qty),
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 32, thickness: 1, color: Colors.black12),
        _moneyRow('Subtotal', subtotal, textTheme),
        _moneyRow('Fees', fees, textTheme),
        SizedBox(height: SizeConfig.h(8)),
        _moneyRow('Total', total, textTheme, isTotal: true),
      ],
    );
  }

  Widget _buildPayButton(double total, TextTheme _) {
    return ActionButton(
      text: _isLoading ? 'PROCESSING...' : 'PAY ${_formatCurrency(total)}',
      onTap: _isLoading ? null : _pay,
      width: double.infinity,
      height: 54,
      baseColor: const Color(0xFF1F1F1F),
      hoverColor: const Color(0xFF333333),
      borderColor: const Color(0xFF1F1F1F),
      margin: EdgeInsets.zero,
    );
  }

  Widget _moneyRow(String label, double value, TextTheme textTheme, {bool isTotal = false}) {
    if (isTotal) {
      return Padding(
        padding: EdgeInsets.only(top: SizeConfig.h(8), bottom: SizeConfig.h(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: textTheme.titleLarge?.copyWith(
                color: const Color(0xFF232323),
                fontWeight: FontWeight.w500,
                fontSize: 26,
              ),
            ),
            const Spacer(),
            Text(
              _formatCurrency(value),
              style: textTheme.displaySmall?.copyWith(
                color: const Color(0xFF1F1F1F),
                fontSize: 48,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      );
    }

    final style = textTheme.bodyLarge?.copyWith(
      color: const Color(0xFF2D2D2D),
      fontWeight: FontWeight.w400,
      fontSize: 17,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.h(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(_formatCurrency(value), style: style),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        fontSize: 24,
        color: const Color(0xFF242424),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
