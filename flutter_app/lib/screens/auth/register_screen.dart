import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../home/main_nav_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScreen()), (route) => false,
      );
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : 'Gagal mendaftar. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buat Akun Baru', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24)),
                const SizedBox(height: 6),
                const Text('Isi data dirimu untuk mulai belanja', style: TextStyle(color: AppColors.plumLight, fontSize: 14)),
                const SizedBox(height: 24),
                if (_error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: const TextStyle(color: AppColors.brandDark, fontSize: 13)),
                  ),
                _label('Nama Lengkap'),
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Jane Doe'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null),
                const SizedBox(height: 14),
                _label('Email'),
                TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'nama@email.com'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null),
                const SizedBox(height: 14),
                _label('Nomor Telepon'),
                TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: '08xxxxxxxxxx')),
                const SizedBox(height: 14),
                _label('Password'),
                TextFormField(controller: _passCtrl, obscureText: true,
                  decoration: const InputDecoration(hintText: 'Minimal 6 karakter'),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Daftar'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );
}
