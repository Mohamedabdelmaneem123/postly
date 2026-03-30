import 'package:flutter/material.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _isYearly = true;

  final _plans = [
    {
      'name': 'Starter',
      'desc': 'Perfect for solopreneurs',
      'price_month': '\$19',
      'price_year': '\$15', // billed annually equivalent
      'features': ['1 Workspace', '3 Social Accounts', '50 AI Posts / mo', 'Basic Analytics'],
      'popular': false,
    },
    {
      'name': 'Pro',
      'desc': 'For growing businesses',
      'price_month': '\$49',
      'price_year': '\$39',
      'features': ['3 Workspaces', '10 Social Accounts', 'Unlimited AI Posts', 'Advanced Analytics', 'Priority Support'],
      'popular': true,
    },
    {
      'name': 'Agency',
      'desc': 'For marketing agencies',
      'price_month': '\$149',
      'price_year': '\$119',
      'features': ['Unlimited Workspaces', 'Unlimited Accounts', 'Custom Branding', 'Team Roles & Approvals', 'Dedicated Success Manager'],
      'popular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Simple, transparent pricing',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No hidden fees. Cancel anytime.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Monthly', style: TextStyle(fontWeight: !_isYearly ? FontWeight.bold : FontWeight.normal)),
                Switch(
                  value: _isYearly,
                  activeThumbColor: Theme.of(context).primaryColor,
                  onChanged: (val) => setState(() => _isYearly = val),
                ),
                Text('Yearly (Save 20%)', style: TextStyle(fontWeight: _isYearly ? FontWeight.bold : FontWeight.normal, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
            // We use responsiveness if screen is wide
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _plans.map((p) => Expanded(child: _buildPricingCard(context, p))).toList(),
                  );
                }
                return Column(
                  children: _plans.map((p) => _buildPricingCard(context, p)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, Map<String, dynamic> plan) {
    final isPopular = plan['popular'] as bool;
    final price = _isYearly ? plan['price_year'] : plan['price_month'];
    final features = plan['features'] as List<String>;

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isPopular ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.white,
        border: Border.all(color: isPopular ? Theme.of(context).primaryColor : Colors.grey.shade300, width: isPopular ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPopular ? [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))] : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isPopular)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 4),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(8)),
                child: const Text('MOST POPULAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            Text(plan['name'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(plan['desc'] as String, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price as String, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.0)),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('/mo', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ],
            ),
            if (_isYearly) const Text('Billed annually', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Starting Stripe Checkout for ${plan['name']}...')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? Theme.of(context).primaryColor : Colors.white,
                foregroundColor: isPopular ? Colors.white : Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isPopular ? 'Get Started' : 'Choose Plan'),
            ),
            const SizedBox(height: 32),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
