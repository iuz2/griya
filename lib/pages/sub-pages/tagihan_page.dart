import 'package:flutter/material.dart';

class TagihanPage extends StatefulWidget {
    const TagihanPage({Key? key}) : super(key: key);

    @override
    State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
    // State Kontrol UI
    String _selectedFilter = 'Semua Aktif';
    final TextEditingController _searchController = TextEditingController();
    String _searchQuery = '';

    // Palet Warna Minimalis Modern (Griya Premium Style)
    final Color _primaryColor = const Color(0xFF1A73E8);
    final Color _bgColor = const Color(0xFFF8F9FA);
    final Color _borderColor = const Color(0xFFE8EAED);
    final Color _textPrimary = const Color(0xFF202124);
    final Color _textSecondary = const Color(0xFF5F6368);

    // Identifikasi Status Berbasis Single Badge Kecil
    final Color _statusMenunggu = const Color(0xFFFBBC04); // Kuning/Orange
    final Color _statusTerlambat = const Color(0xFFEA4335); // Merah
    final Color _statusTerkirim = const Color(0xFF34A853);

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
                        // PERBAIKAN: Dibungkus SingleChildScrollView agar terhindar dari Bottom Overflowed
                        child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    // SECTION 1: HEADER (Nama & Kamar)
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
                                                    data['status'],
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor, letterSpacing: 0.3),
                                                ),
                                            ),
                                        ],
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // SECTION 2: FOKUS UTAMA (Total Tagihan)
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
                                                    'TOTAL TAGIHAN',
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
                                    
                                    // SECTION 3: RINCIAN BIAYA
                                    Text('Rincian Biaya', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: 0.3)),
                                    const SizedBox(height: 12),
                                    ...List.generate(data['rincian'].length, (index) {
                                        final item = data['rincian'][index];
                                        return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Row(
                                                children: [
                                                    Expanded(
                                                        child: Text(item['nama'], style: TextStyle(fontSize: 14, color: _textSecondary)),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(item['harga'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                                                ],
                                            ),
                                        );
                                    }),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // SECTION 4: INFO TAMBAHAN
                                    Text('Informasi Tagihan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: 0.3)),
                                    const SizedBox(height: 12),
                                    _buildDetailItem('No. WhatsApp', data['telepon']),
                                    _buildDetailItem('Status Pengiriman', data['status_kirim'], valueColor: isSent ? _statusTerkirim : _textSecondary),
                                    _buildDetailItem('Tanggal Tagihan', data['tanggal_tagihan']),
                                    _buildDetailItem('Status Tagihan', data['umur_tagihan'], valueColor: badgeColor, isBold: true),
                                    _buildDetailItem('Metode Bayar', 'Gateway Otomatis (Midtrans)'),
                                    
                                    const SizedBox(height: 28),
                                    
                                    // SECTION 5: TOMBOL AKSI
                                    if (data['status'] == 'Menunggu') ...[
                                        _buildBottomSheetButton(
                                            label: isSent ? 'Kirim Ulang Notifikasi WA' : 'Kirim Tagihan via WhatsApp',
                                            icon: Icons.chat_bubble_outline_rounded,
                                            color: const Color(0xFF34A853),
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildBottomSheetButton(
                                            label: 'Salin Tautan Pembayaran',
                                            icon: Icons.link_rounded,
                                            color: _primaryColor,
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

        int totalUangMenunggu = 0;
        int totalUangTerlambat = 0;
        int hitungHariIni = 0;

        for (var t in _allTagihanAktif) {
            if (t['status'] == 'Menunggu') totalUangMenunggu += t['nominal_raw'] as int;
            if (t['status'] == 'Terlambat') totalUangTerlambat += t['nominal_raw'] as int;
            if (t['umur_tagihan'] == 'Tempo Hari Ini') hitungHariIni++;
        }

        return Scaffold(
            backgroundColor: _bgColor,
            body: SafeArea(
                child: CustomScrollView(
                    slivers: [
                        _buildSliverAppBar(),
                        
                        SliverPersistentHeader(
                            pinned: false,
                            delegate: _StatistikTagihanDelegate(
                                menunggu: 'Rp ${_formatRupiahRaw(totalUangMenunggu)}',
                                terlambat: 'Rp ${_formatRupiahRaw(totalUangTerlambat)}',
                                hariIni: '$hitungHariIni Kamar',
                                statusMenungguColor: _statusMenunggu,
                                statusTerlambatColor: _statusTerlambat,
                            ),
                        ),

                        SliverPersistentHeader(
                            pinned: true,
                            delegate: _PinnedHeaderDelegate(
                                height: 116.0,
                                child: Column(
                                    children: [
                                        const SizedBox(height: 8),
                                        _buildSearchSection(),
                                        _buildFilterChips(),
                                    ],
                                ),
                            ),
                        ),

                        filteredList.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: _primaryColor,
                elevation: 2,
                icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                label: const Text(
                    'Generate Tagihan Massal',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                ),
            ),
        );
    }

    Widget _buildSliverAppBar() {
        return SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            title: Text(
                'Tagihan Aktif',
                style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
            ),
            actions: [
                IconButton(
                    icon: Icon(Icons.refresh_rounded, color: _textSecondary, size: 22),
                    onPressed: () => setState(() {}),
                ),
                IconButton(
                    icon: Icon(Icons.tune_rounded, color: _textSecondary, size: 22),
                    onPressed: () {},
                ),
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: _borderColor, height: 1),
            ),
        );
    }

    Widget _buildSearchSection() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                height: 46,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderColor),
                ),
                child: TextField(
                    controller: _searchController,
                    cursorColor: _primaryColor,
                    style: TextStyle(color: _textPrimary, fontSize: 15),
                    onChanged: (val) {
                        setState(() { _searchQuery = val; });
                    },
                    decoration: InputDecoration(
                        hintText: 'Cari nama penyewa atau kamar...',
                        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: _textSecondary.withOpacity(0.7), size: 18),
                        suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: _textSecondary, size: 18),
                                onPressed: () {
                                    _searchController.clear();
                                    setState(() { _searchQuery = ''; });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                ),
            ),
        );
    }

    Widget _buildFilterChips() {
        final filters = ['Semua Aktif', 'Menunggu', 'Terlambat'];
        return Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                    final filter = filters[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: _primaryColor.withOpacity(0.08),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? _primaryColor : _textSecondary,
                            ),
                            side: BorderSide(color: isSelected ? _primaryColor : _borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            showCheckmark: false,
                            onSelected: (secure) {
                                if (secure) {
                                    setState(() { _selectedFilter = filter; });
                                }
                            },
                        ),
                    );
                },
            ),
        );
    }

    // REVISI KOREKSI 2: Ditambahkan penanda status kirim (done_all/schedule_send) di sebelah nomor kamar
    Widget _buildTagihanCard(Map<String, dynamic> item) {
        Color statusColor = item['status'] == 'Terlambat' ? _statusTerlambat : _statusMenunggu;
        bool isSent = item['status_kirim'] == 'Sudah dikirim';

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
                                            Text(
                                                item['penyewa'],
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: -0.1),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                                children: [
                                                    Text(
                                                        item['kamar'],
                                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textSecondary),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Indikator icon penanda distribusi pengiriman mini yang bersih
                                                    Icon(
                                                        isSent ? Icons.done_all_rounded : Icons.schedule_send_rounded, 
                                                        size: 14, 
                                                        color: isSent ? _statusTerkirim : _textSecondary.withOpacity(0.5)
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
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                                item['status'],
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.3),
                                            ),
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
                        Icon(Icons.space_dashboard_outlined, size: 48, color: _textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('Semua bersih & kondusif', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary)),
                        const SizedBox(height: 4),
                        Text('Tidak ada sisa tunggakan tagihan aktif yang tertinggal pada filter ini.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: _textSecondary)),
                        const SizedBox(height: 20),
                        OutlinedButton(
                            onPressed: () {
                                _searchController.clear();
                                setState(() {
                                    _searchQuery = '';
                                    _selectedFilter = 'Semua Aktif';
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

    String _formatRupiahRaw(int value) {
        String stringValue = value.toString();
        return stringValue.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
}

class _StatistikTagihanDelegate extends SliverPersistentHeaderDelegate {
    final String menunggu;
    final String terlambat;
    final String hariIni;
    final Color statusMenungguColor;
    final Color statusTerlambatColor;

    _StatistikTagihanDelegate({
        required this.menunggu,
        required this.terlambat,
        required this.hariIni,
        required this.statusMenungguColor,
        required this.statusTerlambatColor,
    });

    @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
        double maxOffset = maxExtent - minExtent;
        double progress = (shrinkOffset / maxOffset).clamp(0.0, 1.0);

        double marginVertical = 16.0 - (16.0 * progress);
        double opacity = progress > 0.85 ? 0.0 : 1.0;

        return Opacity(
            opacity: opacity,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: marginVertical),
                child: Row(
                    children: [
                        _buildStatItem('Menunggu Bayar', menunggu, Icons.hourglass_empty_rounded, statusMenungguColor, progress),
                        _buildStatItem('Total Terlambat', terlambat, Icons.warning_amber_rounded, statusTerlambatColor, progress),
                        _buildStatItem('Tempo Hari Ini', hariIni, Icons.notification_important_outlined, Colors.purple, progress),
                    ],
                ),
            ),
        );
    }

    Widget _buildStatItem(String label, String value, IconData icon, Color color, double progress) {
        double currentWidth = 165.0 - (20.0 * progress);
        double currentPadding = 16.0 - (6.0 * progress);
        double currentIconPadding = 6.0 - (2.0 * progress);
        double currentIconSize = 18.0 - (4.0 * progress);
        
        return Container(
            width: currentWidth,
            margin: const EdgeInsets.only(right: 12),
            clipBehavior: Clip.hardEdge, 
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(currentPadding),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            padding: EdgeInsets.all(currentIconPadding),
                            decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
                            child: Icon(icon, color: color, size: currentIconSize),
                        ),
                        const SizedBox(height: 14),
                        Text(
                            value,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202124), letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                            label,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF5F7A90), fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                        ),
                    ],
                ),
            ),
        );
    }

    @override
    double get maxExtent => 170.0; 
    
    @override
    double get minExtent => 90.0;

    @override
    bool shouldRebuild(covariant _StatistikTagihanDelegate oldDelegate) {
        return menunggu != oldDelegate.menunggu || terlambat != oldDelegate.terlambat || hariIni != oldDelegate.hariIni;
    }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
    final Widget child;
    final double height;

    _PinnedHeaderDelegate({required this.child, required this.height});

    @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
        return Container(
            color: const Color(0xFFF8F9FA),
            child: child,
        );
    }

    @override
    double get maxExtent => height;
    @override
    double get minExtent => height;
    @override
    bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
        return true;
    }
}
