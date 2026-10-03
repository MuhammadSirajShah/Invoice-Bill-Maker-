import 'package:flutter/material.dart';

import '../models/invoice_model.dart';
import '../services/invoice_storage_service.dart';
import 'business_profile_screen.dart';
import 'create_invoice_screen.dart';
import 'customers_screen.dart';
import 'invoice_preview_screen.dart';
import 'invoices_screen.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InvoiceModel> invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final savedInvoices =
    await InvoiceStorageService.getInvoices();

    if (!mounted) {
      return;
    }

    setState(() {
      invoices = savedInvoices;
    });
  }

  int get paidInvoicesCount {
    return invoices.where(
          (invoice) => invoice.status == 'Paid',
    ).length;
  }

  int get pendingInvoicesCount {
    return invoices.where(
          (invoice) => invoice.status == 'Pending',
    ).length;
  }

  double get paidRevenue {
    return invoices
        .where(
          (invoice) => invoice.status == 'Paid',
    )
        .fold(
      0,
          (sum, invoice) => sum + invoice.total,
    );
  }

  Future<void> _openBusinessProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const BusinessProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice & Bill Maker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
          IconButton(
            onPressed: _openBusinessProfile,
            tooltip: 'Business Profile',
            icon: const Icon(
              Icons.business_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInvoices,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),

            const Text(
              'Good Morning 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Manage your invoices easily',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const CreateInvoiceScreen(),
                    ),
                  );

                  _loadInvoices();
                },
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Create New Invoice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Invoices',
                    value: invoices.length.toString(),
                    icon: Icons.receipt_long,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Paid',
                    value: paidInvoicesCount.toString(),
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pending',
                    value: pendingInvoicesCount.toString(),
                    icon: Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Paid Revenue',
                    value:
                    '\$${paidRevenue.toStringAsFixed(2)}',
                    icon: Icons.payments_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Invoices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (invoices.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const InvoicesScreen(),
                        ),
                      );

                      _loadInvoices();
                    },
                    child: const Text(
                      'View All',
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            if (invoices.isEmpty)
              const _EmptyInvoices()
            else
              ...invoices.take(5).map(
                    (invoice) => _InvoiceCard(
                  invoice: invoice,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InvoicePreviewScreen(
                              invoice: invoice,
                            ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Business Profile
            Card(
              elevation: 0,
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    color: Colors.indigo,
                  ),
                ),
                title: const Text(
                  'Business Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Manage your business information',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: _openBusinessProfile,
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) async {
          if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const CustomersScreen(),
              ),
            );
          }

          if (index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const ProductsScreen(),
              ),
            );
          }

          if (index == 3) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const InvoicesScreen(),
              ),
            );

            _loadInvoices();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.people_outline,
            ),
            label: 'Customers',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.inventory_2_outlined,
            ),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            label: 'Invoices',
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isPaid = invoice.status == 'Paid';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long,
            color: Colors.indigo,
          ),
        ),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              invoice.customerName,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withValues(
                      alpha: 0.1,
                    )
                        : Colors.orange.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    invoice.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPaid
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(invoice.invoiceDate),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '${invoice.currency} '
              '${invoice.total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _EmptyInvoices extends StatelessWidget {
  const _EmptyInvoices();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 36,
          horizontal: 20,
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'No invoices yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create your first invoice to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}