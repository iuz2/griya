import 'package:flutter/material.dart';

class LainnyaPage extends StatefulWidget {
    const LainnyaPage({Key? key}) : super(key: key);

    @override
    State<LainnyaPage> createState() => _LainnyaPageState();
}

class _LainnyaPageState extends State<LainnyaPage> {
    bool _isSyncing = false;

    // State Lokal Aplikasi (Revisi 3 & 4)
    String _selectedTheme = 'Ikuti Sistem';
    bool _notiTagihan = true;
    bool _notiPembayaran = true;
    bool _notiSistem = false;

    // Palet Warna Griya Premium Minimalis
    final Color _primaryColor = const Color(0xFF1A73E8);
    final Color _bgColor = const Color(0xFFF8F9FA);
    final Color _borderColor = const Color(0xFFE8EAED);
    final Color _textPrimary = const Color(0xFF202124);
    final Color _textSecondary = const Color(0xFF5F6368);
    final Color _successColor = const Color(0xFF34A853);
    final Color _errorColor = const Color(0xFFEA4335);

    Future<void> _handleSync() async {
        setState(() => _isSyncing = true);
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isSyncing = false);

        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: const Text('✅ Sinkronisasi berhasil!'),
                    backgroundColor: _successColor,
                    duration: const Duration(seconds: 2),
                ),
            );
        }
    }

    // REVISI 3: Fungsikan Menu Tema via BottomSheet Modern
    void _showTemaBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                                            child: Text('Pilih Tema Aplikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildThemeOption(context, 'Ikuti Sistem', _selectedTheme, (val) {
                                            setState(() => _selectedTheme = val!);
                                            setModalState(() {});
                                        }),
                                        _buildThemeOption(context, 'Mode Terang', _selectedTheme, (val) {
                                            setState(() => _selectedTheme = val!);
                                            setModalState(() {});
                                        }),
                                        _buildThemeOption(context, 'Mode Gelap', _selectedTheme, (val) {
                                            setState(() => _selectedTheme = val!);
                                            setModalState(() {});
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

    Widget _buildThemeOption(BuildContext context, String title, String currentGroup, ValueChanged<String?> onChanged) {
        final isSelected = title == currentGroup;
        return ListTile(
            title: Text(title, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: _textPrimary)),
            trailing: isSelected ? Icon(Icons.check_circle_rounded, color: _primaryColor, size: 22) : Radio<String>(
                value: title,
                groupValue: currentGroup,
                activeColor: _primaryColor,
                onChanged: (val) {
                    onChanged(val);
                    Navigator.pop(context);
                },
            ),
            onTap: () {
                onChanged(title);
                Navigator.pop(context);
            },
        );
    }

    // REVISI 4: Fungsikan Menu Notifikasi via BottomSheet Switch Modern
    void _showNotifikasiBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                                            child: Text('Pengaturan Notifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                                        ),
                                        const SizedBox(height: 8),
                                        SwitchListTile(
                                            title: const Text('Notifikasi Tagihan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                            subtitle: const Text('Pengingat otomatis jatuh tempo kos', style: TextStyle(fontSize: 12)),
                                            activeColor: _primaryColor,
                                            value: _notiTagihan,
                                            onChanged: (val) {
                                                setState(() => _notiTagihan = val);
                                                setModalState(() {});
                                            },
                                        ),
                                        SwitchListTile(
                                            title: const Text('Notifikasi Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                            subtitle: const Text('Laporan kiriman struk masuk dari penyewa', style: TextStyle(fontSize: 12)),
                                            activeColor: _primaryColor,
                                            value: _notiPembayaran,
                                            onChanged: (val) {
                                                setState(() => _notiPembayaran = val);
                                                setModalState(() {});
                                            },
                                        ),
                                        SwitchListTile(
                                            title: const Text('Notifikasi Sistem', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                            subtitle: const Text('Pemberitahuan pemeliharaan server', style: TextStyle(fontSize: 12)),
                                            activeColor: _primaryColor,
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

    // REVISI 5: Fungsikan Menu FAQ menggunakan Efek Accordion Di Dalam BottomSheet
    void _showFAQBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                                        Text('Pertanyaan Sering Diajukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                                        const SizedBox(height: 16),
                                        _buildFAQItem('Bagaimana membuat tagihan?', 'Buka menu Keuangan, klik tombol "+" di pojok kanan bawah, lalu pilih opsi "Buat Tagihan". Isi detail kamar dan nominal sewa.'),
                                        _buildFAQItem('Bagaimana memverifikasi pembayaran?', 'Masuk ke menu Keuangan, buka sub-menu "Pembayaran". Klik pada transaksi berstatus pending, periksa bukti lalu tekan tombol "Verifikasi".'),
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
                title: Text(q, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textPrimary)),
                childrenPadding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(a, style: TextStyle(fontSize: 13, color: _textSecondary, height: 1.4))],
            ),
        );
    }

    // REVISI 6: Fungsikan Menu Hubungi Support via BottomSheet Opsi
    void _showSupportBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                                    child: Text('Hubungi Layanan Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                                ),
                                const SizedBox(height: 8),
                                ListTile(
                                    leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366)),
                                    title: const Text('WhatsApp Support', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    subtitle: const Text('Respon cepat keluhan teknis operasional kos', style: TextStyle(fontSize: 12)),
                                    onTap: () => Navigator.pop(context),
                                ),
                                ListTile(
                                    leading: Icon(Icons.email_outlined, color: _primaryColor),
                                    title: const Text('Email Support', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    subtitle: const Text('Kirim dokumen kerjasama formal mitra griya', style: TextStyle(fontSize: 12)),
                                    onTap: () => Navigator.pop(context),
                                ),
                            ],
                        ),
                    ),
                );
            },
        );
    }

    // REVISI 7: Fungsikan Lapor Bug Menggunakan Dialog Form Masukan Multi-Line
    void _showLaporBugDialog() {
        final TextEditingController bugController = TextEditingController();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text('Laporkan Bug / Kendala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                content: TextField(
                    controller: bugController,
                    maxLines: 4,
                    style: TextStyle(fontSize: 14, color: _textPrimary),
                    decoration: InputDecoration(
                        hintText: 'Jelaskan kendala atau error yang Anda temukan...',
                        hintStyle: TextStyle(fontSize: 13, color: _textSecondary.withOpacity(0.6)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryColor)),
                        contentPadding: const EdgeInsets.all(12),
                    ),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal', style: TextStyle(color: _textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                        onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('🚀 Laporan bug berhasil dikirim. Terima kasih!'), backgroundColor: _primaryColor),
                            );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        );
    }

    // REVISI 9: Fungsikan Menu Keamanan Tergabung Gabungan Email & Password
    void _showKeamananBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            builder: (context) {
                return Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Keamanan Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                            const SizedBox(height: 20),
                            _buildKeamananField('Alamat Email', 'pemilik.griya@gmail.com', Icons.mail_outline_rounded),
                            const SizedBox(height: 14),
                            _buildKeamananField('Kata Sandi', '••••••••••••••••', Icons.lock_outline_rounded, isObscured: true),
                            const SizedBox(height: 14),
                            Row(
                                children: [
                                    Icon(Icons.verified_user_rounded, color: _successColor, size: 16),
                                    const SizedBox(width: 6),
                                    Text('Akun Terverifikasi Komunitas', style: TextStyle(fontSize: 12, color: _successColor, fontWeight: FontWeight.bold)),
                                ],
                            ),
                            const SizedBox(height: 12),
                        ],
                    ),
                );
            },
        );
    }

    Widget _buildKeamananField(String label, String value, IconData icon, {bool isObscured = false}) {
        return Row(
            children: [
                Icon(icon, size: 18, color: _textSecondary),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(label, style: TextStyle(fontSize: 11, color: _textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textPrimary)),
                        ],
                    ),
                ),
                TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text('Ubah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryColor)),
                ),
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 1,
                title: Text(
                    'Lainnya',
                    style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                ),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(color: _borderColor, height: 1),
                ),
            ),
            body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: _handleSync,
                    color: _primaryColor,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildPropertyCard(),
                                const SizedBox(height: 12),
                                _buildSyncStatusCard(),
                                const SizedBox(height: 24),
                                _buildExpandableSections(),
                                const SizedBox(height: 32),
                                _buildLogoutButton(),
                                const SizedBox(height: 24),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    // REVISI 10: Perbaikan Kartu Properti Aktif (Ditambahkan Kamar Terisi & Persentase Okupansi)
    Widget _buildPropertyCard() {
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
                boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
                children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: _primaryColor.withOpacity(0.08), shape: BoxShape.circle),
                        child: Icon(Icons.home_work_rounded, color: _primaryColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text('PROPERTI AKTIF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.5)),
                                const SizedBox(height: 2),
                                Text('Griya Utama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: -0.2)),
                                const SizedBox(height: 4),
                                FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                        '15 Kamar • 13 Terisi (87% Hunian)',
                                        style: TextStyle(fontSize: 12, color: _successColor, fontWeight: FontWeight.w600),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), backgroundColor: _bgColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                        child: Text('Switch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryColor)),
                    ),
                ],
            ),
        );
    }

    // REVISI 11: Indikator Sinkronisasi Lebih Informatif & Sederhana Premium
    Widget _buildSyncStatusCard() {
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
            ),
            child: Row(
                children: [
                    _isSyncing
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _primaryColor, strokeWidth: 2.5))
                        : Icon(Icons.check_circle_rounded, color: _successColor, size: 26),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(_isSyncing ? 'Sedang Sinkronisasi...' : 'Data Tersinkronisasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textPrimary)),
                                const SizedBox(height: 2),
                                Text(_isSyncing ? 'Mengunduh pembukuan kos terbaru' : 'Sinkronisasi Terakhir: Hari ini 15:32', style: TextStyle(fontSize: 12, color: _textSecondary)),
                            ],
                        ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                        onPressed: _isSyncing ? null : _handleSync,
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _isSyncing ? _borderColor : _successColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                        ),
                        child: Row(
                            children: [
                                Icon(Icons.sync_rounded, size: 14, color: _isSyncing ? _textSecondary : _successColor),
                                const SizedBox(width: 4),
                                Text('Sync', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isSyncing ? _textSecondary : _successColor)),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    // REVISI 1 & 2: Sederhanakan Struktur Menu 5 Klasifikasi Esensial Tetap Accordion
    Widget _buildExpandableSections() {
        return Column(
            children: [
                _buildSection(
                    title: 'AKUN',
                    icon: Icons.person_outline_rounded,
                    isExpanded: true,
                    items: [
                        _buildMenuItem(icon: Icons.account_circle_outlined, title: 'Profil', onTap: () {}),
                        _buildMenuItem(icon: Icons.shield_outlined, title: 'Keamanan', onTap: _showKeamananBottomSheet),
                    ],
                ),
                const SizedBox(height: 12),
                _buildSection(
                    title: 'PROPERTI',
                    icon: Icons.business_outlined,
                    items: [
                        _buildMenuItem(icon: Icons.info_outline_rounded, title: 'Informasi Properti', onTap: () {}),
                        _buildMenuItem(icon: Icons.king_bed_outlined, title: 'Kamar & Fasilitas', onTap: () {}),
                    ],
                ),
                const SizedBox(height: 12),
                _buildSection(
                    title: 'APLIKASI',
                    icon: Icons.tune_rounded,
                    items: [
                        _buildMenuItem(icon: Icons.sync_rounded, title: 'Sinkronisasi Data', onTap: _handleSync),
                        _buildMenuItem(icon: Icons.notifications_none_rounded, title: 'Notifikasi', onTap: _showNotifikasiBottomSheet),
                        _buildMenuItem(icon: Icons.palette_outlined, title: 'Tema', subtitle: _selectedTheme, onTap: _showTemaBottomSheet),
                    ],
                ),
                const SizedBox(height: 12),
                _buildSection(
                    title: 'BANTUAN',
                    icon: Icons.help_outline_rounded,
                    items: [
                        _buildMenuItem(icon: Icons.quiz_outlined, title: 'FAQ', onTap: _showFAQBottomSheet),
                        _buildMenuItem(icon: Icons.support_agent_rounded, title: 'Hubungi Support', onTap: _showSupportBottomSheet),
                        _buildMenuItem(icon: Icons.bug_report_outlined, title: 'Lapor Bug', onTap: _showLaporBugDialog),
                    ],
                ),
                const SizedBox(height: 12),
                _buildSection(
                    title: 'TENTANG',
                    icon: Icons.info_outline_rounded,
                    items: [
                        // REVISI 8: Format Versi Aplikasi Tanpa Chevron Sesuai Kaidah UI Minimalis
                        _buildMenuItem(icon: Icons.verified_outlined, title: 'Versi Aplikasi v1.2.0', hasChevron: false, onTap: null),
                        _buildMenuItem(icon: Icons.privacy_tip_outlined, title: 'Kebijakan Privasi', onTap: () {}),
                    ],
                ),
            ],
        );
    }

    Widget _buildSection({required String title, required IconData icon, bool isExpanded = false, required List<Widget> items}) {
        return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                        initiallyExpanded: isExpanded,
                        leading: Icon(icon, color: _textSecondary, size: 20),
                        title: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.5)),
                        iconColor: _primaryColor,
                        collapsedIconColor: _textSecondary.withOpacity(0.6),
                        children: items,
                    ),
                ),
            ),
        );
    }

    Widget _buildMenuItem({required IconData icon, required String title, String? subtitle, bool hasChevron = true, required VoidCallback? onTap}) {
        return Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onTap,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: _borderColor))),
                    child: Row(
                        children: [
                            Icon(icon, size: 18, color: _textSecondary),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textPrimary)),
                                        if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12, color: _primaryColor, fontWeight: FontWeight.bold)),
                                    ],
                                ),
                            ),
                            if (hasChevron && onTap != null) ...[
                                const SizedBox(width: 12),
                                Icon(Icons.chevron_right_rounded, size: 18, color: _textSecondary.withOpacity(0.5)),
                            ],
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildLogoutButton() {
        return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                onPressed: _showLogoutConfirmation,
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _errorColor.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: _errorColor.withOpacity(0.02),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.logout_rounded, color: _errorColor, size: 18),
                        const SizedBox(width: 8),
                        Text('Keluar Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _errorColor)),
                    ],
                ),
            ),
        );
    }

    void _showLogoutConfirmation() {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text('Keluar Akun?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                content: Text('Anda harus login kembali untuk mengakses panel data manajemen kos Griya.', style: TextStyle(fontSize: 14, color: _textSecondary)),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal', style: TextStyle(color: _textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: _errorColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        );
    }
}
