import 'package:flutter/material.dart';
import 'sub-pages/detail_pengeluaran_page.dart'; // Pastikan path import ini sesuai struktur folder Anda
import 'sub-pages/tagihan_page.dart'; // Impor file halaman tagihan baru
import 'sub-pages/pembayaran_page.dart'; // Impor file halaman pembayaran baru yang baru saja dibuat
import 'sub-pages/laporan_page.dart'; // Impor file halaman laporan baru yang baru saja dibuat

class KeuanganPage extends StatefulWidget {
    const KeuanganPage({Key? key}) : super(key: key);

    @override
    State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
    String _selectedPeriod = 'Bulan Ini';
    bool _isRefreshing = false;

    // Mock Data
    final String _pemasukan = 'Rp 4.500.000';
    final String _pengeluaran = 'Rp 1.200.000';
    final String _labaBersih = 'Rp 3.300.000';
    final String _trend = '↑ 15% dari bulan lalu';
    
    final int _pendingCount = 2;
    final String _pendingAmount = 'Rp 900.000';
    final int _overdueCount = 3;
    final String _overdueAmount = 'Rp 1.350.000';

    final List<Map<String, dynamic>> _recentTransactions = [
        {'kamar': 'Kamar 101', 'nominal': 'Rp 450.000', 'tanggal': '15 Jun 2024', 'status': 'Dikonfirmasi', 'icon': Icons.check_circle, 'color': const Color(0xFF34A853)},
        {'kamar': 'Kamar 105', 'nominal': 'Rp 400.000', 'tanggal': '14 Jun 2024', 'status': 'Pending', 'icon': Icons.hourglass_empty, 'color': const Color(0xFFFBBC04)},
        {'kamar': 'Kamar 102', 'nominal': 'Rp 450.000', 'tanggal': '13 Jun 2024', 'status': 'Ditolak', 'icon': Icons.cancel, 'color': const Color(0xFFEA4335)},
    ];

    Future<void> _handleRefresh() async {
        setState(() => _isRefreshing = true);
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() => _isRefreshing = false);
        
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('✅ Data keuangan diperbarui'),
                    backgroundColor: Color(0xFF34A853),
                    duration: Duration(seconds: 2),
                ),
            );
        }
    }

    void _showAddDataBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
                return SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    child: Text(
                                        'Tambah Data',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                ListTile(
                                    leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: const Color(0xFF1A73E8).withOpacity(0.1), shape: BoxShape.circle),
                                        child: const Icon(Icons.payments_outlined, color: Color(0xFF1A73E8), size: 20),
                                    ),
                                    title: const Text('Catat Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF202124))),
                                    subtitle: const Text('Input pembayaran tunai/manual dari penyewa', style: TextStyle(fontSize: 12, color: Color(0xFF5F7A90))),
                                    onTap: () async {
                                        Navigator.pop(context);
                                        await Future.delayed(const Duration(milliseconds: 150));
                                        if (context.mounted) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const PembayaranPage(),
                                                ),
                                            );
                                        }
                                    },
                                ),
                                ListTile(
                                    leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: const Color(0xFFEA4335).withOpacity(0.1), shape: BoxShape.circle),
                                        child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFEA4335), size: 20),
                                    ),
                                    title: const Text('Catat Pengeluaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF202124))),
                                    subtitle: const Text('Input biaya operasional kos', style: TextStyle(fontSize: 12, color: Color(0xFF5F7A90))),
                                    onTap: () async {
                                        Navigator.pop(context);
                                        await Future.delayed(const Duration(milliseconds: 150));
                                        if (context.mounted) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const DetailPengeluaranPage(mode: PengeluaranMode.add),
                                                ),
                                            );
                                        }
                                    },
                                ),
                                ListTile(
                                    leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: const Color(0xFF7B1FA2).withOpacity(0.1), shape: BoxShape.circle),
                                        child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF7B1FA2), size: 20),
                                    ),
                                    title: const Text('Buat Tagihan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF202124))),
                                    subtitle: const Text('Buat tagihan sewa baru untuk kamar', style: TextStyle(fontSize: 12, color: Color(0xFF5F7A90))),
                                    onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const TagihanPage(),
                                            ),
                                        );
                                    },
                                ),
                            ],
                        ),
                    ),
                );
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF1A73E8),
                    backgroundColor: Colors.white,
                    child: CustomScrollView(
                        slivers: [
                            _buildSliverAppBar(),
                            SliverToBoxAdapter(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const SizedBox(height: 16),
                                            _buildRevenueCard(),
                                            const SizedBox(height: 8),
                                            _buildStatCards(),
                                            const SizedBox(height: 24),
                                            _buildFinanceHub(),
                                            const SizedBox(height: 24),
                                            _buildCollapsibleSections(),
                                            const SizedBox(height: 16),
                                            _buildRecentTransactions(),
                                            const SizedBox(height: 80),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _showAddDataBottomSheet,
                backgroundColor: const Color(0xFF1A73E8),
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white),
            ),
        );
    }

    Widget _buildSliverAppBar() {
        return SliverAppBar(
            backgroundColor: const Color(0xFFFFFFFF),
            elevation: 0,
            scrolledUnderElevation: 1,
            pinned: true,
            title: const Text(
                'Keuangan',
                style: TextStyle(color: Color(0xFF202124), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
                Container(
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: _selectedPeriod,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF5F6368)),
                            style: const TextStyle(color: Color(0xFF202124), fontSize: 13, fontWeight: FontWeight.w600),
                            onChanged: (String? newValue) {
                                if (newValue != null) {
                                    setState(() => _selectedPeriod = newValue);
                                }
                            },
                            items: <String>['Bulan Ini', 'Bulan Lalu', 'Tahun Ini']
                                .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                );
                            }).toList(),
                        ),
                    ),
                ),
                IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF5F6368)),
                    onPressed: _handleRefresh,
                ),
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: const Color(0xFFE8EAED), height: 1),
            ),
        );
    }

    Widget _buildRevenueCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EAED)),
                boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        'Laba Bersih Bulan Ini',
                        style: TextStyle(fontSize: 13, color: Color(0xFF5F7A90), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                            _labaBersih,
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF34A853)),
                        ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8EAED)),
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text('Pemasukan', style: TextStyle(fontSize: 11, color: Color(0xFF5F7A90))),
                                            const SizedBox(height: 2),
                                            Text(_pemasukan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                                        ],
                                    ),
                                ),
                                Container(width: 1, height: 28, color: const Color(0xFFE8EAED)),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text('Pengeluaran', style: TextStyle(fontSize: 11, color: Color(0xFF5F7A90))),
                                            const SizedBox(height: 2),
                                            Text(_pengeluaran, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEA4335))),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                        children: [
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF34A853).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                    _trend,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF34A853)),
                                ),
                            ),
                            const Spacer(),
                            const Text(
                                'Update: Baru saja',
                                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }

    Widget _buildStatCards() {
        return Row(
            children: [
                Expanded(
                    child: _buildSingleStatCard(
                        'BELUM DIVERIFIKASI',
                        '$_pendingCount bayar',
                        _pendingAmount,
                        const Color(0xFFFBBC04),
                        Icons.hourglass_empty,
                    ),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildSingleStatCard(
                        'BELUM BAYAR',
                        '$_overdueCount kamar',
                        _overdueAmount,
                        const Color(0xFFEA4335),
                        Icons.warning_amber_rounded,
                    ),
                ),
            ],
        );
    }

    Widget _buildSingleStatCard(String title, String count, String amount, Color color, IconData icon) {
        return Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3)),
                        boxShadow: [
                            BoxShadow(color: color.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(
                                children: [
                                    Icon(icon, size: 14, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                        title,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.2),
                                    ),
                                ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                                count,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color == const Color(0xFFEA4335) ? color : const Color(0xFF202124)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                amount,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF5F7A90), fontWeight: FontWeight.w500),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildFinanceHub() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                        'Pusat Keuangan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                    ),
                ),
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8EAED)),
                        boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                    ),
                    child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.25,
                        children: [
                            _buildFinanceMenuItem(
                                icon: Icons.receipt_long_outlined,
                                title: 'Tagihan',
                                subtitle: 'Kelola tagihan penyewa',
                                iconColor: const Color(0xFF1A73E8),
                                onTap: () async {
                                    await Future.delayed(const Duration(milliseconds: 200));
                                    if (mounted) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const TagihanPage(),
                                            ),
                                        );
                                    }
                                },
                            ),
                            _buildFinanceMenuItem(
                                icon: Icons.payments_outlined,
                                title: 'Pembayaran',
                                subtitle: 'Riwayat & verifikasi pembayaran',
                                iconColor: const Color(0xFF34A853),
                                onTap: () async {
                                    await Future.delayed(const Duration(milliseconds: 200));
                                    if (mounted) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const PembayaranPage(),
                                            ),
                                        );
                                    }
                                },
                            ),
                            _buildFinanceMenuItem(
                                icon: Icons.shopping_cart_outlined,
                                title: 'Pengeluaran',
                                subtitle: 'Catat biaya operasional',
                                iconColor: const Color(0xFFEA4335),
                                onTap: () async {
                                    await Future.delayed(const Duration(milliseconds: 200));
                                    if (mounted) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const DetailPengeluaranPage(mode: PengeluaranMode.add),
                                            ),
                                        );
                                    }
                                },
                            ),
                            _buildFinanceMenuItem(
                                icon: Icons.bar_chart_outlined,
                                title: 'Laporan',
                                subtitle: 'Analisis keuangan',
                                iconColor: const Color(0xFFFBBC04),
                                // Menambahkan navigasi ke LaporanPage dengan async delay
                                onTap: () async {
                                    await Future.delayed(const Duration(milliseconds: 200));
                                    if (mounted) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const LaporanPage(),
                                            ),
                                        );
                                    }
                                },
                            ),
                            _buildFinanceMenuItem(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'Payment Gateway',
                                subtitle: 'Midtrans & metode pembayaran',
                                iconColor: const Color(0xFF7B1FA2),
                                onTap: () {},
                            ),
                            _buildFinanceMenuItem(
                                icon: Icons.settings_applications_outlined,
                                title: 'Pengaturan Keuangan',
                                subtitle: 'Kategori, denda, dan pengaturan tagihan',
                                iconColor: const Color(0xFF5F6368),
                                onTap: () {},
                            ),
                        ],
                    ),
                ),
            ],
        );
    }

    Widget _buildFinanceMenuItem({required IconData icon, required String title, required String subtitle, required Color iconColor, required VoidCallback onTap}) {
        return Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(icon, color: iconColor, size: 20),
                            ),
                            const SizedBox(height: 10),
                            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                            const SizedBox(height: 2),
                            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF5F7A90), height: 1.2)),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildCollapsibleSections() {
        return Container(
            decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8EAED))),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: Column(
                        children: [
                            ExpansionTile(
                                title: const Text('Ringkasan Bulan Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                    _buildSummaryRow('Pembayaran Penuh', '10x', 'Rp 4.500.000'),
                                    _buildSummaryRow('Pembayaran Sebagian', '0x', 'Rp 0'),
                                    const Divider(color: Color(0xFFE8EAED)),
                                    _buildSummaryRow('Belum Bayar', '3 Kamar', '- Rp 1.350.000', isAlert: true),
                                ],
                            ),
                            Container(height: 1, color: const Color(0xFFE8EAED)),
                            ExpansionTile(
                                title: const Text('Status Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                    _buildStatusRow('Dikonfirmasi', '10', const Color(0xFF34A853)),
                                    _buildStatusRow('Pending Konfirmasi', '2', const Color(0xFFFBBC04)),
                                    _buildStatusRow('Ditolak', '0', const Color(0xFFEA4335)),
                                ],
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildSummaryRow(String label, String count, String amount, {bool isAlert = false}) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
                children: [
                    Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5F7A90)))),
                    Expanded(flex: 1, child: Text(count, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF202124)))),
                    Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAlert ? const Color(0xFFEA4335) : const Color(0xFF202124))),
                ],
            ),
        );
    }

    Widget _buildStatusRow(String label, String count, Color dotColor) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Row(
                        children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5F7A90))),
                        ],
                    ),
                    Text(count, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                ],
            ),
        );
    }

    Widget _buildRecentTransactions() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text('Riwayat Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                ),
                Container(
                    decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8EAED))),
                    child: Column(
                        children: [
                            ..._recentTransactions.map((tx) => _buildTransactionItem(tx)).toList(),
                            InkWell(
                                onTap: () {},
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE8EAED)))),
                                    child: const Center(
                                        child: Text('Lihat Semua Transaksi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        );
    }

    Widget _buildTransactionItem(Map<String, dynamic> tx) {
        return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
                children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: tx['color'].withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(tx['icon'], color: tx['color'], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(tx['kamar'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                                        Text(tx['nominal'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                                    ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(tx['tanggal'], style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                        Text(tx['status'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tx['color'])),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
}
