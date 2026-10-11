
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker _imagePicker = ImagePicker();

  String? logoPath;
  File? selectedLogo;

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
    try {
      final business =
      await BusinessStorageService.getBusiness();

      if (!mounted) return;

      if (business != null) {
        businessNameController.text =
            business.businessName;
        phoneController.text = business.phone;
        emailController.text = business.email;
        addressController.text = business.address;

        final savedPath = business.logoPath;

        if (savedPath != null &&
            savedPath.isNotEmpty &&
            await File(savedPath).exists()) {
          logoPath = savedPath;
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load business profile.',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      setState(() {
        selectedLogo = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select logo: $e'),
        ),
      );
    }
  }

  Future<void> _saveBusiness() async {
    if (businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your business name.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? finalLogoPath = logoPath;

      if (selectedLogo != null) {
        finalLogoPath =
        await BusinessStorageService.saveLogo(
          selectedLogo!,
        );
      }

      final business = BusinessModel(
        businessName:
        businessNameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        address: addressController.text.trim(),
        logoPath: finalLogoPath,
      );

      await BusinessStorageService.saveBusiness(
        business,
      );

      if (!mounted) return;

      setState(() {
        logoPath = finalLogoPath;
        selectedLogo = null;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Business profile and logo saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
        ),
      );
    }
  }

  Widget _buildLogoPreview() {
    final String? currentPath =
        selectedLogo?.path ?? logoPath;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.25),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: currentPath != null &&
          File(currentPath).existsSync()
          ? Image.file(
        File(currentPath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.business,
            size: 50,
            color: Colors.indigo,
          );
        },
      )
          : const Icon(
        Icons.business,
        size: 50,
        color: Colors.indigo,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _buildLogoPreview(),
                  const SizedBox(height: 14),
                  const Text(
                    'Your Business Logo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose a logo for your invoices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed:
                    isSaving ? null : _pickLogo,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                    ),
                    label: const Text('Choose Logo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: businessNameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Business Name',
                icon: Icons.business_outlined,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Phone',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Email',
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              maxLines: 3,
              textInputAction: TextInputAction.done,
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
                isSaving ? null : _saveBusiness,
                icon: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save_outlined),
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