import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
    const RegisterPage({Key? key}) : super(key: key);

    @override
    State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
    final TextEditingController _etEmailReg = TextEditingController();
    final TextEditingController _etNamaKos = TextEditingController();
    final TextEditingController _etPassReg = TextEditingController();
    bool _isPasswordObscured = true; // State pengontrol sembunyikan password

    @override
    void dispose() {
        _etEmailReg.dispose();
        _etNamaKos.dispose();
        _etPassReg.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.white, // Latar belakang putih bersih sesuai XML asli
            body: SafeArea(
                child: Center(
                    child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildTitleText(),
                                const SizedBox(height: 40),
                                _buildFlatInputField(
                                    controller: _etEmailReg,
                                    hint: "Email Baru",
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                ),
                                _buildFlatInputField(
                                    controller: _etNamaKos,
                                    hint: "Nama Kos / Properti",
                                    icon: Icons.corporate_fare_rounded,
                                    keyboardType: TextInputType.text,
                                ),
                                _buildPasswordInputField(),
                                const SizedBox(height: 16),
                                _buildRegisterButton(),
                                const SizedBox(height: 24),
                                _buildLoginNavigationLink(),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    // Judul & Sub-judul Registrasi Modern M3
    Widget _buildTitleText() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
                Text(
                    "Daftar Akun",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1.0,
                    ),
                ),
                SizedBox(height: 6),
                Text(
                    "Kelola kos Anda lebih profesional",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                    ),
                ),
            ],
        );
    }

    // Builder Input Text Field Flat (Email & Nama Kos)
    Widget _buildFlatInputField({
        required TextEditingController controller,
        required String hint,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
    }) {
        return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Slate 50 soft fill
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                ),
            ),
        );
    }

    // Input Field Khusus Password dengan Saklar Lihat/Sembunyikan
    Widget _buildPasswordInputField() {
        return Container(
            margin: const EdgeInsets.only(bottom: 28.0),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
                controller: _etPassReg,
                obscureText: _isPasswordObscured,
                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                    hintText: "Password Baru",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                    suffixIcon: IconButton(
                        icon: Icon(
                            _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF64748B),
                            size: 20,
                        ),
                        onPressed: () {
                            setState(() {
                                _isPasswordObscured = !_isPasswordObscured;
                            });
                        },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                ),
            ),
        );
    }

    // Tombol Registrasi Utama Berwarna Tema Emerald
    Widget _buildRegisterButton() {
        return ElevatedButton(
            onPressed: () {
                // Alur pembuatan user baru di Firebase Auth & Firestore dilempar di sini nanti
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669), // Emerald Utama
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
            ),
            child: const Text(
                "DAFTAR SEKARANG",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
        );
    }

    // Tautan Navigasi untuk Kembali ke LoginPage jika Sudah Punya Akun
    Widget _buildLoginNavigationLink() {
        return Center(
            child: TextButton(
                onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman Login
                },
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    splashFactory: NoSplash.splashFactory,
                ),
                child: const Text(
                    "Sudah punya akun? Masuk",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
            ),
        );
    }
}
