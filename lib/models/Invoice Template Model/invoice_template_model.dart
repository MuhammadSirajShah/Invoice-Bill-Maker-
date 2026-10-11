
import 'package:flutter/material.dart';

class InvoiceTemplateModel {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;

  const InvoiceTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
  });

  static const List<InvoiceTemplateModel> templates = [
    InvoiceTemplateModel(
      id: 'professional',
      name: 'Professional',
      description: 'Corporate blue and white',
      primaryColor: Color(0xFF273C75),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF4878C0),
    ),
    InvoiceTemplateModel(
      id: 'modern',
      name: 'Modern',
      description: 'Fresh green accents',
      primaryColor: Color(0xFF167D5A),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF50B38A),
    ),
    InvoiceTemplateModel(
      id: 'classic',
      name: 'Classic',
      description: 'Formal black and white',
      primaryColor: Color(0xFF222222),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF777777),
    ),
    InvoiceTemplateModel(
      id: 'luxury',
      name: 'Luxury',
      description: 'Premium black and gold',
      primaryColor: Color(0xFF171717),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFC29B45),
    ),
    InvoiceTemplateModel(
      id: 'creative',
      name: 'Creative',
      description: 'Colorful and expressive',
      primaryColor: Color(0xFF7038A8),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFF8A65),
    ),
    InvoiceTemplateModel(
      id: 'minimal',
      name: 'Minimal',
      description: 'Simple and clean',
      primaryColor: Color(0xFF424242),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFBDBDBD),
    ),
    InvoiceTemplateModel(
      id: 'tech',
      name: 'Tech',
      description: 'Modern technology style',
      primaryColor: Color(0xFF075985),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF38BDF8),
    ),
    InvoiceTemplateModel(
      id: 'elegant',
      name: 'Elegant',
      description: 'Warm and sophisticated',
      primaryColor: Color(0xFF795548),
      backgroundColor: Color(0xFFFFFBF5),
      accentColor: Color(0xFFD7B98E),
    ),
    InvoiceTemplateModel(
      id: 'bold',
      name: 'Bold',
      description: 'Strong orange accents',
      primaryColor: Color(0xFF262626),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFEF6C00),
    ),
    InvoiceTemplateModel(
      id: 'fresh',
      name: 'Fresh',
      description: 'Clean teal design',
      primaryColor: Color(0xFF006D77),
      backgroundColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF83C5BE),
    ),
  ];

  static InvoiceTemplateModel getById(String? id) {
    return templates.firstWhere(
          (template) => template.id == id,
      orElse: () => templates.first,
    );
  }
}