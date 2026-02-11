import 'dart:io';

import 'package:ausadhi_khau/blocs/medicine/medicine_bloc.dart';
import 'package:ausadhi_khau/blocs/medicine/medicine_event.dart';
import 'package:ausadhi_khau/repositories/medicine_repository.dart';
import 'package:ausadhi_khau/services/hive_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _isGenerating = false;

  Future<void> _shareDataAsFile() async {
    setState(() => _isGenerating = true);
    try {
      final data = HiveService().exportMedicines();
      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = 'medicine_backup_$dateStr.mrbackup';

      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        final String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup File',
          fileName: fileName,
          allowedExtensions: ['mrbackup'],
          type: FileType.custom,
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(data);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Backup saved to $outputFile'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        final directory = await getTemporaryDirectory();
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final file = File('${directory.path}/$fileName');
        await file.writeAsString(data);

        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Medicine Reminder Backup',
            text: 'Backup file generated on $dateStr. Import this in the app.',
            sharePositionOrigin: box != null
                ? box.localToGlobal(Offset.zero) & box.size
                : null,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error sharing file: $e\n$stackTrace');
      if (mounted) {
        final errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share file: $errorMessage'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Copy Error',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: errorMessage));
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.save_alt_rounded,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Backup Your Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create a backup file of all your medicines and schedules. You can share this file to another device or save it for safekeeping.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (_isGenerating)
                const CircularProgressIndicator()
              else
                FilledButton.icon(
                  onPressed: _shareDataAsFile,
                  icon: const Icon(Icons.share),
                  label: const Text('Create & Share Backup'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 56),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({super.key});

  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  bool _isProcessing = false;

  Future<void> _processData(String data) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final count = await HiveService().importMedicines(data);

      if (!mounted) return;

      // Refresh data
      context.read<MedicineBloc>().add(LoadMedicines());

      // Reschedule notifications since IDs might be new/updated
      await MedicineRepository().refreshAllNotifications();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: Text('Successfully imported $count medicines.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                context.pop(); // Go back
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final data = await file.readAsString();
        await _processData(data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Data'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restore_page_rounded,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Restore From Backup',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Import data from a previously created backup file (.mrbackup). This will merge with your existing data.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Importing data...'),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select Backup File'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 56),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
