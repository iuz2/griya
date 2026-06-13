import 'package:flutter/material.dart';

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

    @override
    void initState() {
        super.initState();
        // Memicu animasi fade-in setelah frame pertama dirender
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

    @override
    Widget build(BuildContext context) {
        // Warna sesuai Bahasa Desain Griya
        const Color primaryColor = Color(0xFF1976D2);
        const Color secondaryColor = Color(0xFF455A64); // Blue Gray
        const Color backgroundColor = Colors.white;
        const Color errorColor = Color(0xFFD32F2F);

        return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
                child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _isPageAnimate ? 1.0 : 0.0,
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                            return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                    ),
                                    child: IntrinsicHeight(
                                        child: Form(
                                            key: _formKey,
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                    const SizedBox(height: 40),
                                                    
                                                    // ========================================== HEADER & BRANDING
                                                    Center(
                                                        child: Container(
                                                            width: 64,
                                                            height: 64,
                                                            decoration: BoxDecoration(
                                                                color: primaryColor.withOpacity(0.1),
                                                                shape: BoxShape.circle,
                                                            ),
                                                            child: const Icon(
                                                                Icons.corporate_fare_rounded,
                                                                color: primaryColor,
                                                                size: 32,
                                                            ),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                        'Griya',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.bold,
                                                            color: primaryColor,
                                                            letterSpacing: 0.5,
                                                        ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    const Text(
                                                        'Aplikasi Manajemen Kos & Properti Sewa',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                            color: secondaryColor,
                                                        ),
                                                    ),
                                                    
                                                    const SizedBox(height: 40),
                                                    
                                                    // ========================================== WELCOME SECTION
                                                    const Text(
                                                        'Selamat Datang',
                                                        style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF212121),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                        'Silakan masuk untuk mengelola properti Anda dengan mudah dan cepat.',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: secondaryColor,
                                                            height: 1.4,
                                                        ),
                                                    ),
                                                    
                                                    const SizedBox(height: 32),
                                                    
                                                    // ========================================== FORM LOGIN
                                                    // Field Email
                                                    TextFormField(
                                                        controller: _emailController,
                                                        keyboardType: TextInputType.emailAddress,
                                                        style: const TextStyle(fontSize: 16, color: Color(0xFF212121)),
                                                        decoration: InputDecoration(
                                                            labelText: 'Email',
                                                            labelStyle: const TextStyle(color: secondaryColor, fontSize: 14),
                                                            prefixIcon: const Icon(Icons.email_outlined, color: secondaryColor),
                                                            border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: primaryColor, width: 2),
                                                            ),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: errorColor, width: 1),
                                                            ),
                                                            focusedErrorBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: errorColor, width: 2),
                                                            ),
                                                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                                        ),
                                                        validator: (value) {
                                                            if (value == null || value.trim().isEmpty) {
                                                                return 'Email tidak boleh kosong';
                                                            }
                                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                                                return 'Format email tidak valid';
                                                            }
                                                            return null;
                                                        },
                                                    ),
                                                    const SizedBox(height: 20),
                                                    
                                                    // Field Password
                                                    TextFormField(
                                                        controller: _passwordController,
                                                        obscureText: _isPasswordObscured,
                                                        style: const TextStyle(fontSize: 16, color: Color(0xFF212121)),
                                                        decoration: InputDecoration(
                                                            labelText: 'Password',
                                                            labelStyle: const TextStyle(color: secondaryColor, fontSize: 14),
                                                            prefixIcon: const Icon(Icons.lock_outlined, color: secondaryColor),
                                                            suffixIcon: IconButton(
                                                                icon: Icon(
                                                                    _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                                                    color: secondaryColor,
                                                                ),
                                                                onPressed: () {
                                                                    setState(() {
                                                                        _isPasswordObscured = !_isPasswordObscured;
                                                                    });
                                                                },
                                                            ),
                                                            border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: primaryColor, width: 2),
                                                            ),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: errorColor, width: 1),
                                                            ),
                                                            focusedErrorBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                                borderSide: const BorderSide(color: errorColor, width: 2),
                                                            ),
                                                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                                        ),
                                                        validator: (value) {
                                                            if (value == null || value.isEmpty) {
                                                                return 'Password tidak boleh kosong';
                                                            }
                                                            if (value.length < 6) {
                                                                return 'Password minimal 6 karakter';
                                                            }
                                                            return null;
                                                        },
                                                    ),
                                                    
                                                    const SizedBox(height: 32),
                                                    
                                                    // ========================================== ACTION SECTION
                                                    ElevatedButton(
                                                        onPressed: () {
                                                            if (_formKey.currentState!.validate()) {
                                                                // Eksekusi Logika Login Backend Anda di sini
                                                            }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor: primaryColor,
                                                            foregroundColor: Colors.white,
                                                            elevation: 0,
                                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                            ),
                                                        ),
                                                        child: const Text(
                                                            'Masuk Ke Aplikasi',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                letterSpacing: 0.3,
                                                            ),
                                                        ),
                                                    ),
                                                    
                                                    const SizedBox(height: 24),
                                                    
                                                    // ========================================== SECONDARY ACTION
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            const Text(
                                                                'Belum memiliki akun? ',
                                                                style: TextStyle(color: secondaryColor, fontSize: 14),
                                                            ),
                                                            GestureDetector(
                                                                onPressed: () {
                                                                    // Eksekusi Navigasi Daftar Akun Anda di sini
                                                                },
                                                                child: const Text(
                                                                    'Daftar Sekarang',
                                                                    style: TextStyle(
                                                                        color: primaryColor,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 14,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                    
                                                    const Spacer(),
                                                    const SizedBox(height: 24),
                                                    
                                                    // ========================================== BOTTOM INFO
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                        decoration: BoxDecoration(
                                                            color: const Color(0xFFF5F7F8),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(color: const Color(0xFFECEFF1), width: 1),
                                                        ),
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: const [
                                                                Icon(Icons.shield_outlined, size: 18, color: secondaryColor),
                                                                SizedBox(width: 8),
                                                                Text(
                                                                    'Data properti Anda tersimpan aman & terenkripsi',
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: secondaryColor,
                                                                        fontWeight: FontWeight.w500,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                ],
                                            ),
                                        ),
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
