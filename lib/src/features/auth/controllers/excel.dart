import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

Future<String?> generateExcelReport({
  required String reportTitle,
  required List<dynamic> data,
  List<String>? columnsToInclude,
  Map<String, String>? columnHeaders,
}) async {
  try {
    // Create a new Excel document
    final excel = Excel.createExcel();

    // Use the first sheet or create a new one
    final Sheet sheet = excel['Report'];

    // Format dates for display
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Add title and date range (merged cells for title)
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnHeaders!.length - 1, rowIndex: 0));
    final titleCell = sheet.cell(CellIndex.indexByString("A1"));
    titleCell.value = TextCellValue(reportTitle);
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Add date range
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        CellIndex.indexByColumnRow(
            columnIndex: columnHeaders!.length - 1, rowIndex: 1));
    final dateRangeCell = sheet.cell(CellIndex.indexByString("A2"));
    dateRangeCell.cellStyle = CellStyle(
      italic: true,
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Add empty row
    // Headers start at row 4
    int rowIndex = 4;
    int colIndex = 0;

    // Determine which columns to include
    final headers =
        columnsToInclude ?? (data.isNotEmpty ? data.first.keys.toList() : []);

    // Write headers
    for (final header in headers) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: colIndex,
        rowIndex: rowIndex,
      ));
      cell.value = TextCellValue(columnHeaders[header] ?? header);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString("#DDDDDD"),
        horizontalAlign: HorizontalAlign.Center,
      );
      colIndex++;
    }

    rowIndex++; // Move to data rows

    // Map to store totals for specified columns
    final totals = <String, num>{};


    // Write data rows
    for (final item in data) {
      colIndex = 0;

      for (final header in headers) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIndex,
          rowIndex: rowIndex,
        ));

        final value = item[header];

        // Format the cell based on value type
        if (value == null) {
          cell.value = TextCellValue("");
        } else if (value is num) {
          cell.value = DoubleCellValue(value.toDouble());
        } else if (value is DateTime) {
          cell.value = TextCellValue(dateFormat.format(value));
        } else {
          cell.value = TextCellValue(value.toString());
        }


        cell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
        );

        colIndex++;
      }

      rowIndex++;
    }

    // Add a total row if we have columns to total
    

    // Auto fit columns
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    excel.delete('Sheet1');

    // Prepare the file name (with timestamp to avoid duplicates)
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedTitle =
        reportTitle.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final fileName = "${sanitizedTitle}_$timestamp.xlsx";

    // Save the file based on platform
    return await _saveExcelFile(excel, fileName);
  } catch (e) {
    print('Error generating Excel report: $e');
    return null;
  }
}

Future<String?> _saveExcelFile(Excel excel, String fileName) async {
  try {
    // if (Platform.isAndroid || Platform.isIOS) {
    //   // Request storage permission on mobile
    //   var status = await Permission.storage.request();
    //   if (!status.isGranted) {
    //     return null;
    //   }
    // }

    final bytes = excel.encode();
    if (bytes == null) return null;

    // Handle different platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop platforms, use file picker to choose save location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        return null; // User canceled the picker
      }

      final file = File('$selectedDirectory/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } else if (Platform.isAndroid) {
      // For Android
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Make sure it exists
        if (!await directory.exists()) {
          // Fallback
          directory = await getExternalStorageDirectory();
        }
      } else {
        // iOS
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return null;

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } else {
      // iOS
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  } catch (e) {
    print('Error saving Excel file: $e');
    return null;
  }
}
