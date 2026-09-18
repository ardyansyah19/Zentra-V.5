import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/theme.dart';
import '../../models/address.dart';
import '../../services/api_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.get('/users/me/addresses');
      _addresses = (data as List).map((e) => Address.fromJson(e)).toList();
    } catch (_) {
      Fluttertoast.showToast(msg: 'Gagal memuat alamat');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Address a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: Text('Hapus alamat "${a.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: AppColors.brand))),
        ],
      ),
    );
    if (confirm != true) return;
    await ApiService.delete('/users/me/addresses/${a.id}');
    Fluttertoast.showToast(msg: 'Alamat dihapus');
    _load();
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressForm(onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: AppColors.brand,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Alamat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off_outlined, size: 56, color: AppColors.plumLight.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text('Belum ada alamat tersimpan', style: TextStyle(color: AppColors.plumLight)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                  itemCount: _addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = _addresses[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: a.isDefault ? Border.all(color: AppColors.brand.withValues(alpha: 0.4)) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                              if (a.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                  child: const Text('Utama', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brand)),
                                ),
                              ],
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _delete(a),
                                child: const Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.plumLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${a.recipient} • ${a.phone}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text(a.fullAddress, style: const TextStyle(fontSize: 12.5, color: AppColors.plumLight, height: 1.4)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddressForm({required this.onSaved});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController(text: 'Rumah');
  final _recipientCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ApiService.post('/users/me/addresses', {
        'label': _labelCtrl.text.trim(),
        'recipient': _recipientCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'full_address': _addressCtrl.text.trim(),
        'is_default': _isDefault,
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      Fluttertoast.showToast(msg: 'Alamat berhasil disimpan');
    } catch (_) {
      Fluttertoast.showToast(msg: 'Gagal menyimpan alamat');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppColors.plumLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
                ),
                const Text('Tambah Alamat Baru', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 18),
                TextFormField(controller: _labelCtrl, decoration: const InputDecoration(labelText: 'Label (Rumah/Kantor)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _recipientCtrl, decoration: const InputDecoration(labelText: 'Nama Penerima'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _addressCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v ?? false),
                  title: const Text('Jadikan alamat utama', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.brand,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Simpan Alamat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
