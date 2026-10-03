import 'package:flutter/material.dart';

import '../models/business_model.dart';
import '../services/business_storage_service.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState
    extends State<BusinessProfileScreen> {
  final TextEditingController businessNameController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadBusiness();
  }

  @override
  void dispose() {
    businessNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();

    super.dispose();
  }

  Future<void> _loadBusiness() async {
    final business =
    await BusinessStorageService.getBusiness();

    if (!mounted) {
      return;
    }

    if (business != null) {
      businessNameController.text =
          business.businessName;

      phoneController.text =
          business.phone;

      emailController.text =
          business.email;

      addressController.text =
          business.address;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveBusiness() async {
    if (businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your business name.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    final business = BusinessModel(
      businessName:
      businessNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
    );

    await BusinessStorageService.saveBusiness(
      business,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Business profile saved successfully.',
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Business Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo
                    .withValues(alpha: 0.08),
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.business,
                    size: 48,
                    color: Colors.indigo,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your Business Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'This information can be used on your invoices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller:
              businessNameController,
              textInputAction:
              TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Business Name',
                icon: Icons.business_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              keyboardType:
              TextInputType.phone,
              textInputAction:
              TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Phone',
                icon: Icons.phone_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType:
              TextInputType.emailAddress,
              textInputAction:
              TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Email',
                icon: Icons.email_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: addressController,
              maxLines: 3,
              textInputAction:
              TextInputAction.done,
              decoration: _inputDecoration(
                label: 'Business Address',
                icon: Icons.location_on_outlined,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed:
                isSaving
                    ? null
                    : _saveBusiness,
                icon: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.save_outlined,
                ),
                label: Text(
                  isSaving
                      ? 'Saving...'
                      : 'Save Business Profile',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}