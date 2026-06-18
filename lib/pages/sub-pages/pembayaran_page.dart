import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'catat_pembayaran_page.dart';

class PembayaranPage extends StatefulWidget {
    const PembayaranPage({Key? key}) : super(key: key);

    @override
    State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
    String _selectedFilter = 'Semua';
    final TextEditingController _searchController = TextEditingController();
    String _searchQuery = '';
    bool _isSearchActive = false;

    // Kunci Konstanta Warna V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);

    final Color _statusPending = const Color(0xFFD97706);  // Amber V4
    final Color _statusBerhasil = const Color(0xFF059669); // Emerald V4
    final Color _statusDitolak = const Color(0xFFDC2626);  // Crimson V4

    final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    @override
    void dispose() {
        _searchController.dispose();
        super.dispose();
    }

    // Pemetaan data lokal dari snapshot Firebase RTDB secara dinamis
    List<Map<String, dynamic>> _parseAndFilterData(List<Map<String, dynamic>> rawList) {
        return rawList.where((item) {
            final matchesFilter = _selectedFilter == 'Semua' || item['status'] == _selectedFilter;
            final matchesSearch = item['kamar']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    item['penyewa']!.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesFilter && matchesSearch;
        }).toList();
    }

    // Modifikasi Aksi Verifikasi: Update status transaksi real-time ke Firebase
    void _updateStatusTransaksi(String paymentId, String statusBaru) async {
        if (paymentId.isEmpty) return;

        final DatabaseReference dbRef = FirebaseDatabase.instance.ref()
            .child('users_data/$_currentUid/laporan_kas/$paymentId');

        try {
            // Jika dikonfirmasi berhasil, pastikan penulisan format huruf kapital awal terjaga konsisten
            String formatStatus = 'Pending';
            if (statusBaru == 'Berhasil') formatStatus = 'Berhasil';
            if (statusBaru == 'Ditolak') formatStatus = 'Ditolak';

            await dbRef.update({
                'status': formatStatus,
            });
            
            _showSnackBar("Status transaksi berhasil diperbarui menjadi $formatStatus!", _tealPrimary);
        } catch (e) {
            _showSnackBar("Gagal memperbarui status: ${e.toString()}", _statusDitolak);
        }
    }

    void _showSnackBar(String message, Color bgColor) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: bgColor),
        );
    }

    void _showDetailBottomSheet(Map<String, dynamic> data) {
        Color badgeColor = _statusPending;
        if (data['status'] == 'Berhasil') badgeColor = _statusBerhasil;
        if (data['status'] == 'Ditolak') badgeColor = _statusDitolak;

        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
                return SafeArea(
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: 24, right: 24, top: 24,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 24
                        ),
                        child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(
                                                            data['penyewa'],
                                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: _textSlatePrimary, letterSpacing: -0.5),
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Text(
                                                            data['kamar'],
                                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlateMuted),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: badgeColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                    data['status'].toString().toUpperCase(),
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                                                ),
                                            ),
                                        ],
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: _borderSlateLight, width: 1.2),
                                        ),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                                Text(
                                                    'NOMINAL PEMBAYARAN MASUK',
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _textSlateMuted, letterSpacing: 0.5),
                                                ),
                                                const SizedBox(height: 6),
                                                FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                        data['nominal'],
                                                        style: TextStyle(fontSize: 44, fontWeight: FontWeight.w500, color: _tealPrimary, letterSpacing: -1.0),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    Text('Informasi Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                    const SizedBox(height: 12),
                                    _buildDetailItem('Metode Bayar', data['metode']),
                                    _buildDetailItem('Tanggal Bayar', data['tanggal']),
                                    _buildDetailItem('Nomor Referensi', data['referensi']),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Fungsional Tombol Aksi Real Terintegrasi Database Server
                                    if (data['status'] == 'Pending') ...[
                                        _buildBottomSheetButton(
                                            label: 'Verifikasi Pembayaran',
                                            icon: Icons.check_circle_outline_rounded,
                                            color: _statusBerhasil,
                                            onPressed: () {
                                                Navigator.pop(context);
                                                _updateStatusTransaksi(data['payment_id'], 'Berhasil');
                                            },
                                        ),
                                        const SizedBox(height: 12),
                                        _buildBottomSheetButton(
                                            label: 'Tolak Setoran Dana',
                                            icon: Icons.cancel_outlined,
                                            color: _statusDitolak,
                                            onPressed: () {
                                                Navigator.pop(context);
                                                _updateStatusTransaksi(data['payment_id'], 'Ditolak');
                                            },
                                        ),
                                    ] else if (data['status'] == 'Berhasil') ...[
                                        _buildBottomSheetButton(
                                            label: 'Lihat Struk Bukti Bayar',
                                            icon: Icons.receipt_long_rounded,
                                            color: _tealPrimary,
                                            onPressed: () {
                                                Navigator.pop(context);
                                                if (data['proof_url'] != null && data['proof_url'].toString().isNotEmpty) {
                                                    // Logika penampil struk terlampir publik jika dibutuhkan
                                                    _showSnackBar("Tautan berkas bukti transfer tersedia murni di Storage", _tealPrimary);
                                                } else {
                                                    _showSnackBar("Transaksi tunai tidak memiliki bukti unggahan foto.", _textSlateMuted);
                                                }
                                            },
                                        ),
                                    ] else if (data['status'] == 'Ditolak') ...[
                                        _buildBottomSheetButton(
                                            label: 'Lihat Alasan Penolakan',
                                            icon: Icons.info_outline_rounded,
                                            color: _textSlatePrimary,
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                    ],
                                ],
                            ),
                        ),
                    ),
                );
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        final Query kasQuery = FirebaseDatabase.instance.ref()
            .child('users_data/$_currentUid/laporan_kas');

        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1),
            body: SafeArea(
                child: StreamBuilder<DatabaseEvent>(
                    stream: kasQuery.onValue,
                    builder: (context, snapshot) {
                        List<Map<String, dynamic>> liveAllPembayaran = [];
                        int countPending = 0;
                        int countBerhasil = 0;
                        int countDitolak = 0;

                        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                            final Map<dynamic, dynamic> mapKas = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            mapKas.forEach((key, val) {
                                final item = val as Map<dynamic, dynamic>;
                                // Hanya memuat transaksi masuk (pemasukan sewa)
                                if (item['type'] == 'pemasukan') {
                                    final String statusRaw = item['status'] ?? 'Pending';
                                    if (statusRaw == 'Pending') countPending++;
                                    if (statusRaw == 'Berhasil') countBerhasil++;
                                    if (statusRaw == 'Ditolak') countDitolak++;

                                    liveAllPembayaran.add({
                                        'payment_id': item['payment_id']?.toString() ?? key.toString(),
                                        'penyewa': item['tenant_name']?.toString() ?? 'Seseorang',
                                        'kamar': 'Kamar ' + (item['room_name']?.toString() ?? '-'),
                                        'nominal': 'Rp ' + (item['amount'] ?? 0).toString(),
                                        'nominal_raw': item['amount'] ?? 0,
                                        'tanggal': item['transaction_date']?.toString() ?? '-',
                                        'status': statusRaw,
                                        'metode': item['payment_method']?.toString() ?? 'Tunai',
                                        'referensi': item['payment_id']?.toString().substring(0, 8).toUpperCase() ?? '-',
                                        'proof_url': item['proof_url'] ?? '',
                                    });
                                }
                            });
                            // Urutkan transaksi kas dari yang paling baru masuk
                            liveAllPembayaran.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));
                        }

                        final filteredList = _parseAndFilterData(liveAllPembayaran);

                        return CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                                _buildSliverAppBar(),
                                
                                SliverToBoxAdapter(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 4.0),
                                        child: _buildKuantitasOverviewCard(
                                            pending: '$countPending Kamar',
                                            berhasil: '$countBerhasil Kamar',
                                            ditolak: '$countDitolak Kamar',
                                        ),
                                    ),
                                ),

                                SliverAppBar(
                                    backgroundColor: const Color(0xFFECEFF1),
                                    elevation: 0,
                                    scrolledUnderElevation: 0,
                                    pinned: true,
                                    automaticallyImplyLeading: false,
                                    toolbarHeight: 64,
                                    title: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: _buildFilterChipsRow(),
                                    ),
                                ),

                                filteredList.isEmpty
                                    ? SliverToBoxAdapter(child: _buildEmptyState())
                                    : SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 80.0),
                                        sliver: SliverList(
                                            delegate: SliverChildBuilderDelegate(
                                                (context, index) {
                                                    return _buildPembayaranCard(filteredList[index]);
                                                },
                                                childCount: filteredList.length,
                                            ),
                                        ),
                                      ),
                            ],
                        );
                    },
                ),
            ),
            floatingActionButton: _buildFAB(),
        );
    }

    Widget _buildSliverAppBar() {
        return SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: false,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textSlatePrimary, size: 18),
                onPressed: () => Navigator.pop(context),
            ),
            title: _isSearchActive
                ? Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderSlateLight, width: 1.2),
                    ),
                    child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        cursorColor: _tealPrimary,
                        style: TextStyle(color: _textSlatePrimary, fontSize: 15, fontWeight: FontWeight.w400),
                        onChanged: (val) {
                            setState(() { _searchQuery = val; });
                        },
                        decoration: InputDecoration(
                            hintText: 'Cari penyewa atau unit...',
                            hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14),
                            prefixIcon: Icon(Icons.search_rounded, color: _textSlateMuted, size: 20),
                            suffixIcon: IconButton(
                                icon: Icon(Icons.close_rounded, color: _textSlateMuted, size: 18),
                                onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                        _searchQuery = '';
                                        _isSearchActive = false;
                                    });
                                },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                    ),
                  )
                : Text(
                    _selectedFilter == 'Semua' ? 'Verifikasi Setoran' : 'Setoran ($_selectedFilter)',
                    style: TextStyle(color: _textSlatePrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            centerTitle: true,
            actions: [
                if (!_isSearchActive) ...[
                    IconButton(
                        icon: Icon(Icons.search_rounded, color: _textSlateMuted, size: 22),
                        onPressed: () => setState(() => _isSearchActive = true),
                    ),
                ],
                IconButton(
                    icon: Icon(Icons.refresh_rounded, color: _textSlateMuted, size: 22),
                    onPressed: () => setState(() {}),
                ),
            ],
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
        );
    }

    Widget _buildKuantitasOverviewCard({required String pending, required String berhasil, required String ditolak}) {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: Row(
                children: [
                    _buildStatItem('Pending', pending, _statusPending),
                    _buildStatDivider(),
                    _buildStatItem('Berhasil', berhasil, _statusBerhasil),
                    _buildStatDivider(),
                    _buildStatItem('Ditolak', ditolak, _statusDitolak),
                ],
            ),
        );
    }

    Widget _buildStatItem(String label, String value, Color color) {
        return Expanded(
            child: Column(
                children: [
                    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color)),
                    const SizedBox(height: 4),
                    Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                ],
            ),
        );
    }

    Widget _buildStatDivider() {
        return Container(height: 32, width: 1, color: const Color(0xFFF1F5F9));
    }

    Widget _buildFilterChipsRow() {
        final filters = ['Semua', 'Pending', 'Berhasil', 'Ditolak'];
        return SizedBox(
            height: 42,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                    final filter = filters[index];
                    final isActive = _selectedFilter == filter;
                    return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                            onTap: () => setState(() => _selectedFilter = filter),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                    color: isActive ? _tealPrimary : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isActive ? _tealPrimary : _borderSlateLight, width: 1.2),
                                ),
                                child: Text(
                                    filter,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                                        color: isActive ? Colors.white : const Color(0xFF475569),
                                    ),
                                ),
                            ),
                        ),
                    );
                },
            ),
        );
    }

    Widget _buildPembayaranCard(Map<String, dynamic> item) {
        Color statusColor = _statusPending;
        if (item['status'] == 'Berhasil') statusColor = _statusBerhasil;
        if (item['status'] == 'Ditolak') statusColor = _statusDitolak;

        return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: Row(
                children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    children: [
                                        Expanded(
                                            child: Text(
                                                item['penyewa'],
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary, letterSpacing: -0.1),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                                item['status'].toString().toUpperCase(),
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    item['kamar'],
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _textSlateMuted),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            Text(
                                item['nominal'],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _textSlatePrimary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                                item['tanggal'],
                                style: TextStyle(fontSize: 13, color: _textSlateMuted, fontWeight: FontWeight.w400),
                            ),
                        ],
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                        onPressed: () => _showDetailBottomSheet(item),
                    ),
                ],
            ),
        );
    }

    Widget _buildDetailItem(String label, String value, {bool isBold = false, Color? valueColor}) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Expanded(
                        flex: 4,
                        child: Text(label, style: TextStyle(fontSize: 14, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 5,
                        child: Text(
                            value,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 14, 
                                fontWeight: isBold ? FontWeight.bold : FontWeight.w400, 
                                color: valueColor ?? _textSlatePrimary
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildBottomSheetButton({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
        return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
            ),
        );
    }

    Widget _buildEmptyState() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.payment_outlined, size: 44, color: _textSlateMuted.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('Tidak ada riwayat transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                    const SizedBox(height: 4),
                    Text('Data setoran dana tidak ditemukan pada filter ini.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _textSlateMuted)),
                    const SizedBox(height: 14),
                    TextButton(
                        onPressed: () {
                            _searchController.clear();
                            setState(() {
                                _searchQuery = '';
                                _selectedFilter = 'Semua';
                            });
                        },
                        child: const Text('Reset Filter', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        );
    }

    Widget _buildFAB() {
        return FloatingActionButton(
            onPressed: () {
                _showSnackBar("Gunakan tombol 'Catat Pembayaran Kas' di Detail Kamar untuk mencatat setoran.", _tealPrimary);
            },
            backgroundColor: _tealPrimary,
            elevation: 2,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        );
    }
}
