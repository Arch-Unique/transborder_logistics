import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '/src/utils/utils_barrel.dart';

///file for all #resusable functions
///Guideline: strongly type all variables and functions

abstract class UtilFunctions {
  static const pideg = 180 / pi;
  static const successCodes = [
    200,
    201,
    202,
    203,
    204,
    205,
    206,
    207,
    208,
    226
  ];

  static PasswordStrength passwordStrengthChecker(String value) {
    value = value.trim();
    final bool passwordHasLetters = Regex.letterReg.hasMatch(value);
    final bool passwordHasNum = Regex.numReg.hasMatch(value);
    final bool passwordHasSpecialChar = Regex.specialCharReg.hasMatch(value);
    if (value.isEmpty) {
      return PasswordStrength.normal;
    } else if (passwordHasLetters && passwordHasNum && passwordHasSpecialChar) {
      return PasswordStrength.strong;
    } else if ((passwordHasLetters && passwordHasNum) ||
        (passwordHasSpecialChar && passwordHasNum) ||
        (passwordHasSpecialChar && passwordHasLetters)) {
      return PasswordStrength.okay;
    } else if (passwordHasLetters ^ passwordHasSpecialChar ^ passwordHasNum) {
      return PasswordStrength.weak;
    } else {
      return PasswordStrength.strong;
    }
  }

  static double deg(double a) => a / pideg;

  static clearTextEditingControllers(List<TextEditingController> conts) {
    for (var i = 0; i < conts.length; i++) {
      conts[i].clear();
    }
  }

  static String moneyRange(num a, num b) {
    return "${a.toCurrency()} - ${b.toCurrency()}";
  }

  static bool isFile(String str) {
  if (str.isEmpty) {
    return false;
  }
  
  // Unix-like (Linux, Android, iOS, macOS)
  if (str.startsWith('/')) {
    return true;
  }
  
  // Windows drive letter (C:\ or C:/)
  if (RegExp(r'^[a-zA-Z]:[\\\/]').hasMatch(str)) {
    return true;
  }
  
  // Windows UNC path (\\server\ or //server/)
  if (RegExp(r'^[\\\/]{2}').hasMatch(str)) {
    return true;
  }
  
  return false;
}


  static String formatPhone(String phone) {
    switch (phone[0]) {
      case '0':
        return '+234${phone.substring(1)}';
      case '+':
        return phone;
      default:
        return '+234${phone.substring(1)}';
    }
  }

  static String formatFullName(String s) {
    return s.maxLength();
  }

  static bool nullOrEmpty(String? s) {
    return s == null || s.isEmpty;
  }

  static returnNullEmpty(dynamic k, dynamic v) {
    if (k is String || k is List) {
      if (k == null || k.isEmpty) {
        return v;
      }
      return k;
    }
    return k ?? v;
  }

  static bool isSuccess(int? a) {
    return successCodes.contains(a);
  }

  static bool validateTecs(List<TextEditingController> tecs) {
    return !(tecs.any((test) => test.text.isEmpty));
  }

  static Future<File> saveToTempFile(Uint8List uint8list,
      {String? filename}) async {
    try {
      // Get the system's temporary directory
      final tempDir = await getTemporaryDirectory();

      // Generate a unique filename if none provided
      final uniqueFileName =
          filename ?? '${DateTime.now().millisecondsSinceEpoch}.png';

      // Create the file path
      final filePath = '${tempDir.path}/$uniqueFileName';

      // Write the Uint8List to a file
      final file = File(filePath);
      await file.writeAsBytes(uint8list);

      return file;
    } catch (e) {
      throw Exception('Failed to convert Uint8List to File: $e');
    }
  }

  /// Wraps a captured PNG image (e.g. from [WidgetsToImageController]) into
  /// a single-page PDF, fitted to the page with a small margin. This keeps
  /// the PDF visually identical to whatever was rendered on screen, rather
  /// than re-building the layout with PDF widgets.
  static Future<Uint8List> imageBytesToPdf(Uint8List pngBytes) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(pngBytes);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    return doc.save();
  }
}
