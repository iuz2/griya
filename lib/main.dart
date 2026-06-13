import 'package:flutter/material.dart';
import 'pages/kamar_page.dart';
import 'pages/keuangan_page.dart';
import 'pages/lainnya_page.dart';

void main() {
    runApp(const GriyaApp());
}

class GriyaApp extends StatelessWidget {
    const GriyaApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Griya',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: const Color(0xFF1A73E8),
                scaffoldBackgroundColor: const Color(0xFFF8F9FA),
                useMaterial3: true,
                fontFamily: 'Roboto',
            ),
            home: const MainScreen(),
        );
    }
}

class MainScreen extends StatefulWidget {
    const MainScreen({Key? key}) : super(key: key);

    @override
    State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    int _selectedIndex = 0;

    final List<Widget> _pages = [
        const BerandaPage(),
        const KamarPage(),
        const KeuanganPage(),
        const LainnyaPage(),
    ];

    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: IndexedStack(
                index: _selectedIndex,
                children: _pages,
            ),
            bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE8EAED), width: 1)),
                ),
                child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    backgroundColor: const Color(0xFFFFFFFF),
                    selectedItemColor: const Color(0xFF1A73E8),
                    unselectedItemColor: const Color(0xFF9CA3AF),
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.dashboard_outlined),
                            activeIcon: Icon(Icons.dashboard),
                            label: 'Beranda',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.bed_outlined),
                            activeIcon: Icon(Icons.bed),
                            label: 'Kamar',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.account_balance_wallet_outlined),
                            activeIcon: Icon(Icons.account_balance_wallet),
                            label: 'Keuangan',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.menu),
                            activeIcon: Icon(Icons.menu_open),
                            label: 'Lainnya',
                        ),
                    ],
                ),
            ),
        );
    }
}

// -------------------------------------------------------------
// HALAMAN BERANDA (ACTION-FIRST DASHBOARD V2)
// -------------------------------------------------------------

class BerandaPage extends StatefulWidget {
    const BerandaPage({Key? key}) : super(key: key);

    @override
    State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
    bool _isRefreshing = false;
    
    // REVISI 9: Setup Micro Animation Halus Menggunakan Animasi Sekuensial Berkelanjutan
    late AnimationController _animationController;
    late Animation<double> _fadeWelcome;
    late Animation<double> _fadeHero;
    late Animation<double> _fadeAttention;
    late Animation<double> _fadeAlert;
    late Animation<double> _fadeGrid;
    late Animation<double> _fadeActions;
    late Animation<double> _fadeInsight;
    late Animation<double> _fadeRecent;

    // Dummy Data Tugas Harian Pemilik Kos
    final int _waitingVerificationCount = 2;
    final int _overdueInvoicesCount = 1;
    final int _dueTodayInvoicesCount = 3;

    // Flag Kondisi Kritis untuk Alert Banner
    final bool _hasCriticalAlert = true; 

    @override
    void initState() {
        super.initState();
        _animationController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 900),
        );

        _fadeWelcome = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)));
        _fadeHero = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)));
        _fadeAttention = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)));
        _fadeAlert = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)));
        _fadeGrid = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)));
        _fadeActions = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic)));
        _fadeInsight = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)));
        _fadeRecent = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic)));

        _animationController.forward();
    }

    @override
    void dispose() {
        _animationController.dispose();
        super.dispose();
    }

    Future<void> _handleRefresh() async {
        setState(() => _isRefreshing = true);
        _animationController.reset();
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() => _isRefreshing = false);
        _animationController.forward();
    }

    String _getGreeting() {
        final hour = DateTime.now().hour;
        if (hour < 12) return 'Pagi';
        if (hour < 18) return 'Siang';
        return 'Malam';
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
                backgroundColor: const Color(0xFFFFFFFF),
                elevation: 0,
                scrolledUnderElevation: 1,
                title: const Text(
                    'Beranda',
                    style: TextStyle(color: Color(0xFF202124), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                actions: [
                    IconButton(
                        icon: const Badge(
                            backgroundColor: Color(0xFFEA4335),
                            label: Text('2'),
                            child: Icon(Icons.notifications_none_outlined, color: Color(0xFF5F6368)),
                        ),
                        onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(color: const Color(0xFFE8EAED), height: 1),
                ),
            ),
            body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF1A73E8),
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                FadeTransition(opacity: _fadeWelcome, child: _buildWelcomeSection()),
                                FadeTransition(opacity: _fadeHero, child: _buildHeroCard()),
                                const SizedBox(height: 12),
                                FadeTransition(opacity: _fadeAttention, child: _buildPerluPerhatianSection()),
                                // REVISI 2: Alert banner dikondisikan hanya muncul untuk kasus darurat berskala kritis
                                if (_hasCriticalAlert) FadeTransition(opacity: _fadeAlert, child: _buildAlertBanner()),
                                const SizedBox(height: 16),
                                FadeTransition(opacity: _fadeGrid, child: _buildModifiedStatGrid()),
                                const SizedBox(height: 20),
                                FadeTransition(opacity: _fadeActions, child: _buildQuickActions()),
                                const SizedBox(height: 20),
                                FadeTransition(opacity: _fadeInsight, child: _buildMiniInsightAndTrendSection()),
                                const SizedBox(height: 20),
                                FadeTransition(opacity: _fadeRecent, child: _buildRecentActivity()),
                                const SizedBox(height: 40),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildWelcomeSection() {
        return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        '${_getGreeting()}, Budi! 👋',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                        'Senin, 15 Juni 2026',
                        style: TextStyle(fontSize: 13, color: Color(0xFF5F7A90), fontWeight: FontWeight.w500),
                    ),
                ],
            ),
        );
    }

    Widget _buildHeroCard() {
        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EAED)),
                boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        'PEMASUKAN BULAN INI',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5F7A90), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            'Rp 4.500.000',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8), letterSpacing: -0.5),
                        ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                        children: [
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF34A853).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                    children: [
                                        Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFF34A853)),
                                        SizedBox(width: 4),
                                        Text('15% dari bulan lalu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF34A853))),
                                    ],
                                ),
                            ),
                            const Spacer(),
                            const Text('12 pembayaran semenjak awal', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                        ],
                    ),
                ],
            ),
        );
    }

    // REVISI 1: Section Baru "Perlu Perhatian Hari Ini" (Compact & Action-Driven)
    Widget _buildPerluPerhatianSection() {
        final hasTasks = _waitingVerificationCount > 0 || _overdueInvoicesCount > 0 || _dueTodayInvoicesCount > 0;

        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        'Perlu Perhatian Hari Ini',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                    ),
                    const SizedBox(height: 8),
                    if (!hasTasks)
                        Row(
                            children: const [
                                Icon(Icons.check_circle_outline_rounded, color: Color(0xFF34A853), size: 16),
                                SizedBox(width: 8),
                                Text('Tidak ada tindakan penting hari ini', style: TextStyle(fontSize: 13, color: Color(0xFF34A853), fontWeight: FontWeight.w500)),
                            ],
                        )
                    else ...[
                        if (_waitingVerificationCount > 0)
                            _buildPerluPerhatianItem(Icons.hourglass_empty_rounded, '$_waitingVerificationCount pembayaran menunggu verifikasi', const Color(0xFFFBBC04)),
                        if (_overdueInvoicesCount > 0)
                            _buildPerluPerhatianItem(Icons.warning_amber_rounded, '$_overdueInvoicesCount kamar terlambat bayar sewa kos', const Color(0xFFEA4335)),
                        if (_dueTodayInvoicesCount > 0)
                            _buildPerluPerhatianItem(Icons.receipt_long_rounded, '$_dueTodayInvoicesCount tagihan jatuh tempo hari ini', const Color(0xFF1A73E8)),
                    ],
                ],
            ),
        );
    }

    Widget _buildPerluPerhatianItem(IconData icon, String text, Color color) {
        return Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {},
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                        children: [
                            Icon(icon, size: 15, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF202124), fontWeight: FontWeight.w500),
                                ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF9CA3AF)),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildAlertBanner() {
        return Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: Color(0xFFEA4335), width: 4)),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Icon(Icons.gavel_rounded, color: Color(0xFFEA4335), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                    'KRITIS: Kamar 102 menunggak > 1 bulan',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                    'Segera tindak lanjuti tagihan sebesar Rp 900.000',
                                    style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                    children: [
                                        ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFEA4335),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                                minimumSize: const Size(0, 28),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                elevation: 0,
                                            ),
                                            child: const Text('Hubungi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                                foregroundColor: const Color(0xFFB91C1C),
                                                minimumSize: const Size(0, 28),
                                            ),
                                            child: const Text('Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    // REVISI 3 & 4: Gabungkan Stat Grid Menjadi Card Hunian & Card Status Pembayaran Berdampingan Simetris
    Widget _buildModifiedStatGrid() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // CARD HUNIAN KAMAR (Kiri)
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8EAED)),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const Text('Hunian Kamar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                                    const SizedBox(height: 8),
                                    const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text('12 / 15 Terisi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: const LinearProgressIndicator(
                                            value: 0.8,
                                            backgroundColor: Color(0xFFE8EAED),
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
                                            minHeight: 4,
                                        ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: const [
                                            Text('80% Rasio', style: TextStyle(fontSize: 11, color: Color(0xFF5F7A90), fontWeight: FontWeight.w500)),
                                            Text('3 kosong', style: TextStyle(fontSize: 11, color: Color(0xFF34A853), fontWeight: FontWeight.bold)),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    // CARD STATUS PEMBAYARAN (Kanan)
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8EAED)),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const Text('Status Pembayaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5F7A90))),
                                    const SizedBox(height: 10),
                                    _buildStatusBadgeRow('Pending', '2', const Color(0xFFFBBC04)),
                                    const SizedBox(height: 6),
                                    _buildStatusBadgeRow('Terlambat', '1', const Color(0xFFEA4335)),
                                    const SizedBox(height: 6),
                                    _buildStatusBadgeRow('Aktif', '12', const Color(0xFF1A73E8)),
                                ],
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildStatusBadgeRow(String label, String count, Color color) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF202124), fontWeight: FontWeight.w500)),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                        count,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                    ),
                ),
            ],
        );
    }

    // REVISI 5: Menyederhanakan Tombol Menjadi 2 Saja Dan Berukuran Besar Menonjol
    Widget _buildQuickActions() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                children: [
                    Expanded(child: _buildModifiedActionButton(Icons.payments_outlined, 'Catat Pembayaran', const Color(0xFF1A73E8))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModifiedActionButton(Icons.fact_check_outlined, 'Verifikasi Bayar', const Color(0xFF34A853))),
                ],
            ),
        );
    }

    Widget _buildModifiedActionButton(IconData icon, String label, Color color) {
        return ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                surfaceTintColor: Colors.white,
                elevation: 0,
                side: BorderSide(color: color.withOpacity(0.3), width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                        ),
                    ),
                ],
            ),
        );
    }

    // REVISI 6 & 7: Kombinasi Section Mini Insight & Mini Trend Visual (Sparkline) Saling Menyeimbangkan
    Widget _buildMiniInsightAndTrendSection() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text('Ringkasan Bulan Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                        const SizedBox(height: 10),
                        _buildInsightInlineRow('📈', 'Pemasukan naik 15% dibanding bulan lalu'),
                        const SizedBox(height: 6),
                        _buildInsightInlineRow('🏠', 'Tingkat hunian stabil di atas 80%'),
                        const SizedBox(height: 6),
                        _buildInsightInlineRow('⚡', 'Pengeluaran listrik naik sekitar 8%'),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: Color(0xFFE8EAED)),
                        ),
                        const Text('Tren Pendapatan 7 Hari', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5F6368))),
                        const SizedBox(height: 10),
                        // Mini Sparkline tanpa menggunakan package eksternal
                        SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: CustomPaint(
                                painter: _MiniSparklinePainter(lineColor: const Color(0xFF1A73E8)),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    Widget _buildInsightInlineRow(String emoji, String text) {
        return Row(
            children: [
                Text(emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF202124), fontWeight: FontWeight.w500),
                    ),
                ),
            ],
        );
    }

    // REVISI 8: Aktivitas Terbaru Ditingkatkan Melalui Feedback Visual Ripple & Chevron Kanan
    Widget _buildRecentActivity() {
        final List<Map<String, dynamic>> activities = [
            {'kamar': 'Kamar 101', 'nominal': 'Rp 450.000', 'time': '15:30', 'status': 'Lunas', 'isSuccess': true},
            {'kamar': 'Kamar 105', 'nominal': 'Rp 400.000', 'time': '14:00', 'status': 'Pending', 'isSuccess': false},
            {'kamar': 'Kamar 103', 'nominal': 'Rp 450.000', 'time': 'Kemarin', 'status': 'Lunas', 'isSuccess': true},
        ];

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                            TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                            ),
                        ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8EAED)),
                        ),
                        child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activities.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE8EAED)),
                            itemBuilder: (context, index) {
                                final item = activities[index];
                                final isSuccess = item['isSuccess'] as bool;
                                return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: () {}, // Trigger feedback riak air (ripple effect)
                                        borderRadius: index == 0 
                                            ? const BorderRadius.vertical(top: Radius.circular(12)) 
                                            : index == activities.length - 1 
                                                ? const BorderRadius.vertical(bottom: Radius.circular(12)) 
                                                : BorderRadius.zero,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            child: Row(
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            color: isSuccess ? const Color(0xFF34A853).withOpacity(0.08) : const Color(0xFFFBBC04).withOpacity(0.08),
                                                            shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                            isSuccess ? Icons.check_circle_outline_rounded : Icons.hourglass_empty_rounded,
                                                            color: isSuccess ? const Color(0xFF34A853) : const Color(0xFFFBBC04),
                                                            size: 18,
                                                        ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                                Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                        Text(item['kamar'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                                                                        Text(item['nominal'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                                                                    ],
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                        Text(item['time'], style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                                                                        Text(item['status'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSuccess ? const Color(0xFF34A853) : const Color(0xFFFBBC04))),
                                                                    ],
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                                                ],
                                            ),
                                        ),
                                    ),
                                );
                            },
                        ),
                    ),
                ],
            ),
        );
    }
}

// Custom Painter untuk Menggambar Sparkline Mini 7 Hari Tanpa Plugin Eksternal
class _MiniSparklinePainter extends CustomPainter {
    final Color lineColor;
    _MiniSparklinePainter({required this.lineColor});

    @override
    void paint(Canvas canvas, Size size) {
        final paintLine = Paint()
            ..color = lineColor
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

        final paintFill = Paint()
            ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [lineColor.withOpacity(0.12), lineColor.withOpacity(0.0)],
            ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

        // Contoh Koordinat Statis Mini Trend Laba Kos 7 Hari Terakhir
        final List<Offset> points = [
            Offset(0, size.height * 0.70),
            Offset(size.width * 0.16, size.height * 0.75),
            Offset(size.width * 0.32, size.height * 0.45),
            Offset(size.width * 0.48, size.height * 0.55),
            Offset(size.width * 0.64, size.height * 0.25),
            Offset(size.width * 0.80, size.height * 0.30),
            Offset(size.width, size.height * 0.10),
        ];

        final path = Path()..moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
            final prev = points[i - 1];
            final current = points[i];
            path.cubicTo((prev.dx + current.dx) / 2, prev.dy, (prev.dx + current.dx) / 2, current.dy, current.dx, current.dy);
        }

        final fillPath = Path.from(path)
            ..lineTo(size.width, size.height)
            ..lineTo(0, size.height)
            ..close();

        canvas.drawPath(fillPath, paintFill);
        canvas.drawPath(path, paintLine);
    }

    @override
    bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) => false;
}
