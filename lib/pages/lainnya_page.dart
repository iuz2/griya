import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LainnyaPage extends StatefulWidget {
    const LainnyaPage({Key? key}) : super(key: key);

    @override
    State<LainnyaPage> createState() => _LainnyaPageState();
}

class _LainnyaPageState extends State<LainnyaPage> {
    bool _isSyncing = false;
    String _selectedTheme = 'Ikuti Sistem';
    bool _notiTagihan = true;
    bool _notiPembayaran = true;
    bool _notiSistem = false;

    // Kunci Konstanta Warna V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);

    Future<void> _handleSync() async {
        setState(() => _isSyncing = true);
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isSyncing = false);

        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('✅ Sinkronisasi pembukuan kos berhasil!'),
                    backgroundColor: Color(0xFF0F766E),
                    duration: Duration(seconds: 2),
                ),
            );
        }
    }

    void _showTemaBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
                return StatefulBuilder(
                    builder: (context, setModalState) {
                        return SafeArea(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                            child: Text('Pilih Tema Tampilan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildThemeOption(context, 'Ikuti Sistem', _selectedTheme, (val) {
                                            setState(() => _selectedTheme = val!);
                                            setModalState(() {});
                                            _applyThemeChange(_selectedTheme);
                                        }),
                                        _buildThemeOption(context, 'Mode Terang', _selectedTheme, (val) {
                                            setState(() => _selectedTheme = val!);
                                            setModalState(() {});
                                            _applyThemeChange(_selectedTheme);
                                        }),
                                        _buildThemeOption(context, 'Mode Gelap', _selectedTheme, (val) {
                                            setState(() => _selectedTheme = val!);
                                            setModalState(() {});
                                            _applyThemeChange(_selectedTheme);
                                        }),
                                    ],
                                ),
                            ),
                        );
                    },
                );
            },
        );
    }

    void _applyThemeChange(String themeMode) {
        String pesan = "Tema berhasil diubah ke ";
        if (themeMode == 'Ikuti Sistem') {
            pesan += "Sinkronisasi Sistem HP";
        } else if (themeMode == 'Mode Terang') {
            pesan += "Tampilan Terang V4";
        } else {
            pesan += "Tampilan Gelap";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(pesan),
                backgroundColor: _tealPrimary,
                duration: const Duration(seconds: 1),
            ),
        );
    }

    Widget _buildThemeOption(BuildContext context, String title, String currentGroup, ValueChanged<String?> onChanged) {
        final isSelected = title == currentGroup;
        return ListTile(
            title: Text(title, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.w400, color: _textSlatePrimary)),
            trailing: isSelected ? Icon(Icons.check_circle_rounded, color: _tealPrimary, size: 22) : null,
            onTap: () {
                onChanged(title);
                Navigator.pop(context);
            },
        );
    }

    void _showNotifikasiBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
                return StatefulBuilder(
                    builder: (context, setModalState) {
                        return SafeArea(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                            child: Text('Pengaturan Notifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                        ),
                                        const SizedBox(height: 10),
                                        SwitchListTile.adaptive(
                                            title: const Text('Notifikasi Tagihan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                                            subtitle: const Text('Pengingat otomatis jatuh tempo kos', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                            activeColor: _tealPrimary,
                                            value: _notiTagihan,
                                            onChanged: (val) {
                                                setState(() => _notiTagihan = val);
                                                setModalState(() {});
                                            },
                                        ),
                                        SwitchListTile.adaptive(
                                            title: const Text('Notifikasi Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                                            subtitle: const Text('Laporan kiriman struk masuk', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                            activeColor: _tealPrimary,
                                            value: _notiPembayaran,
                                            onChanged: (val) {
                                                setState(() => _notiPembayaran = val);
                                                setModalState(() {});
                                            },
                                        ),
                                        SwitchListTile.adaptive(
                                            title: const Text('Notifikasi Sistem', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                                            subtitle: const Text('Pemberitahuan pemeliharaan server', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                            activeColor: _tealPrimary,
                                            value: _notiSistem,
                                            onChanged: (val) {
                                                setState(() => _notiSistem = val);
                                                setModalState(() {});
                                            },
                                        ),
                                    ],
                                ),
                            ),
                        );
                    },
                );
            },
        );
    }

    void _showFAQBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
                return DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    maxChildSize: 0.85,
                    minChildSize: 0.5,
                    expand: false,
                    builder: (context, scrollController) {
                        return SafeArea(
                            child: SingleChildScrollView(
                                controller: scrollController,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text('Pertanyaan Sering Diajukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                        const SizedBox(height: 16),
                                        _buildFAQItem('Bagaimana membuat tagihan?', 'Buka menu Keuangan, klik tombol "+" di pojok kanan bawah, lalu pilih opsi "Buat Tagihan". Isi detail kamar dan nominal sewa.'),
                                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                        _buildFAQItem('Bagaimana memverifikasi pembayaran?', 'Masuk ke menu Keuangan, buka sub-menu "Pembayaran". Klik pada transaksi berstatus pending, periksa bukti lalu tekan tombol "Verifikasi".'),
                                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                        _buildFAQItem('Bagaimana mengubah data kamar?', 'Buka pengaturan Properti di halaman ini, lalu masuk ke sub-menu "Kamar & Fasilitas" untuk memperbarui status keterisian kamar.'),
                                    ],
                                ),
                            ),
                        );
                    },
                );
            },
        );
    }

    Widget _buildFAQItem(String q, String a) {
        return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(q, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                childrenPadding: const EdgeInsets.only(bottom: 12),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(a, style: TextStyle(fontSize: 14, color: _textSlateMuted, height: 1.4, fontWeight: FontWeight.w300))],
            ),
        );
    }

    void _showSupportBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
                return SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    child: Text('Hubungi Layanan Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                ),
                                const SizedBox(height: 10),
                                ListTile(
                                    leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366)),
                                    title: const Text('WhatsApp Support', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                                    subtitle: const Text('Respon cepat keluhan teknis operasional kos', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                    onTap: () => Navigator.pop(context),
                                ),
                                ListTile(
                                    leading: Icon(Icons.email_outlined, color: _tealPrimary),
                                    title: const Text('Email Support', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                                    subtitle: const Text('Kirim dokumen kerjasama formal mitra griya', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                    onTap: () => Navigator.pop(context),
                                ),
                            ],
                        ),
                    ),
                );
            },
        );
    }

    void _showLaporBugDialog() {
        final TextEditingController bugController = TextEditingController();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Laporkan Bug / Kendala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                content: TextField(
                    controller: bugController,
                    maxLines: 4,
                    style: TextStyle(fontSize: 15, color: _textSlatePrimary, fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                        hintText: 'Jelaskan kendala atau error yang Anda temukan...',
                        hintStyle: TextStyle(fontSize: 14, color: _textSlateMuted.withOpacity(0.6)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight, width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
                        contentPadding: const EdgeInsets.all(14),
                    ),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal', style: TextStyle(color: _textSlateMuted, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    ElevatedButton(
                        onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('🚀 Laporan bug dikirim.'), backgroundColor: _tealPrimary),
                            );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _tealPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        child: const Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                ],
            ),
        );
    }

    void _showKeamananBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
                final User? currentUser = FirebaseAuth.instance.currentUser;
                final String userEmail = currentUser?.email ?? 'pemilik.griya@gmail.com';

                return Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Keamanan Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                            const SizedBox(height: 24),
                            _buildKeamananField('Alamat Email Pemilik', userEmail, Icons.mail_outline_rounded),
                            const SizedBox(height: 16),
                            _buildKeamananField('Kata Sandi Akun', '••••••••••••••••', Icons.lock_outline_rounded),
                            const SizedBox(height: 12),
                        ],
                    ),
                );
            },
        );
    }

    Widget _buildKeamananField(String label, String value, IconData icon) {
        return Row(
            children: [
                Icon(icon, size: 18, color: _textSlateMuted),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(label, style: TextStyle(fontSize: 12, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                            const SizedBox(height: 4),
                            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _textSlatePrimary)),
                        ],
                    ),
                ),
                TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero),
                    child: Text('Ubah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tealPrimary)),
                ),
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1), 
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: const Text(
                    'Pengaturan Aplikasi',
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            ),
            body: RefreshIndicator(
                onRefresh: _handleSync,
                color: _tealPrimary,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0), 
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            _buildCardWrapper(
                                child: Column(
                                    children: [
                                        _buildPropertyHeaderInfo(),
                                        const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 16.0),
                                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                        ),
                                        _buildSyncStatusRow(),
                                    ],
                                ),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildCardWrapper(child: _buildExpandableSections()),
                            const SizedBox(height: 80),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildCardWrapper({required Widget child}) {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0), 
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0), 
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: child,
        );
    }

    Widget _buildPropertyHeaderInfo() {
        return Row(
            children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('PROPERTI AKTIF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _textSlateMuted, letterSpacing: 0.5)),
                            const SizedBox(height: 4),
                            Text('Griya Utama', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                            const SizedBox(height: 6),
                            Text('15 Kamar • 13 Terisi (87% Okupansi)', style: TextStyle(fontSize: 14, color: _tealPrimary, fontWeight: FontWeight.w400)),
                        ],
                    ),
                ),
                TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9), 
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Ganti', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _tealPrimary)),
                ),
            ],
        );
    }

    Widget _buildSyncStatusRow() {
        return Row(
            children: [
                _isSyncing
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: _tealPrimary, strokeWidth: 2))
                    : Icon(Icons.verified_user_rounded, color: _tealPrimary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        _isSyncing ? 'Mengunduh data buku kas...' : 'Terakhir sinkronisasi: Hari ini 15:32',
                        style: TextStyle(fontSize: 13, color: _textSlateMuted, fontWeight: FontWeight.w400),
                    ),
                ),
                if (!_isSyncing)
                    InkWell(
                        onTap: _handleSync,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.sync_rounded, size: 20, color: _tealPrimary),
                        ),
                    ),
            ],
        );
    }

    Widget _buildExpandableSections() {
        return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
                children: [
                    _buildAccordionItem('Manajemen Akun', Icons.person_outline_rounded, [
                        _buildSubMenuItem('Profil Pemilik', () {}),
                        _buildSubMenuItem('Keamanan & Password', _showKeamananBottomSheet),
                    ]),
                    _buildAccordionDivider(),
                    _buildAccordionItem('Pengaturan Properti', Icons.business_outlined, [
                        _buildSubMenuItem('Informasi Dasar Kos', () {}),
                        _buildSubMenuItem('Kamar & Fasilitas', () {}),
                    ]),
                    _buildAccordionDivider(),
                    _buildAccordionItem('Sistem & Aplikasi', Icons.tune_rounded, [
                        _buildSubMenuItem('Notifikasi Otomatis', _showNotifikasiBottomSheet),
                        _buildSubMenuItem('Tema Tampilan', _showTemaBottomSheet),
                    ]),
                    _buildAccordionDivider(),
                    _buildAccordionItem('Pusat Bantuan', Icons.help_outline_rounded, [
                        _buildSubMenuItem('FAQ / Tanya Jawab', _showFAQBottomSheet),
                        _buildSubMenuItem('Hubungi Tim Support', _showSupportBottomSheet),
                        _buildSubMenuItem('Laporkan Kendala Bug', _showLaporBugDialog),
                    ]),
                    _buildAccordionDivider(),
                    _buildAccordionItem('Informasi Lainnya', Icons.info_outline_rounded, [
                        _buildSubMenuItem('Kebijakan Privasi', () {}),
                        ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            title: const Text('Logout Akun Pemilik', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFFEF4444))),
                            trailing: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFEF4444)),
                            onTap: _showLogoutConfirmation,
                        ),
                    ]),
                ],
            ),
        );
    }

    Widget _buildAccordionItem(String title, IconData icon, List<Widget> children) {
        return ExpansionTile(
            dense: true,
            tilePadding: EdgeInsets.zero,
            leading: Icon(icon, color: _tealPrimary, size: 20),
            title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
            iconColor: _tealPrimary,
            collapsedIconColor: _textSlateMuted,
            children: children, // KOREKSI SINTAKS: Titik koma sudah diganti tanda kurung tutup penutup parameter aman
        );
    }

    Widget _buildSubMenuItem(String label, VoidCallback? onTap) {
        return ListTile(
            onTap: onTap,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(label, style: TextStyle(fontSize: 14, color: _textSlatePrimary, fontWeight: FontWeight.w400)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 11, color: _textSlateMuted.withOpacity(0.5)),
        );
    }

    Widget _buildAccordionDivider() {
        return const Divider(height: 1, color: Color(0xFFF1F5F9));
    }

    void _showLogoutConfirmation() {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Logout Akun?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                content: Text('Anda akan keluar dari sistem manajemen kos Griya dan harus memasukkan email kembali.', style: TextStyle(fontSize: 14, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal', style: TextStyle(color: _textSlateMuted, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                            Navigator.pop(context);
                            try {
                                await FirebaseAuth.instance.signOut();
                                if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: const Text('🔒 Berhasil keluar dari akun.'),
                                            backgroundColor: _tealPrimary,
                                        ),
                                    );
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                }
                            } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Gagal melakukan logout.'),
                                        backgroundColor: Colors.redAccent,
                                    ),
                                );
                            }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                ],
            ),
        );
    }
}
