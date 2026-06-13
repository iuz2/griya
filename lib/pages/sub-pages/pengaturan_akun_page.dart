import 'package:flutter/material.dart';

class PengaturanAkunPage extends StatefulWidget {
    const PengaturanAccountsPage({Key? key}) : super(key: key);

    // Memperbaiki typo prapasang nama kelas agar konsisten saat dipanggil
    @override
    State<PengaturanAkunPage> createState() => _PengaturanAkunPageState();
}

class _PengaturanAkunPageState extends State<PengaturanAkunPage> {
    final TextEditingController _etNamaKos = TextEditingController();
    
    // Mock Data Email (Nanti otomatis ditarik dari FirebaseAuth.instance.currentUser?.email)
    final String _userEmail = "twilight.software@gmail.com";

    @override
    void initState() {
        super.initState();
        // Set data awal dummy untuk nama kos
        _etNamaKos.text = "Griya Berkah Utama";
    }

    @override
    void dispose() {
        _etNamaKos.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC), // Latar Slate 50 bersih
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
                    onPressed: () => Navigator.pop(context),
                ),
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                        Text(
                            "Pengaturan Akun",
                            style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFF0F172A)
                            ),
                        ),
                        SizedBox(height: 2),
                        Text(
                            "• Data Tersinkronisasi",
                            style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFF10B981) // Hijau Emerald Sukses
                            ),
                        ),
                    ],
                ),
                centerTitle: true,
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            ),
            body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    children: [
                        _buildFormAkunCard(),
                        const SizedBox(height: 16),
                        _buildAksiAkunCard(),
                    ],
                ),
            ),
        );
    }

    // =========================================================================
    // 1. CARD UTAMA: DETAIL EMAIL & FORM NAMA KOS
    // =========================================================================
    Widget _buildFormAkunCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        "Email Akun Terdaftar",
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        _userEmail,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                        "Nama Kos / Properti",
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    
                    // Input Field Flat Modern
                    Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                            controller: _etNamaKos,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration(
                                hintText: "Masukkan Nama Kos",
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                prefixIcon: Icon(Icons.corporate_fare_rounded, color: Color(0xFF64748B), size: 20),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            ),
                        ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tombol Simpan Perubahan Utama
                    ElevatedButton(
                        onPressed: () {
                            // Logika Firebase Firestore update data nama instansi kos
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669), // Emerald
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                        child: const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        );
    }

    // =========================================================================
    // 2. CARD AKSI Tambahan: RESET PASSWORD & LOGOUT
    // =========================================================================
    Widget _buildAksiAkunCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
                children: [
                    // Tombol Reset Password (Outline Soft Blue)
                    OutlinedButton(
                        onPressed: () {
                            // Logika kirim email reset password FirebaseAuth
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                        child: const Text("RESET KATA SANDI", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tombol Logout (Flat Soft Red Danger Indicator)
                    ElevatedButton(
                        onPressed: () {
                            // Logika FirebaseAuth.instance.signOut() lalu kick ke LoginPage
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2), // Latar merah super soft
                            foregroundColor: const Color(0xFFEF4444), // Teks merah tegas
                            elevation: 0,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                                side: const BorderSide(color: Color(0xFFFEE2E2), width: 1),
                            ),
                        ),
                        child: const Text("KELUAR (LOGOUT)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        );
    }
}
