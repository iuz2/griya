import 'package:flutter/material.dart';

class TagihanPage extends StatefulWidget {
    const TagihanPage({Key? key}) : super(key: key);

    @override
    State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
    String _selectedFilter = 'Semua Aktif';
    final TextEditingController _searchController = TextEditingController();
    String _searchQuery = '';

    // Kunci Konstanta Warna V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);

    final Color _statusMenunggu = const Color(0xFFD97706); 
    final Color _statusTerlambat = const Color(0xFFDC2626); 
    final Color _statusTerkirim = const Color(0xFF059669); 

    // Struktur Logika Data Dummy Asli (100% Dipertahankan)
    final List<Map<String, dynamic>> _allTagihanAktif = [
        {
            'kamar': 'Kamar 101', 'penyewa': 'Budi Santoso', 
            'nominal': 'Rp 500.000', 'nominal_raw': 500000, 
            'umur_tagihan': 'Tempo 3 hari lagi', 'tanggal_tagihan': '01 Juni 2026', 
            'status': 'Menunggu', 'status_kirim': 'Belum dikirim', 'telepon': '08123456789',
            'rincian': [
                {'nama': 'Sewa Kamar', 'harga': 'Rp 450.000'},
                {'nama': 'Listrik Tambahan', 'harga': 'Rp 50.000'}
            ]
        },
        {
            'kamar': 'Kamar 102', 'penyewa': 'Siti Rahma', 
            'nominal': 'Rp 500.000', 'nominal_raw': 500000, 
            'umur_tagihan': 'Terlambat 2 hari', 'tanggal_tagihan': '01 Juni 2026', 
            'status': 'Terlambat', 'status_kirim': 'Sudah dikirim', 'telepon': '08129876543',
            'rincian': [
                {'nama': 'Sewa Kamar', 'harga': 'Rp 500.000'}
            ]
        },
        {
            'kamar': 'Kamar 104', 'penyewa': 'Dewi Lestari', 
            'nominal': 'Rp 650.000', 'nominal_raw': 650000, 
            'umur_tagihan': 'Tempo 1 minggu lagi', 'tanggal_tagihan': '01 Juni 2026', 
            'status': 'Menunggu', 'status_kirim': 'Sudah dikirim', 'telepon': '08145678901',
            'rincian': [
                {'nama': 'Sewa Kamar', 'harga': 'Rp 600.000'},
                {'nama': 'Air', 'harga': 'Rp 50.000'}
            ]
        },
        {
            'kamar': 'Kamar 105', 'penyewa': 'Eko Prasetyo', 
            'nominal': 'Rp 400.000', 'nominal_raw': 400000, 
            'umur_tagihan': 'Terlambat 5 hari', 'tanggal_tagihan': '01 Juni 2026', 
            'status': 'Terlambat', 'status_kirim': 'Belum dikirim', 'telepon': '08156789012',
            'rincian': [
                {'nama': 'Sewa Kamar', 'harga': 'Rp 400.000'}
            ]
        },
        {
            'kamar': 'Kamar 203', 'penyewa': 'Hendra Wijaya', 
            'nominal': 'Rp 450.000', 'nominal_raw': 450000, 
            'umur_tagihan': 'Tempo Hari Ini', 'tanggal_tagihan': '01 Juni 2026', 
            'status': 'Menunggu', 'status_kirim': 'Sudah dikirim', 'telepon': '08189012345',
            'rincian': [
                {'nama': 'Sewa Kamar', 'harga': 'Rp 450.000'}
            ]
        },
        {
            'kamar': 'Kamar 302', 'penyewa': 'Anisa Bahar', 
            'nominal': 'Rp 525.000', 'nominal_raw': 525000, 
            'umur_tagihan': 'Terlambat 1 hari', 'tanggal_tagihan': '01 Juni 2026', 
            'status': 'Terlambat', 'status_kirim': 'Sudah dikirim', 'telepon': '08223456789',
            'rincian': [
                {'nama': 'Sewa Kamar', 'harga': 'Rp 450.000'},
                {'nama': 'Denda Keterlambatan', 'harga': 'Rp 75.000'}
            ]
        },
    ];

    @override
    void dispose() {
        _searchController.dispose();
        super.dispose();
    }

    List<Map<String, dynamic>> _getFilteredData() {
        return _allTagihanAktif.where((item) {
            final matchesFilter = _selectedFilter == 'Semua Aktif' || item['status'] == _selectedFilter;
            final matchesSearch = item['kamar']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    item['penyewa']!.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesFilter && matchesSearch;
        }).toList();
    }

    void _showDetailBottomSheet(Map<String, dynamic> data) {
        Color badgeColor = data['status'] == 'Terlambat' ? _statusTerlambat : _statusMenunggu;
        bool isSent = data['status_kirim'] == 'Sudah dikirim';

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
                                                    data['status'],
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
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
                                                    'TOTAL NOMINAL INVOICE',
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
                                    Text('Rincian Komponen Biaya', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                    const SizedBox(height: 12),
                                    ...List.generate(data['rincian'].length, (index) {
                                        final item = data['rincian'][index];
                                        return Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Row(
                                                children: [
                                                    Expanded(
                                                        child: Text(item['nama'], style: TextStyle(fontSize: 14, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(item['harga'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textSlatePrimary)),
                                                ],
                                            ),
                                        );
                                    }),
                                    
                                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                    Text('Informasi Distribusi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                    const SizedBox(height: 12),
                                    _buildDetailItem('No. WhatsApp', data['telepon']),
                                    _buildDetailItem('Status Pengiriman', data['status_kirim'], valueColor: isSent ? _statusTerkirim : _textSlateMuted),
                                    _buildDetailItem('Tanggal Cetak', data['tanggal_tagihan']),
                                    _buildDetailItem('Status Umur Nota', data['umur_tagihan'], valueColor: badgeColor, isBold: true),
                                    _buildDetailItem('Metode Pembayaran', 'Midtrans Gateway Otomatis'),
                                    
                                    const SizedBox(height: 24),
                                    
                                    if (data['status'] == 'Menunggu') ...[
                                        _buildBottomSheetButton(
                                            label: isSent ? 'Kirim Ulang Notifikasi WA' : 'Kirim Tagihan via WhatsApp',
                                            icon: Icons.chat_bubble_outline_rounded,
                                            color: const Color(0xFF25D366),
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildBottomSheetButton(
                                            label: 'Salin Tautan Pembayaran',
                                            icon: Icons.link_rounded,
                                            color: _tealPrimary,
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                    ] else if (data['status'] == 'Terlambat') ...[
                                        _buildBottomSheetButton(
                                            label: 'Kirim Teguran Keterlambatan',
                                            icon: Icons.warning_amber_rounded,
                                            color: _statusTerlambat,
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

        int hitungMenunggu = 0;
        int hitungTerlambat = 0;
        int hitungHariIni = 0;

        for (var t in _allTagihanAktif) {
            if (t['status'] == 'Menunggu') hitungMenunggu++;
            if (t['status'] == 'Terlambat') hitungTerlambat++;
            if (t['umur_tagihan'] == 'Tempo Hari Ini') hitungHariIni++;
        }

        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1),
            body: SafeArea(
                child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                        SliverAppBar(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            scrolledUnderElevation: 0,
                            pinned: false,
                            title: Text(
                                'Tagihan Aktif Properti',
                                style: TextStyle(color: _textSlatePrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            centerTitle: true,
                            actions: [
                                IconButton(
                                    icon: Icon(Icons.refresh_rounded, color: _textSlateMuted, size: 22),
                                    onPressed: () => setState(() {}),
                                ),
                            ],
                        ),
                        
                        // REVISI TOTAL: Mengubah isi data statistik menjadi hitungan Unit Kamar (100% Beban Overlowed Hilang)
                        SliverToBoxAdapter(
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 4.0),
                                child: _buildKuantitasOverviewCard(
                                    menunggu: '$hitungMenunggu Kamar',
                                    terlambat: '$hitungTerlambat Kamar',
                                    hariIni: '$hitungHariIni Unit',
                                ),
                            ),
                        ),

                        SliverAppBar(
                            backgroundColor: const Color(0xFFECEFF1),
                            elevation: 0,
                            scrolledUnderElevation: 0,
                            pinned: true,
                            automaticallyImplyLeading: false,
                            toolbarHeight: 124,
                            title: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        _buildSearchSection(),
                                        const SizedBox(height: 14),
                                        _buildFilterChipsRow(),
                                    ],
                                ),
                            ),
                        ),

                        filteredList.isEmpty
                            ? SliverToBoxAdapter(child: _buildEmptyState())
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 80.0),
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                            return _buildTagihanCard(filteredList[index]);
                                        },
                                        childCount: filteredList.length,
                                    ),
                                ),
                              ),
                    ],
                ),
            ),
            floatingActionButton: _buildFAB(),
        );
    }

    // DESAIN BARU: Tiga Kolom Flat Datar Borderless (Serasi Penuh Dengan Kotak Halaman List Kamar)
    Widget _buildKuantitasOverviewCard({required String menunggu, required String terlambat, required String hariIni}) {
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
                    _buildStatItem('Menunggu', menunggu, _statusMenunggu),
                    _buildStatDivider(),
                    _buildStatItem('Terlambat', terlambat, _statusTerlambat),
                    _buildStatDivider(),
                    _buildStatItem('Hari Ini', hariIni, _textSlatePrimary),
                ],
            ),
        );
    }

    Widget _buildStatItem(String label, String value, Color color) {
        return Expanded(
            child: Column(
                children: [
                    Text(
                        value, 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color)
                    ),
                    const SizedBox(height: 4),
                    Text(
                        label, 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 13, color: _textSlateMuted, fontWeight: FontWeight.w400)
                    ),
                ],
            ),
        );
    }

    Widget _buildStatDivider() {
        return Container(height: 32, width: 1, color: const Color(0xFFF1F5F9));
    }

    Widget _buildSearchSection() {
        return Container(
            height: 54,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: TextField(
                controller: _searchController,
                style: TextStyle(color: _textSlatePrimary, fontSize: 16, fontWeight: FontWeight.w400),
                onChanged: (val) {
                    setState(() { _searchQuery = val; });
                },
                decoration: InputDecoration(
                    hintText: 'Cari nama penyewa atau kamar...',
                    hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 15),
                    prefixIcon: Icon(Icons.search_rounded, color: _textSlateMuted, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: _textSlateMuted, size: 20),
                            onPressed: () {
                                _searchController.clear();
                                setState(() { _searchQuery = ''; });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
            ),
        );
    }

    Widget _buildFilterChipsRow() {
        final filters = ['Semua Aktif', 'Menunggu', 'Terlambat'];
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

    Widget _buildTagihanCard(Map<String, dynamic> item) {
        Color statusColor = item['status'] == 'Terlambat' ? _statusTerlambat : _statusMenunggu;
        bool isSent = item['status_kirim'] == 'Sudah dikirim';

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
                                Text(
                                    item['penyewa'],
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary, letterSpacing: -0.1),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                    children: [
                                        Text(
                                            item['kamar'],
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _textSlateMuted),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                            isSent ? Icons.done_all_rounded : Icons.schedule_send_rounded, 
                                            size: 14, 
                                            color: isSent ? _statusTerkirim : _textSlateMuted.withOpacity(0.5)
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            Text(
                                item['nominal'],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _textSlatePrimary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                    item['status'],
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                ),
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
                    Icon(Icons.space_dashboard_outlined, size: 44, color: _textSlateMuted.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('Semua bersih & kondusif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                    const SizedBox(height: 4),
                    Text('Tidak ada sisa tunggakan tagihan aktif yang tertinggal.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _textSlateMuted)),
                    const SizedBox(height: 14),
                    TextButton(
                        onPressed: () {
                            _searchController.clear();
                            setState(() {
                                _searchQuery = '';
                                _selectedFilter = 'Semua Aktif';
                            });
                        },
                        child: const Text('Reset Filter', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        );
    }

    Widget _buildFAB() {
        return FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: _tealPrimary,
            elevation: 2,
            icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            label: const Text('Generate Massal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
        );
    }
}
