import 'package:intl/intl.dart';

/// Formatter mata uang terpusat untuk seluruh aplikasi — memastikan harga
/// selalu ditampilkan dalam format Rupiah yang sama seperti di Admin
/// Dashboard (mis. "Rp249.000"), bukan lagi simbol dolar.
final NumberFormat _rupiahFormat = NumberFormat.decimalPattern('id_ID');

String formatRupiah(num? amount) {
  final value = (amount ?? 0).round();
  return 'Rp${_rupiahFormat.format(value)}';
}
