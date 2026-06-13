import 'package:flutter/material.dart';
import 'sub-pages/detail_kamar_page.dart';
import 'sub-pages/setup_kamar_page.dart';

class KamarPage extends StatefulWidget {
    const KamarPage({Key? key}) : super(key: key);

    @override
    State<KamarPage> createState() => _KamarPageState();
}

class _KamarPageState extends State<KamarPage> {
    final TextEditingController _searchController = TextEditingController();
    
    String _selectedFilter = 'Semua';
    String _searchQuery = '';

    final List<Map<String, dynamic>> _allKamar = [
        {'nomor': 'Kamar 101', 'status': 'Terisi', 'penghuni': 'Budi Santoso', 'harga': 'Rp 450.000 / bulan', 'info': 'Masuk: 15 Jan 2024'},
        {'nomor': 'Kamar 102', 'status': 'Kosong', 'penghuni': '-', 'harga': 'Rp 400.000 / bulan', 'info': 'Siap diisi'},
        {'nomor': 'Kamar 103', 'status': 'Bermasalah', 'penghuni': 'Rina Kusuma', 'harga': 'Rp 450.000 / bulan', 'info': 'Tunggakan: 2 bulan'},
        {'nomor': 'Kamar 104', 'status': 'Terisi', 'penghuni': 'Ahmad Fauzi', 'harga': 'Rp 500.000 / bulan', 'info': 'Masuk: 01 Feb 2024'},
        {'nomor': 'Kamar 105', 'status': 'Kosong', 'penghuni': '-', 'harga': 'Rp 400.000 / bulan', 'info': 'Siap diisi'},
    ];

    int get _totalKamar => _allKamar.length;
    int get _terisiKamar => _allKamar.where((k) => k['status'] == 'Terisi' || k['status'] == 'Bermasalah').length;
    int get _kosongKamar => _allKamar.where((k) => k['status'] == 'Kosong').length;

    List<Map<String, dynamic>> get _filteredKamar {
        return _allKamar.where((kamar) {
            final matchesSearch = kamar['nomor'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                kamar['penghuni'].toLowerCase().contains(_searchQuery.toLowerCase());
            
            if (_selectedFilter == 'Semua') {
                return matchesSearch;
            } else if (_selectedFilter == 'Terisi') {
                return matchesSearch && (kamar['status'] == 'Terisi' || kamar['status'] == 'Bermasalah');
            } else if (_selectedFilter == 'Belum Bayar') {
                return matchesSearch &&
                    kamar['status'] == 'Bermasalah';
            }

            return matchesSearch &&
                kamar['status'] == _selectedFilter;
        }).toList();
    }

    @override
    void dispose() {
        _searchController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
                child: CustomScrollView(
                    slivers: [
                        _buildSliverAppBar(),
                        SliverPersistentHeader(
                            pinned: false,
                            delegate: _StatistikDelegate(
                                total: _totalKamar,
                                terisi: _terisiKamar,
                                kosong: _kosongKamar,
                            ),
                        ),
                        SliverPersistentHeader(
                            pinned: true,
                            delegate: _PinnedHeaderDelegate(
                                height: 112.0,
                                child: Column(
                                    children: [
                                        const SizedBox(height: 8),
                                        _buildSearchFilterSection(),
                                        _buildFilterChips(),
                                    ],
                                ),
                            ),
                        ),
                        _filteredKamar.isEmpty 
                            ? SliverFillRemaining(child: _buildEmptyState())
                            : SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                            return _buildKamarCard(_filteredKamar[index]);
                                        },
                                        childCount: _filteredKamar.length,
                                    ),
                                ),
                            ),
                    ],
                ),
            ),
            floatingActionButton: _buildFAB(),
        );
    }

    Widget _buildSliverAppBar() {
        return SliverAppBar(
            backgroundColor: const Color(0xFFFFFFFF),
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            title: const Text(
                'Manajemen Kamar',
                style: TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),
            ),
            actions: [
                IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF5F6368)),
                    onPressed: () {
                        setState(() {});
                    },
                ),
                IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF5F6368)),
                    onPressed: () {},
                ),
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: const Color(0xFFE8EAED), height: 1),
            ),
        );
    }

    Widget _buildSearchFilterSection() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                children: [
                    Expanded(
                        child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE8EAED)),
                            ),
                            child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                    setState(() {
                                        _searchQuery = value;
                                    });
                                },
                                decoration: InputDecoration(
                                    hintText: 'Cari kamar, nama...',
                                    hintStyle: const TextStyle(color: Color(0xFF5F7A90), fontSize: 14),
                                    prefixIcon: const Icon(Icons.search, color: Color(0xFF5F7A90), size: 20),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                                icon: const Icon(Icons.clear, color: Color(0xFF5F7A90), size: 20),
                                                onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                        _searchQuery = '';
                                                    });
                                                },
                                            )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                            ),
                        ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE8EAED)),
                        ),
                        child: IconButton(
                            icon: const Icon(Icons.tune, color: Color(0xFF202124), size: 20),
                            onPressed: () {},
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildFilterChips() {
        final filters = [
           'Semua',
           'Terisi',
           'Kosong',
           'Belum Bayar'
        ];
        return Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                    final filter = filters[index];
                    final isActive = _selectedFilter == filter;
                    return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(filter),
                            selected: isActive,
                            onSelected: (selected) {
                                if (selected) {
                                    setState(() {
                                        _selectedFilter = filter;
                                    });
                                }
                            },
                            selectedColor: const Color(0xFF1A73E8).withOpacity(0.15),
                            backgroundColor: const Color(0xFFFFFFFF),
                            labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? const Color(0xFF1A73E8) : const Color(0xFF5F7A90),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: isActive ? const Color(0xFF1A73E8) : const Color(0xFFE8EAED),
                                ),
                            ),
                            showCheckmark: false,
                        ),
                    );
                },
            ),
        );
    }

    Widget _buildEmptyState() {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.home_work_outlined, size: 64, color: Color(0xFF9CA3AF)),
                    const SizedBox(height: 16),
                    const Text(
                        'Tidak Ada Data!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                        'Tidak ditemukan data yang sesuai dengan pencarian atau filter. ',
                        style: TextStyle(fontSize: 14, color: Color(0xFF5F7A90)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                        onPressed: () {
                            setState(() {
                                _selectedFilter = 'Semua';
                                _searchController.clear();
                                _searchQuery = '';
                            });
                        },
                        child: const Text('Kembali ke semua kamar', style: TextStyle(color: Color(0xFF1A73E8))),
                    )
                ],
            ),
        );
    }

    Widget _buildKamarCard(Map<String, dynamic> kamar) {
        Color badgeBgColor;
        Color badgeTextColor;
        String statusText = kamar['status'];

        switch (kamar['status']) {
            case 'Terisi':
                badgeBgColor = const Color(0xFF34A853).withOpacity(0.15);
                badgeTextColor = const Color(0xFF34A853);
                break;
            case 'Kosong':
                badgeBgColor = const Color(0xFF1A73E8).withOpacity(0.15);
                badgeTextColor = const Color(0xFF1A73E8);
                break;
            case 'Bermasalah':
                badgeBgColor = const Color(0xFFEA4335).withOpacity(0.15);
                badgeTextColor = const Color(0xFFEA4335);
                statusText = 'Belum Bayar';
                break;
            default:
                badgeBgColor = const Color(0xFF9CA3AF).withOpacity(0.15);
                badgeTextColor = const Color(0xFF5F6368);
        }

        // Mapping parameter data lokal agar sinkron dengan kebutuhan parser DetailKamarPage
        final Map<String, dynamic> mappedKamarData = {
            'nomor_kamar': kamar['nomor']?.toString().replaceAll('Kamar ', '') ?? '-',
            'status': statusText,
            'nama_penghuni': kamar['penghuni'],
            'harga_sewa': kamar['harga'],
            'catatan': kamar['info'],
            'telepon': kamar['status'] == 'Kosong' ? '-' : '081234567890', // Default fallback value
            'alamat': kamar['status'] == 'Kosong' ? '-' : 'Yogyakarta', // Default fallback value
            'tanggal_masuk': kamar['status'] == 'Terisi' ? '15 Jan 2024' : (kamar['status'] == 'Bermasalah' ? '01 Des 2023' : '-'),
            'jatuh_tempo': kamar['status'] == 'Kosong' ? '-' : '15 tiap bulan',
            'status_pembayaran': kamar['status'] == 'Bermasalah' ? 'Belum Lunas' : (kamar['status'] == 'Terisi' ? 'Lunas' : '-'),
            'total_tunggakan': kamar['status'] == 'Bermasalah' ? 'Rp 900.000' : '0',
        };

        return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EAED)),
                boxShadow: const [
                    BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                    ),
                ],
            ),
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailKamarPage(kamar: mappedKamarData),
                            ),
                        );
                    },
                    onLongPress: () => _showContextMenu(kamar),
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Row(
                                                children: [
                                                    Text(
                                                        kamar['nomor'],
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF202124),
                                                        ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                            color: badgeBgColor,
                                                            borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                            statusText,
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.bold,
                                                                color: badgeTextColor,
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                kamar['penghuni'],
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF202124),
                                                ),
                                            ),
                                            const SizedBox(height: 2),
                                            Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(
                                                        kamar['harga'],
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xFF5F7A90),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                        kamar['info'],
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(0xFF9CA3AF),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildFAB() {
        return FloatingActionButton.extended(
            onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SetupKamarPage(),
                    ),
                );
            },
            backgroundColor: const Color(0xFF1A73E8),
            elevation: 6,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
                'Kamar Baru',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                ),
            ),
        );
    }

    void _showContextMenu(Map<String, dynamic> kamar) {
        showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFFFFFFFF),
            builder: (context) {
                return SafeArea(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            ListTile(
                                leading: const Icon(Icons.edit, color: Color(0xFF1A73E8)),
                                title: const Text('Edit Kamar'),
                                onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                                leading: const Icon(Icons.phone, color: Color(0xFF34A853)),
                                title: const Text('Hubungi Penghuni'),
                                onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                                leading: const Icon(Icons.delete, color: Color(0xFFEA4335)),
                                title: const Text('Hapus Kamar', style: TextStyle(color: Color(0xFFEA4335))),
                                onTap: () {
                                    Navigator.pop(context);
                                    _showDeleteConfirmation(kamar);
                                },
                            ),
                        ],
                    ),
                );
            },
        );
    }

    void _showDeleteConfirmation(Map<String, dynamic> kamar) {
        showDialog(
            context: context,
            builder: (context) {
                return AlertDialog(
                    backgroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text('Hapus ${kamar['nomor']}?'),
                    content: const Text('Apakah Anda yakin ingin menghapus kamar ini? Tindakan ini tidak dapat dibatalkan.'),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(color: Color(0xFF5F6368))),
                        ),
                        ElevatedButton(
                            onPressed: () {
                                Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA4335),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                        ),
                    ],
                );
            },
        );
    }

}

class _StatistikDelegate extends SliverPersistentHeaderDelegate {
    final int total;
    final int terisi;
    final int kosong;

    _StatistikDelegate({
        required this.total,
        required this.terisi,
        required this.kosong,
    });

    @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
        double maxOffset = maxExtent - minExtent;
        double progress = (shrinkOffset / maxOffset).clamp(0.0, 1.0);

        double marginVertical = 16.0 - (16.0 * progress);
        double opacity = progress > 0.85 ? 0.0 : 1.0;

        return Opacity(
            opacity: opacity,
            child: Container(
                margin: EdgeInsets.fromLTRB(16, marginVertical, 16, marginVertical),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        Expanded(child: _buildStatItem('Total', total.toString(), Icons.inventory_2, const Color(0xFF1A73E8), progress)),
                        Expanded(child: _buildStatItem('Terisi', terisi.toString(), Icons.people, const Color(0xFF34A853), progress)),
                        Expanded(child: _buildStatItem('Kosong', kosong.toString(), Icons.home, const Color(0xFFFBBC04), progress)),
                    ],
                ),
            ),
        );
    }

    Widget _buildStatItem(String label, String value, IconData icon, Color color, double progress) {
        double currentIconSize = 18.0 - (4.0 * progress);
        double currentNumberSize = 26.0 - (10.0 * progress);
        double currentLabelSize = 12.0 - (3.0 * progress);
        double currentSpacing = 4.0 - (3.0 * progress);

        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Icon(icon, size: currentIconSize, color: color),
                SizedBox(height: currentSpacing),
                AnimatedDefaultTextStyle(
                    duration: Duration.zero,
                    style: TextStyle(
                        fontSize: currentNumberSize, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF202124)
                    ),
                    child: Text(value),
                ),
                SizedBox(height: currentSpacing),
                AnimatedDefaultTextStyle(
                    duration: Duration.zero,
                    style: TextStyle(
                        fontSize: currentLabelSize, 
                        color: const Color(0xFF5F7A90), 
                        fontWeight: FontWeight.w500
                    ),
                    child: Text(label),
                ),
            ],
        );
    }

    @override
    double get maxExtent => 148.0; 
    
    @override
    double get minExtent => 50.0;

    @override
    bool shouldRebuild(covariant _StatistikDelegate oldDelegate) {
        return total != oldDelegate.total || terisi != oldDelegate.terisi || kosong != oldDelegate.kosong;
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
