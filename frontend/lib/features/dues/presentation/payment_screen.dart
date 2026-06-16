import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../logic/due_provider.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic due; // The due object from dueProvider.duesHistory

  const PaymentScreen({super.key, required this.due});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Transfer Bank BCA';
  final _proofUrlController = TextEditingController();

  @override
  void dispose() {
    _proofUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pembayaran Iuran',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Tagihan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    'Iuran ${widget.due.month} ${widget.due.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.due.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment Method
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMethod,
                  isExpanded: true,
                  items: [
                    'Transfer Bank BCA',
                    'Transfer Bank Mandiri',
                    'Transfer Bank BRI',
                    'OVO / Dana / GoPay',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMethod = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            
            // Instruction
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1FDF4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instruksi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryGreen)),
                  SizedBox(height: 4),
                  Text('1. Transfer sesuai nominal tagihan ke rekening RT/RW.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  Text('2. Simpan bukti transfer (struk/screenshot).', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  Text('3. Upload bukti transfer di bawah ini.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Bukti Pembayaran (URL/Link Gambar)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _proofUrlController,
              decoration: InputDecoration(
                hintText: 'Masukkan link gambar bukti transfer...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            Consumer<DueProvider>(
              builder: (context, provider, child) {
                return CustomButton(
                  text: provider.isLoading ? 'Memproses...' : 'Konfirmasi Pembayaran',
                  onPressed: provider.isLoading ? null : () async {
                    if (_proofUrlController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan masukkan bukti transfer')));
                      return;
                    }
                    
                    final success = await provider.createPayment(
                      widget.due.month,
                      widget.due.year,
                      widget.due.amount,
                      _selectedMethod,
                      _proofUrlController.text,
                    );
                    
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil dikonfirmasi!')));
                      Navigator.pop(context); // Go back to inbox
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Gagal memproses pembayaran')));
                    }
                  },
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
