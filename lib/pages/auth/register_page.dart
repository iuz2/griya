import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
    const RegisterPage({Key? key}) : super(key: key);

    @override
    State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
    final AuthService _authService = AuthService();

    final TextEditingController _namaKosController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    
    bool _isLoading = false;

    // WARNA TETAP FINAL (NON-STATIC CONST AMAN)
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);

    @override
    void dispose() {
        _namaKosController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    void _handleRegister() async {
        final String namaKos = _namaKosController.text.trim();
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();

        if (namaKos.isEmpty || email.isEmpty || password.isEmpty) {
            _showSnackBar("Lengkapi semua data input!", Colors.redAccent);
            return;
        }

        setState(() => _isLoading = true);

        try {
            String? suksesKodePublik = await _authService.registerOwner(
                namaKos: namaKos,
                email: email,
                password: password,
            );

            if (suksesKodePublik != null) {
                _showSnackBar("Daftar Berhasil!\nKode publik: $suksesKodePublik", _tealPrimary);
                if (mounted) Navigator.pop(context);
            }
        } catch (error) {
            _showSnackBar(error.toString(), Colors.redAccent);
        } finally {
            if (mounted) setState(() => _isLoading = false);
        }
    }

    void _showSnackBar(String message, Color bgColor) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                backgroundColor: bgColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1), 
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: Text('Registrasi Akun Baru', style: TextStyle(color: _textSlatePrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                centerTitle: true,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textSlatePrimary, size: 18),
                    onPressed: () => Navigator.pop(context),
                ),
            ),
            body: Center(
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.0), 
                            border: Border.all(color: _borderSlateLight, width: 1.2),
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildFieldLabel("Nama Properti Kos"),
                                _buildTextField(controller: _namaKosController, hint: "Masukkan nama kos Anda...", icon: Icons.business_rounded),
                                const SizedBox(height: 14),
                                
                                _buildFieldLabel("Alamat Email"),
                                _buildTextField(controller: _emailController, hint: "Contoh: pemilik@gmail.com", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                                const SizedBox(height: 14),
                                
                                _buildFieldLabel("Kata Sandi Keamanan"),
                                _buildTextField(controller: _passwordController, hint: "Minimal 6 karakter...", icon: Icons.lock_outline_rounded, isObscure: true),
                                const SizedBox(height: 24),
                                
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: _isLoading ? null : _handleRegister,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: _tealPrimary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: _isLoading 
                                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                            : const Text("Daftarkan Akun Properti", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                    ),
                                ),
                                const SizedBox(height: 16),
                                
                                Center(
                                    child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Sudah punya akun? Masuk di sini", style: TextStyle(color: _tealPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildFieldLabel(String label) {
        return Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
            child: Text(label, style: TextStyle(fontSize: 14, color: _textSlateMuted, fontWeight: FontWeight.w400)),
        );
    }

    Widget _buildTextField({
        required TextEditingController controller,
        required String hint,
        required IconData icon,
        bool isObscure = false,
        TextInputType keyboardType = TextInputType.text,
    }) {
        return TextField(
            controller: controller,
            obscureText: isObscure,
            keyboardType: keyboardType,
            style: TextStyle(color: _textSlatePrimary, fontSize: 15, fontWeight: FontWeight.w400),
            cursorColor: _tealPrimary,
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(icon, color: _textSlateMuted, size: 20),
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _borderSlateLight, width: 1.2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
            ),
        );
    }
}
