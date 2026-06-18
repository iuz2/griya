import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'sub-pages/detail_kamar_page.dart';
import 'sub-pages/setup_kamar_page.dart';

class KamarPage extends StatefulWidget {
    const KamarPage({Key? key}) : super(key: key);

    @override
    State<KamarPage> createState() => _KamarPageState();
}

class _KamarPageState extends State<KamarPage> {
    final TextEditingController _searchController = TextEditingController();
    final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    String _selectedFilter = 'Semua';
    String _searchQuery = '';

    @override
    void dispose() {
        _searchController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final Query roomQuery = FirebaseDatabase.instance
            .ref()
            .child('users_data/$_currentUid/rooms');

        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1), 
            body: SafeArea(
                child: StreamBuilder<DatabaseEvent>(
                    stream: roomQuery.onValue,
                    builder: (context, snapshot) {
                        List<Map<String, dynamic>> allKamarRaw = [];

                        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                            final Map<dynamic, dynamic> roomsMap = 
                                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            
                            roomsMap.forEach((key, val) {
                                final Map<dynamic, dynamic> roomData = val as Map<dynamic, dynamic>;
                                
                                String statusMap = 'Kosong';
                                if (roomData['availability_status'] == 'occupied') {
                                    statusMap = (roomData['has_pending'] == true) ? 'Bermasalah' : 'Terisi';
                                }

                                allKamarRaw.add({
                                    'id': roomData['room_id']?.toString() ?? key.toString(),
                                    'nomor': roomData['room_name']?.toString() ?? 'Tanpa Nama',
                                    'status': statusMap,
                                    'penghuni': roomData['availability_status'] == 'occupied' ? 'Aktif' : '-',
                                    'harga_raw': roomData['price'] ?? 0,
                                    'harga': 'Rp ${roomData['price'] ?? 0} / bulan',
                                    'info': roomData['room_type']?.toString() ?? 'Standard',
                                });
                            });

                            allKamarRaw.sort((a, b) => a['nomor'].compareTo(b['nomor']));
                        }

                        final int totalKamar = allKamarRaw.length;
                        final int terisiKamar = allKamarRaw.where((k) => k['status'] == 'Terisi' || k['status'] == 'Bermasalah').length;
                        final int kosongKamar = allKamarRaw.where((k) => k['status'] == 'Kosong').length;

                        final List<Map<String, dynamic>> filteredKamar = allKamarRaw.where((kamar) {
                            final matchesSearch = kamar['nomor'].toLowerCase().contains(_searchQuery.toLowerCase());
                            
                            if (_selectedFilter == 'Semua') {
                                return matchesSearch;
                            } else if (_selectedFilter == 'Terisi') {
                                return matchesSearch && (kamar['status'] == 'Terisi' || kamar['status'] == 'Bermasalah');
                            } else if (_selectedFilter == 'Belum Bayar') {
                                return matchesSearch && kamar['status'] == 'Bermasalah';
                            }
                            return matchesSearch && kamar['status'] == _selectedFilter;
                        }).toList();

                        if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)));
                        }

                        return CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                                SliverAppBar(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    scrolledUnderElevation: 0,
                                    pinned: false, 
                                    title: const Text(
                                        'Manajemen Kamar',
                                        style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    centerTitle: true,
                                ),

                                SliverToBoxAdapter(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 4.0),
                                        child: _buildStatistikOverviewCard(totalKamar, terisiKamar, kosongKamar),
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

                                filteredKamar.isEmpty 
                                    ? SliverToBoxAdapter(child: _buildEmptyState())
                                    : SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 80.0),
                                        sliver: SliverList(
                                            delegate: SliverChildBuilderDelegate(
                                                (context, index) {
                                                    return _buildKamarCard(filteredKamar[index]);
                                                },
                                                childCount: filteredKamar.length,
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
    
    Widget _buildStatistikOverviewCard(int total, int terisi, int kosong) {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0), 
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0), 
                border: Border.all(color: const Color(0xFFCFD8DC), width: 1.2),
            ),
            child: Row(
                children: [
                    _buildStatItem('Total Unit', total.toString(), const Color(0xFF1E293B)),
                    _buildStatDivider(),
                    _buildStatItem('Terisi', terisi.toString(), const Color(0xFF0F766E)),
                    _buildStatDivider(),
                    _buildStatItem('Kosong', kosong.toString(), const Color(0xFF64748B)),
                ],
            ),
        );
    }

    Widget _buildStatItem(String label, String value, Color color) {
        return Expanded(
            child: Column(
                children: [
                    Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: color)),
                    const SizedBox(height: 4),
                    Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w400)),
                ],
            ),
        );
    }

    Widget _buildStatDivider() {
        return Container(height: 32, width: 1, color: const Color(0xFFCFD8DC));
    }

    Widget _buildSearchSection() {
        return Container(
            height: 54, 
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCFD8DC), width: 1.2),
            ),
            child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A), fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                    hintText: 'Cari nomor kamar kos...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: Color(0xFF64748B), size: 20),
                                onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
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
        final filters = ['Semua', 'Terisi', 'Kosong', 'Belum Bayar'];
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
                                    color: isActive ? const Color(0xFF0F766E) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isActive ? const Color(0xFF0F766E) : const Color(0xFFCFD8DC), width: 1.2),
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

    Widget _buildKamarCard(Map<String, dynamic> kamar) {
        Color badgeBgColor;
        Color badgeTextColor;
        String statusText = kamar['status'];

        switch (kamar['status']) {
            case 'Terisi':
                badgeBgColor = const Color(0xFFCCFBF1);
                badgeTextColor = const Color(0xFF115E59);
                break;
            case 'Kosong':
                badgeBgColor = const Color(0xFFF1F5F9);
                badgeTextColor = const Color(0xFF475569);
                break;
            case 'Bermasalah':
                badgeBgColor = const Color(0xFFFEE2E2);
                badgeTextColor = const Color(0xFF991B1B);
                statusText = 'Belum Bayar';
                break;
            default:
                badgeBgColor = const Color(0xFFF1F5F9);
                badgeTextColor = const Color(0xFF475569);
        }

        final Map<String, dynamic> mappedKamarData = {
            'room_id': kamar['id'],
            'nomor_kamar': kamar['nomor'],
            'status': statusText,
            'harga_sewa': kamar['harga_raw'],
            'room_type': kamar['info'],
        };

        return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(24.0), 
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24), 
                border: Border.all(color: const Color(0xFFCFD8DC), width: 1.2),
            ),
            child: Row(
                children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // KOREKSI SINTAKS MUTLAK: Bertumpuknya penunjuk parameter sudah dibersihkan total
                            children: [
                                Row(
                                    children: [
                                        Text(
                                            'Kamar ${kamar['nomor']}',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(8)),
                                            child: Text(
                                                statusText,
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeTextColor),
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                    'Tipe: ${kamar['info']}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 6),
                                Text(kamar['harga'], style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w400)),
                            ],
                        ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetailKamarPage(kamar: mappedKamarData)),
                            );
                        },
                    ),
                ],
            ),
        );
    }

    Widget _buildEmptyState() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
            alignment: Alignment.center,
            child: Column(
                children: [
                    const Text('🚪', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 12),
                    const Text('Tidak ada data kamar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    const Text('Hasil tidak ditemukan atau data database masih kosong.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    TextButton(
                        onPressed: () {
                            setState(() {
                                _selectedFilter = 'Semua';
                                _searchController.clear();
                                _searchQuery = '';
                            });
                        },
                        child: const Text('Reset Filter', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                    )
                ],
            ),
        );
    }

    Widget _buildFAB() {
        return FloatingActionButton.extended(
            onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SetupKamarPage()),
                );
            },
            backgroundColor: const Color(0xFF0F766E),
            elevation: 2,
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
            label: const Text('Kamar Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
        );
    }
}
