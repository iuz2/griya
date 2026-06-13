import 'package:flutter/material.dart';

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

    final Color _primaryColor = const Color(0xFF1A73E8);
    final Color _bgColor = const Color(0xFFF8F9FA);
    final Color _borderColor = const Color(0xFFE8EAED);
    final Color _textPrimary = const Color(0xFF202124);
    final Color _textSecondary = const Color(0xFF5F6368);

    final Color _statusPending = const Color(0xFFFBBC04);
    final Color _statusBerhasil = const Color(0xFF34A853);
    final Color _statusGagal = const Color(0xFFEA4335);

    final List<Map<String, dynamic>> _allPembayaran = [
        {'penyewa': 'Budi Santoso', 'kamar': 'Kamar 101', 'nominal': 'Rp 450.000', 'nominal_raw': 450000, 'tanggal': '12 Juni 2026', 'status': 'Pending', 'metode': 'Transfer Bank', 'referensi': 'TRX-98210'},
        {'penyewa': 'Siti Rahma', 'kamar': 'Kamar 102', 'nominal': 'Rp 500.000', 'nominal_raw': 500000, 'tanggal': '11 Juni 2026', 'status': 'Berhasil', 'metode': 'QRIS', 'referensi': 'QR-88123'},
        {'penyewa': 'Andi Wijaya', 'kamar': 'Kamar 103', 'nominal': 'Rp 450.000', 'nominal_raw': 450000, 'tanggal': '10 Juni 2026', 'status': 'Gagal', 'metode': 'Transfer Bank', 'referensi': 'TRX-11204'},
        {'penyewa': 'Dewi Lestari', 'kamar': 'Kamar 104', 'nominal': 'Rp 600.000', 'nominal_raw': 600000, 'tanggal': '10 Juni 2026', 'status': 'Pending', 'metode': 'Cash', 'referensi': 'TUNAI-552'},
        {'penyewa': 'Eko Prasetyo', 'kamar': 'Kamar 105', 'nominal': 'Rp 400.000', 'nominal_raw': 400000, 'tanggal': '09 Juni 2026', 'status': 'Berhasil', 'metode': 'QRIS', 'referensi': 'QR-77401'},
        {'penyewa': 'Feri Setiawan', 'kamar': 'Kamar 201', 'nominal': 'Rp 450.000', 'nominal_raw': 450000, 'tanggal': '08 Juni 2026', 'status': 'Berhasil', 'metode': 'Transfer Bank', 'referensi': 'TRX-00431'},
        {'penyewa': 'Gita Permata', 'kamar': 'Kamar 202', 'nominal': 'Rp 550.000', 'nominal_raw': 550000, 'tanggal': '07 Juni 2026', 'status': 'Pending', 'metode': 'Transfer Bank', 'referensi': 'TRX-66190'},
        {'penyewa': 'Hendra Wijaya', 'kamar': 'Kamar 203', 'nominal': 'Rp 450.000', 'nominal_raw': 450000, 'tanggal': '06 Juni 2026', 'status': 'Berhasil', 'metode': 'Cash', 'referensi': 'TUNAI-560'},
        {'penyewa': 'Irma Suryani', 'kamar': 'Kamar 204', 'nominal': 'Rp 450.000', 'nominal_raw': 450000, 'tanggal': '05 Juni 2026', 'status': 'Berhasil', 'metode': 'QRIS', 'referensi': 'QR-11029'},
        {'penyewa': 'Joko Widodo', 'kamar': 'Kamar 205', 'nominal': 'Rp 700.000', 'nominal_raw': 700000, 'tanggal': '04 Juni 2026', 'status': 'Berhasil', 'metode': 'Transfer Bank', 'referensi': 'TRX-55410'},
    ];

    @override
    void dispose() {
        _searchController.dispose();
        super.dispose();
    }

    List<Map<String, dynamic>> _getFilteredData() {
        return _allPembayaran.where((item) {
            final matchesFilter = _selectedFilter == 'Semua' || item['status'] == _selectedFilter;
            final matchesSearch = item['kamar']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    item['penyewa']!.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesFilter && matchesSearch;
        }).toList();
    }

    void _showFilterDialog() {
        final filters = ['Semua', 'Pending', 'Berhasil', 'Gagal'];
        showDialog(
            context: context,
            builder: (context) {
                return AlertDialog(
                    title: Text('Saring Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: filters.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return ListTile(
                                title: Text(
                                    filter, 
                                    style: TextStyle(
                                        fontSize: 14, 
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? _primaryColor : _textPrimary
                                    ),
                                ),
                                trailing: isSelected ? Icon(Icons.check_rounded, color: _primaryColor, size: 20) : null,
                                onTap: () {
                                    setState(() { _selectedFilter = filter; });
                                    Navigator.pop(context);
                                },
                            );
                        }).toList(),
                    ),
                );
            },
        );
    }

    void _showDetailBottomSheet(Map<String, dynamic> data) {
        Color badgeColor = _statusPending;
        if (data['status'] == 'Berhasil') badgeColor = _statusBerhasil;
        if (data['status'] == 'Gagal') badgeColor = _statusGagal;

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
                                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: -0.5),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                            data['kamar'],
                                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _textSecondary),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: badgeColor.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                    data['status'].toString().toUpperCase(),
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor, letterSpacing: 0.5),
                                                ),
                                            ),
                                        ],
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                        decoration: BoxDecoration(
                                            color: _primaryColor.withOpacity(0.04),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: _primaryColor.withOpacity(0.1)),
                                        ),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                                Text(
                                                    'NOMINAL PEMBAYARAN',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryColor, letterSpacing: 1.2),
                                                ),
                                                const SizedBox(height: 6),
                                                FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                        data['nominal'],
                                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _primaryColor, letterSpacing: -0.5),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    Text('Informasi Transaksi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: 0.3)),
                                    const SizedBox(height: 12),
                                    _buildDetailItem('Metode Bayar', data['metode']),
                                    _buildDetailItem('Tanggal Bayar', data['tanggal']),
                                    _buildDetailItem('Nomor Referensi', data['referensi']),
                                    
                                    const SizedBox(height: 32),
                                    
                                    if (data['status'] == 'Pending') ...[
                                        _buildBottomSheetButton(
                                            label: 'Verifikasi Pembayaran',
                                            icon: Icons.check_circle_outline_rounded,
                                            color: _statusBerhasil,
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildBottomSheetButton(
                                            label: 'Tolak Pembayaran',
                                            icon: Icons.cancel_outlined,
                                            color: _statusGagal,
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                    ] else if (data['status'] == 'Berhasil') ...[
                                        _buildBottomSheetButton(
                                            label: 'Lihat Bukti Pembayaran',
                                            icon: Icons.receipt_long_rounded,
                                            color: _primaryColor,
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                    ] else if (data['status'] == 'Gagal') ...[
                                        _buildBottomSheetButton(
                                            label: 'Lihat Alasan Kegagalan',
                                            icon: Icons.info_outline_rounded,
                                            color: _textPrimary,
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
        final filteredList = _getFilteredData();

        int countPending = 0;
        int countBerhasil = 0;
        int countGagal = 0;

        for (var p in _allPembayaran) {
            if (p['status'] == 'Pending') countPending++;
            if (p['status'] == 'Berhasil') countBerhasil++;
            if (p['status'] == 'Gagal') countGagal++;
        }
        int countTotal = _allPembayaran.length;

        return Scaffold(
            backgroundColor: _bgColor,
            body: SafeArea(
                child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                        _buildSliverAppBar(),
                        
                        SliverPersistentHeader(
                            pinned: true, 
                            delegate: _StatistikPembayaranDelegate(
                                pending: '$countPending',
                                berhasil: '$countBerhasil',
                                gagal: '$countGagal',
                                total: '$countTotal',
                                statusPendingColor: _statusPending,
                                statusBerhasilColor: _statusBerhasil,
                                statusGagalColor: _statusGagal,
                                statusTotalColor: _primaryColor,
                            ),
                        ),

                        filteredList.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {},
                backgroundColor: _primaryColor,
                elevation: 2,
                child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
        );
    }

    Widget _buildSliverAppBar() {
        return SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            title: _isSearchActive
                ? Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _borderColor),
                    ),
                    child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        cursorColor: _primaryColor,
                        style: TextStyle(color: _textPrimary, fontSize: 14),
                        onChanged: (val) {
                            setState(() { _searchQuery = val; });
                        },
                        decoration: InputDecoration(
                            hintText: 'Cari penyewa/kamar...',
                            hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 13),
                            prefixIcon: Icon(Icons.search_rounded, color: _textSecondary.withOpacity(0.7), size: 16),
                            suffixIcon: IconButton(
                                icon: Icon(Icons.close_rounded, color: _textSecondary, size: 16),
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
                    _selectedFilter == 'Semua' ? 'Pembayaran' : 'Pembayaran ($_selectedFilter)',
                    style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                  ),
            actions: [
                if (!_isSearchActive) ...[
                    IconButton(
                        icon: Icon(Icons.search_rounded, color: _textSecondary, size: 22),
                        onPressed: () => setState(() => _isSearchActive = true),
                    ),
                    IconButton(
                        icon: Icon(Icons.filter_list_rounded, color: _textSecondary, size: 22),
                        onPressed: _showFilterDialog,
                    ),
                ],
                IconButton(
                    icon: Icon(Icons.refresh_rounded, color: _textSecondary, size: 22),
                    onPressed: () => setState(() {}),
                ),
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: _borderColor, height: 1),
            ),
        );
    }

    Widget _buildPembayaranCard(Map<String, dynamic> item) {
        Color statusColor = _statusPending;
        if (item['status'] == 'Berhasil') statusColor = _statusBerhasil;
        if (item['status'] == 'Gagal') statusColor = _statusGagal;

        return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
            ),
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () => _showDetailBottomSheet(item),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: -0.1),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                            color: statusColor.withOpacity(0.08),
                                                            borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                            item['status'].toString().toUpperCase(),
                                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.3),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                item['kamar'],
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textSecondary),
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
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            item['tanggal'],
                                            style: TextStyle(fontSize: 12, color: _textSecondary),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ),
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
                        child: Text(label, style: TextStyle(fontSize: 14, color: _textSecondary)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 5,
                        child: Text(
                            value,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 14, 
                                fontWeight: isBold ? FontWeight.bold : FontWeight.w500, 
                                color: valueColor ?? _textPrimary
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
            height: 46,
            child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
            ),
        );
    }

    Widget _buildEmptyState() {
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.payment_outlined, size: 48, color: _textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('Tidak ada riwayat pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary)),
                        const SizedBox(height: 4),
                        Text('Data transaksi tidak ditemukan atau tidak sesuai dengan penyaringan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: _textSecondary)),
                        const SizedBox(height: 20),
                        OutlinedButton(
                            onPressed: () {
                                _searchController.clear();
                                setState(() {
                                    _searchQuery = '';
                                    _selectedFilter = 'Semua';
                                });
                            },
                            style: OutlinedButton.styleFrom(side: BorderSide(color: _borderColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: Text('Reset Filter', style: TextStyle(color: _primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                    ],
                ),
            ),
        );
    }
}

// ==========================================
// REDESIGN TOTAL: STATISTIK DENGAN NAVIGASI STRUKTUR ADAPTIF (ANTI-OVERFLOW)
// ==========================================
class _StatistikPembayaranDelegate extends SliverPersistentHeaderDelegate {
    final String pending;
    final String berhasil;
    final String gagal;
    final String total;
    final Color statusPendingColor;
    final Color statusBerhasilColor;
    final Color statusGagalColor;
    final Color statusTotalColor;

    _StatistikPembayaranDelegate({
        required this.pending,
        required this.berhasil,
        required this.gagal,
        required this.total,
        required this.statusPendingColor,
        required this.statusBerhasilColor,
        required this.statusGagalColor,
        required this.statusTotalColor,
    });

    @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
        double maxOffset = maxExtent - minExtent;
        double progress = (shrinkOffset / maxOffset).clamp(0.0, 1.0);

        // Interpolasi layout dinamis searah pergerakan scroll jari user
        double paddingLayout = Tween<double>(begin: 12.0, end: 6.0).transform(progress);
        double containerGap = Tween<double>(begin: 10.0, end: 6.0).transform(progress);

        return Container(
            color: const Color(0xFFF8F9FA),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingLayout),
            alignment: Alignment.center,
            child: progress < 0.65
                ? Column(
                    children: [
                        Expanded(
                            child: Row(
                                children: [
                                    Expanded(child: _buildLinearTile('Pending', pending, Icons.hourglass_empty_rounded, statusPendingColor, progress)),
                                    SizedBox(width: containerGap),
                                    Expanded(child: _buildLinearTile('Berhasil', berhasil, Icons.check_circle_outline_rounded, statusBerhasilColor, progress)),
                                ],
                            ),
                        ),
                        SizedBox(height: containerGap),
                        Expanded(
                            child: Row(
                                children: [
                                    Expanded(child: _buildLinearTile('Gagal', gagal, Icons.cancel_outlined, statusGagalColor, progress)),
                                    SizedBox(width: containerGap),
                                    Expanded(child: _buildLinearTile('Total', total, Icons.analytics_outlined, statusTotalColor, progress)),
                                ],
                            ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                        Expanded(child: _buildCollapsedTile('Pdg', pending, statusPendingColor)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCollapsedTile('Brh', berhasil, statusBerhasilColor)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCollapsedTile('Ggl', gagal, statusGagalColor)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCollapsedTile('Tot', total, statusTotalColor)),
                    ],
                  ),
        );
    }

    // Mengubah struktur susunan internal komponen secara bertahap (Column -> Row) sebelum fase tukar layout utama terjadi
    Widget _buildLinearTile(String label, String value, IconData icon, Color color, double progress) {
        // Skala pengecilan ukuran teks dan ikon secara dinamis & halus
        double currentIconSize = Tween<double>(begin: 22.0, end: 14.0).transform(progress);
        double currentValueSize = Tween<double>(begin: 24.0, end: 14.0).transform(progress);
        double currentLabelSize = Tween<double>(begin: 12.0, end: 10.0).transform(progress);

        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: progress < 0.35
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(icon, color: color, size: currentIconSize),
                        const SizedBox(height: 4),
                        FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                value,
                                style: TextStyle(fontSize: currentValueSize, fontWeight: FontWeight.bold, color: const Color(0xFF202124), height: 1.1),
                            ),
                        ),
                        FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                label,
                                style: TextStyle(fontSize: currentLabelSize, color: const Color(0xFF5F6368), fontWeight: FontWeight.w500),
                            ),
                        ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(icon, color: color, size: currentIconSize),
                        const SizedBox(width: 8),
                        Flexible(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            value,
                                            style: TextStyle(fontSize: currentValueSize, fontWeight: FontWeight.bold, color: const Color(0xFF202124), height: 1.1),
                                        ),
                                    ),
                                    FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            label,
                                            style: TextStyle(fontSize: currentLabelSize, color: const Color(0xFF5F6368), fontWeight: FontWeight.w500),
                                        ),
                                    ),
                                ],
                            ),
                        )
                    ],
                  ),
        );
    }

    Widget _buildCollapsedTile(String compactLabel, String value, Color color) {
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text('$compactLabel: ', style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368), fontWeight: FontWeight.w500)),
                            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                        ],
                    ),
                ),
            ),
        );
    }

    @override
    double get maxExtent => 210.0; 
    
    @override
    double get minExtent => 54.0;

    @override
    bool shouldRebuild(covariant _StatistikPembayaranDelegate oldDelegate) {
        return pending != oldDelegate.pending || berhasil != oldDelegate.berhasil || gagal != oldDelegate.gagal || total != oldDelegate.total;
    }
}
