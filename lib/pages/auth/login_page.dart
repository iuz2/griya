import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({Key? key}) : super(key: key);

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    
    bool _isPasswordObscured = true;
    bool _isPageAnimate = false;
    bool _isLoading = false;

    // Batasan Konstanta Warna V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);
    final Color _errorColor = const Color(0xFFEF4444);

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
                _isPageAnimate = true;
            });
        });
    }

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    void _handleLogin() async {
        if (!_formKey.currentState!.validate()) return;

        setState(() => _isLoading = true);

        try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
            );
            
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('🔓 Selamat Datang Kembali!'), backgroundColor: _tealPrimary),
                );
            }
        } on FirebaseAuthException catch (e) {
            String pesanError = "Terjadi kesalahan masuk.";
            if (e.code == 'user-not-found') {
                pesanError = "Email tidak terdaftar.";
            } else if (e.code == 'wrong-password') {
                pesanError = "Kata sandi yang Anda masukkan salah.";
            } else if (e.code == 'invalid-email') {
                pesanError = "Format alamat email tidak sah.";
            }
            _showSnackBar(pesanError, _errorColor);
        } catch (e) {
            _showSnackBar(e.toString(), _errorColor);
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
            body: SafeArea(
                child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _isPageAnimate ? 1.0 : 0.0,
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                            return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Form(
                                    key: _formKey,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                            const SizedBox(height: 40),
                                            
                                            // ========================================== HEADER LOGO
                                            Center(
                                                child: Container(
                                                    width: 64,
                                                    height: 64,
                                                    decoration: BoxDecoration(
                                                        color: _tealPrimary.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.corporate_fare_rounded, color: _tealPrimary, size: 32),
                                                ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                                'Griya',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _tealPrimary, letterSpacing: 0.5),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                                'Aplikasi Manajemen Kos & Properti Sewa',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textSlateMuted),
                                            ),
                                            
                                            const SizedBox(height: 40),
                                            Text(
                                                'Selamat Datang',
                                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textSlatePrimary),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                'Silakan masuk untuk mengelola properti Anda dengan mudah dan cepat.',
                                                style: TextStyle(fontSize: 14, color: _textSlateMuted, height: 1.4),
                                            ),
                                            
                                            const SizedBox(height: 32),
                                            
                                            // ========================================== INPUT INPUT FIELD
                                            TextFormField(
                                                controller: _emailController,
                                                keyboardType: TextInputType.emailAddress,
                                                style: TextStyle(fontSize: 15, color: _textSlatePrimary, fontWeight: FontWeight.w400),
                                                decoration: InputDecoration(
                                                    labelText: 'Alamat Email',
                                                    labelStyle: TextStyle(color: _textSlateMuted, fontSize: 14),
                                                    prefixIcon: Icon(Icons.email_outlined, color: _textSlateMuted, size: 20),
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _borderSlateLight, width: 1.2)),
                                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
                                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _errorColor, width: 1.2)),
                                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _errorColor, width: 1.5)),
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                ),
                                                validator: (value) {
                                                    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
                                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Format email tidak valid';
                                                    return null;
                                                },
                                            ),
                                            const SizedBox(height: 16),
                                            
                                            TextFormField(
                                                controller: _passwordController,
                                                obscureText: _isPasswordObscured,
                                                style: TextStyle(fontSize: 15, color: _textSlatePrimary, fontWeight: FontWeight.w400),
                                                decoration: InputDecoration(
                                                    labelText: 'Kata Sandi Keamanan',
                                                    labelStyle: TextStyle(color: _textSlateMuted, fontSize: 14),
                                                    prefixIcon: Icon(Icons.lock_outlined, color: _textSlateMuted, size: 20),
                                                    suffixIcon: IconButton(
                                                        icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textSlateMuted, size: 20),
                                                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                                                    ),
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _borderSlateLight, width: 1.2)),
                                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
                                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _errorColor, width: 1.2)),
                                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: _errorColor, width: 1.5)),
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                ),
                                                validator: (value) {
                                                    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                                                    if (value.length < 6) return 'Password minimal 6 karakter';
                                                    return null;
                                                },
                                            ),
                                            
                                            const SizedBox(height: 32),
                                            
                                            // ========================================== ELEVATED TOMBOL MASUK
                                            SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                    onPressed: _isLoading ? null : _handleLogin,
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: _tealPrimary,
                                                        foregroundColor: Colors.white,
                                                        elevation: 0,
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                    ),
                                                    child: _isLoading 
                                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                                        : const Text('Masuk Ke Aplikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                                                ),
                                            ),
                                            
                                            const SizedBox(height: 24),
                                            
                                            // ========================================== REGISTER TRIGGER
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    Text('Belum memiliki akun? ', style: TextStyle(color: _textSlateMuted, fontSize: 14)),
                                                    GestureDetector(
                                                        onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                                                            );
                                                        },
                                                        child: Text('Daftar Sekarang', style: TextStyle(color: _tealPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                                    ),
                                                ],
                                            ),
                                            
                                            // KOREKSI AMAN: Spacer() dicopot, diganti SizedBox statis sebagai peredam desakan keyboard HP
                                            const SizedBox(height: 40), 
                                            
                                            // ========================================== FOOTER DIBAWAH
                                            Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(color: _borderSlateLight, width: 1.2),
                                                ),
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        Icon(Icons.shield_outlined, size: 18, color: _tealPrimary),
                                                        const SizedBox(width: 8),
                                                        Flexible(
                                                            child: Text(
                                                                'Data properti Anda tersimpan aman & terenkripsi', 
                                                                style: TextStyle(fontSize: 12, color: _textSlateMuted, fontWeight: FontWeight.w500),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(height: 24),
                                        ],
                                    ),
                                ),
                            );
                        },
                    ),
                ),
            ),
        );
    }
}
