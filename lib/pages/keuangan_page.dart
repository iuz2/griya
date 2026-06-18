import 'package:flutter/material.dart';
import 'sub-pages/detail_pengeluaran_page.dart'; 
import 'sub-pages/tagihan_page.dart'; 
import 'sub-pages/pembayaran_page.dart'; 
import 'sub-pages/laporan_page.dart'; 

class KeuanganPage extends StatefulWidget {
    const KeuanganPage({Key? key}) : super(key: key);

    @override
    State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
    String _selectedPeriod = 'Bulan Ini';

    // Data operasional fungsional (Kadar visual tunduk di bawah kontrol Beranda)
    final String _pemasukan = 'Rp 4.500.000';
    final String _pengeluaran = 'Rp 1.200.000';
    final String _labaBersih = 'Rp 3.300.000';
    
    final int _pendingCount = 2;
    final int _overdueCount = 3;

    final List<Map<String, dynamic>> _recentTransactions = [
        {'kamar': 'Kamar 101', 'nominal': 'Log: +Rp 450.000', 'tanggal': '15 Jun 2026', 'status': 'Dikonfirmasi', 'isPlus': true},
        {'kamar': 'Kamar 105', 'nominal': 'Log: Rp 400.000', 'tanggal': '14 Jun 2026', 'status': 'Pending', 'isPlus': false},
        {'kamar': 'Kamar 102', 'nominal': 'Log: Rp 450.000', 'tanggal': '13 Jun 2026', 'status': 'Ditolak', 'isPlus': false},
    ];

    void _showAddDataBottomSheet() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
                return SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(color: const Color(0xFFCFD8DC), borderRadius: BorderRadius.circular(2)),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                    leading: const Icon(Icons.add_card_rounded, color: Color(0xFF0F766E)),
                                    title: const Text('Catat Pembayaran', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                                    onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PembayaranPage()));
                                    },
                                ),
                                ListTile(
                                    leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0F766E)),
                                    title: const Text('Catat Pengeluaran', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                                    onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailPengeluaranPage(mode: PengeluaranMode.add)));
                                    },
                                ),
                                ListTile(
                                    leading: const Icon(Icons.receipt_outlined, color: Color(0xFF0F766E)),
                                    title: const Text('Buat Tagihan Baru', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                                    onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TagihanPage()));
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
            backgroundColor: const Color(0xFFECEFF1), 
            body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    color: const Color(0xFF0F766E),
                    child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                            // 1. APP BAR UTAMA ELEGAN
                            SliverAppBar(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                scrolledUnderElevation: 0,
                                pinned: false, 
                                title: const Text(
                                    'Keuangan Properti',
                                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                centerTitle: true,
                            ),

                            // 2. SEKSI STICKY FILTER BULAN (Mengunci diam di atas)
                            SliverAppBar(
                                backgroundColor: const Color(0xFFECEFF1), 
                                elevation: 0,
                                scrolledUnderElevation: 0,
                                pinned: true, 
                                automaticallyImplyLeading: false,
                                toolbarHeight: 74, 
                                title: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: _buildPeriodFilterRow(),
                                ),
                            ),

                            // 3. DAFTAR KONTEN CARD UTAMA LAPANG (Padding disamakan Beranda)
                            SliverPadding(
                                padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 80.0),
                                sliver: SliverList(
                                    delegate: SliverChildListDelegate([
                                        _buildCardWrapper(child: _buildFunctionalBalanceList()),
                                        const SizedBox(height: 16),
                                        _buildCardWrapper(child: _buildFinanceHubList()),
                                        const SizedBox(height: 16),
                                        _buildCardWrapper(child: _buildTransactionHistoryList()),
                                    ]),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _showAddDataBottomSheet,
                backgroundColor: const Color(0xFF0F766E),
                elevation: 2,
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
        );
    }

    Widget _buildCardWrapper({required Widget child}) {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0), // Diperbesar ke 24.0 agar seimbang megah
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0), // Sesuai lengkung halus Beranda
                border: Border.all(color: const Color(0xFFCFD8DC), width: 1.2),
            ),
            child: child,
        );
    }

    Widget _buildPeriodFilterRow() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Text(
                    "Buku Kas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF475569)),
                ),
                Container(
                    height: 44, 
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCFD8DC), width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: _selectedPeriod,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0F766E), size: 24),
                            style: const TextStyle(color: Color(0xFF0F766E), fontSize: 15, fontWeight: FontWeight.bold),
                            onChanged: (String? val) {
                                if (val != null) setState(() => _selectedPeriod = val);
                            },
                            items: <String>['Bulan Ini', 'Bulan Lalu', 'Tahun Ini'].map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildFunctionalBalanceList() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text('Ikhtisar Saldo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF0F172A))),
                const SizedBox(height: 18),
                _buildDataRowItem("Total Pemasukan", _pemasukan, const Color(0xFF0F766E)),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildDataRowItem("Total Pengeluaran", _pengeluaran, const Color(0xFF1E293B)),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildDataRowItem("Estimasi Laba Bersih", _labaBersih, const Color(0xFF0F766E)),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildDataRowItem("Belum Diverifikasi", "$_pendingCount Transaksi", const Color(0xFF475569)),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Row(
                            children: const [
                                Text('• ', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold)),
                                Text("Tunggakan Sewa Kos", style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w400)),
                            ],
                        ),
                        Text("$_overdueCount Unit", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF991B1B))),
                    ],
                ),
            ],
        );
    }

    Widget _buildDataRowItem(String title, String value, Color valueColor) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w400)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: valueColor)),
            ],
        );
    }

    Widget _buildFinanceHubList() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text('Menu Pengelolaan Kas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildMenuRowItem(Icons.receipt_long_rounded, 'Manajemen Data Tagihan', 'Kelola & distribusikan invoice', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TagihanPage()));
                }),
                _buildMenuRowItem(Icons.verified_rounded, 'Verifikasi Pembayaran', 'Konfirmasi setoran dana masuk', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PembayaranPage()));
                }),
                _buildMenuRowItem(Icons.shopping_bag_rounded, 'Biaya & Pengeluaran Operasional', 'Catat nota belanja rutin kos', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailPengeluaranPage(mode: PengeluaranMode.add)));
                }),
                _buildMenuRowItem(Icons.analytics_rounded, 'Laporan & Analisis Kas', 'Grafik laba rugi bulanan', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LaporanPage()));
                }),
            ],
        );
    }

    Widget _buildMenuRowItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
        return ListTile(
            onTap: onTap,
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: const Color(0xFF0F766E), size: 20),
            title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF1E293B))),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w400)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
        );
    }

    Widget _buildTransactionHistoryList() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Text('Riwayat Transaksi Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF0F172A))),
                        TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text('Lihat Semua', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F766E))),
                        ),
                    ],
                ),
                const SizedBox(height: 10),
                ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentTransactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                        final tx = _recentTransactions[index];
                        final bool isPlusTransaction = tx['isPlus'] == true;
                        
                        return Row(
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(tx['kamar']?.toString() ?? 'Kamar', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF0F172A))),
                                            const SizedBox(height: 4),
                                            Text('${tx['status'] ?? ''} • ${tx['tanggal'] ?? ''}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w400)),
                                        ],
                                    ),
                                ),
                                Text(
                                    tx['nominal']?.toString() ?? 'Rp 0',
                                    style: TextStyle(
                                        fontSize: 15, 
                                        fontWeight: FontWeight.w500, 
                                        color: isPlusTransaction ? const Color(0xFF0F766E) : const Color(0xFF1E293B),
                                    ),
                                ),
                            ],
                        );
                    },
                ),
            ],
        );
    }
}
