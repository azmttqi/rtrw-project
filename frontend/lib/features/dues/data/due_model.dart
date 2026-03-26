class Due {
  final int id;
  final String month;
  final int year;
  final double amount;
  final String status; // 'LUNAS', 'PENDING', 'BELUM_BAYAR'
  final DateTime? paidAt;

  Due({
    required this.id,
    required this.month,
    required this.year,
    required this.amount,
    required this.status,
    this.paidAt,
  });

  factory Due.fromJson(Map<String, dynamic> json) {
    return Due(
      id: json['id'],
      month: json['bulan'],
      year: json['tahun'],
      amount: (json['jumlah'] as num).toDouble(),
      status: json['status'],
      paidAt: json['tanggal_bayar'] != null ? DateTime.parse(json['tanggal_bayar']) : null,
    );
  }
}
