import 'package:flutter/material.dart';
import '../../../widgets/atoms/custom_text_field.dart';

class FamilyRegistrationScreen extends StatefulWidget {
  const FamilyRegistrationScreen({super.key});

  @override
  State<FamilyRegistrationScreen> createState() => _FamilyRegistrationScreenState();
}

class _FamilyRegistrationScreenState extends State<FamilyRegistrationScreen> {
  int _currentStep = 0;
  final _noKKController = TextEditingController();
  final List<Map<String, dynamic>> _members = []; // For NIKs and names
  // Mock file list
  List<String> _selectedFiles = []; 

  void _addMember() {
    setState(() {
      _members.add({'nama': '', 'nik': ''});
    });
  }

  void _pickFiles() async {
    // TODO: Implement file picking logic
    setState(() {
      _selectedFiles.add('dummy_ktp.jpg');
    });
  }

  Future<void> _submitData() async {
    // TODO: Implement actual multipart/form-data upload using Dio
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunggah data KK dan dokumen...')),
    );
    // Success -> Navigate to Warga Dashboard with 'Pending Verification' state
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Keluarga & Dokumen')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submitData();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(
            title: const Text('Informasi KK'),
            isActive: _currentStep >= 0,
            content: CustomTextField(
              controller: _noKKController,
              label: 'Nomor KK',
              prefixIcon: Icons.credit_card,
              keyboardType: TextInputType.number,
            ),
          ),
          Step(
            title: const Text('Anggota Keluarga (Opsional)'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                const Text('Tambahkan NIK anggota keluarga sesuai KK.'),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      title: Text('Member ${index + 1}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _members.removeAt(index)),
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addMember,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Member'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Upload Dokumen'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Unggah foto KTP dan KK sebagai dokumen pendukung verifikasi.'),
                const SizedBox(height: 16),
                if (_selectedFiles.isNotEmpty)
                  ..._selectedFiles.map((f) => ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(f),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  )),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pilih Foto Dokumen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
