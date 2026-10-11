
import 'package:flutter/material.dart';

import '../../models/Invoice Template Model/invoice_template_model.dart';
import '../../services/Invoice Template Storage Service/invoice_template_storage_service.dart';

class InvoiceTemplatesScreen extends StatefulWidget {
  const InvoiceTemplatesScreen({super.key});

  @override
  State<InvoiceTemplatesScreen> createState() =>
      _InvoiceTemplatesScreenState();
}

class _InvoiceTemplatesScreenState
    extends State<InvoiceTemplatesScreen> {
  String _selectedTemplateId = 'professional';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedTemplate();
  }

  Future<void> _loadSelectedTemplate() async {
    final template =
    await InvoiceTemplateStorageService.getSelectedTemplate();

    if (!mounted) return;

    setState(() {
      _selectedTemplateId = template.id;
      _isLoading = false;
    });
  }

  Future<void> _selectTemplate(
      InvoiceTemplateModel template,
      ) async {
    await InvoiceTemplateStorageService.saveSelectedTemplate(
      template.id,
    );

    if (!mounted) return;

    setState(() {
      _selectedTemplateId = template.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template.name} template selected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Templates'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount:
        InvoiceTemplateModel.templates.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final template =
          InvoiceTemplateModel.templates[index];

          final isSelected =
              _selectedTemplateId == template.id;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectTemplate(template),
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? template.primaryColor
                      : Colors.grey.shade300,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: template.backgroundColor,
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      padding:
                      const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 9,
                            width: 55,
                            decoration: BoxDecoration(
                              color:
                              template.primaryColor,
                              borderRadius:
                              BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 4,
                            width: 75,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            height: 4,
                            width: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 22,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                              template.primaryColor,
                              borderRadius:
                              BorderRadius.circular(3),
                            ),
                            alignment: Alignment.centerLeft,
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: const Text(
                              'INVOICE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          ...List.generate(
                            3,
                                (lineIndex) => Padding(
                              padding:
                              const EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 4,
                                      color: Colors
                                          .grey.shade300,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Container(
                                    height: 4,
                                    width: 20,
                                    color:
                                    template.accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment:
                            Alignment.bottomRight,
                            child: Container(
                              height: 15,
                              width: 48,
                              decoration: BoxDecoration(
                                color:
                                template.accentColor,
                                borderRadius:
                                BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: template.primaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSelected
                          ? null
                          : () => _selectTemplate(template),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                        template.primaryColor,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        isSelected ? 'Selected' : 'Use Template',
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}