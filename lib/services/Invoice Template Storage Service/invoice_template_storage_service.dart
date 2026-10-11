
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/Invoice Template Model/invoice_template_model.dart';


class InvoiceTemplateStorageService {
  static const String _templateKey =
      'selected_invoice_template';

  static Future<String> getSelectedTemplateId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_templateKey) ??
        'professional';
  }

  static Future<InvoiceTemplateModel>
  getSelectedTemplate() async {
    final templateId = await getSelectedTemplateId();

    return InvoiceTemplateModel.getById(templateId);
  }

  static Future<void> saveSelectedTemplate(
      String templateId,
      ) async {
    final isValid = InvoiceTemplateModel.templates.any(
          (template) => template.id == templateId,
    );

    if (!isValid) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_templateKey, templateId);
  }
}