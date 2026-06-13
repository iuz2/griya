import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget {
    const LaporanPage({Key? key}) : super(key: key);

    @override
    State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    
    // Animasi sekuensial (Staggered) untuk meningkatkan kesan premium tanpa merusak performa
    late Animation<double> _fadeFinansial;
    late Animation<double> _fadeGrafik;
    late Animation<double> _fadeInsight;
    late Animation<double> _fadeRingkasan;
    late Animation<double> _fadeMetrik;

    late Animation<Offset> _slideFinansial;
    late Animation<Offset> _slideGrafik;
    late Animation<Offset> _slideInsight;
    late Animation<Offset> _slideRingkasan;
    late Animation<Offset> _slideMetrik;

    String _selectedPeriod = 'Juni 2026';

    // Palet Warna Griya Premium Minimalis
    final Color _primaryColor = const Color(0xFF1A73E8);
    final Color _bgColor = const Color(0xFFF8F9FA);
    final Color _borderColor = const Color(0xFFE8EAED);
    final Color _textPrimary = const Color(0xFF202124);
    final Color _textSecondary = const Color(0xFF5F6368);
    final Color _successColor = const Color(0xFF34A853);
    final Color _warningColor = const Color(0xFFFBBC04);
    final Color _errorColor = const Color(0xFFEA4335);

    @override
    void initState() {
        super.initState();
        _animationController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1000),
        );

        // REVISI 8: Micro-animation berurutan (Staggered) agar seksi muncul bergantian secara halus
        _fadeFinansial = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
        _fadeGrafik = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic)));
        _fadeInsight = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));
        _fadeRingkasan = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic)));
        _fadeMetrik = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)));

        const Offset slideStart = Offset(0.0, 0.03);
        _slideFinansial = Tween<Offset>(begin: slideStart, end: Offset.zero).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
        _slideGrafik = Tween<Offset>(begin: slideStart, end: Offset.zero).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic)));
        _slideInsight = Tween<Offset>(begin: slideStart, end: Offset.zero).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));
        _slideRingkasan = Tween<Offset>(begin: slideStart, end: Offset.zero).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic)));
        _slideMetrik = Tween<Offset>(begin: slideStart, end: Offset.zero).animate(CurvedAnimation(
            parent: _animationController, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)));

        _animationController.forward();
    }

    @override
    void dispose() {
        _animationController.dispose();
        super.dispose();
    }

    Future<void> _refreshLaporan() async {
        _animationController.reset();
        _animationController.forward();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: _bgColor,
            body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: _refreshLaporan,
                    color: _primaryColor,
                    backgroundColor: Colors.white,
                    child: CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                            _buildSliverAppBar(),
                            SliverToBoxAdapter(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const SizedBox(height: 16),
                                            
                                            // REVISI 1: Tata Urutan Seksi Baru Mengikuti Pola Pikir Pemilik Kos (Finansial -> Grafik -> Insight -> Ringkasan -> Metrik)
                                            FadeTransition(
                                                opacity: _fadeFinansial,
                                                child: SlideTransition(
                                                    position: _slideFinansial,
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            _buildSectionTitle('Finansial'),
                                                            const SizedBox(height: 12),
                                                            _buildUtamaFinancialGrid(),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(height: 24),
                                            
                                            FadeTransition(
                                                opacity: _fadeGrafik,
                                                child: SlideTransition(
                                                    position: _slideGrafik,
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            _buildSectionTitle('Grafik Tren'),
                                                            const SizedBox(height: 12),
                                                            _buildChartTrenKeuangan(),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(height: 24),
                                            
                                            FadeTransition(
                                                opacity: _fadeInsight,
                                                child: SlideTransition(
                                                    position: _slideInsight,
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            _buildSectionTitle('Insight'),
                                                            const SizedBox(height: 12),
                                                            _buildInsightOtomatisCard(),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(height: 24),
                                            
                                            FadeTransition(
                                                opacity: _fadeRingkasan,
                                                child: SlideTransition(
                                                    position: _slideRingkasan,
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            _buildSectionTitle('Ringkasan Hunian'),
                                                            const SizedBox(height: 12),
                                                            _buildRingkasanPeriodeCard(),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(height: 24),
                                            
                                            FadeTransition(
                                                opacity: _fadeMetrik,
                                                child: SlideTransition(
                                                    position: _slideMetrik,
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            _buildSectionTitle('Metrik Bisnis'),
                                                            const SizedBox(height: 12),
                                                            _buildStatistikOperasionalGrid(),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(height: 40),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
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
                'Laporan',
                style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
            ),
            actions: [
                Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: _selectedPeriod,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _textSecondary),
                            style: TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            onChanged: (String? newValue) {
                                if (newValue != null) {
                                    setState(() {
                                        _selectedPeriod = newValue;
                                        _refreshLaporan();
                                    });
                                }
                            },
                            items: <String>['Juni 2026', 'Mei 2026', 'April 2026']
                                .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                );
                            }).toList(),
                        ),
                    ),
                ),
                const SizedBox(width: 4),
                IconButton(
                    icon: Icon(Icons.refresh_rounded, color: _textSecondary, size: 22),
                    onPressed: _refreshLaporan,
                ),
                const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: _borderColor, height: 1),
            ),
        );
    }

    // REVISI 2: Judul Seksi Bersih (Bukan Kapital Semua, Ukuran Sesuai, Profesional)
    Widget _buildSectionTitle(String title) {
        return Text(
            title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _textSecondary,
                letterSpacing: 0.2,
            ),
        );
    }

    // REVISI 3: Kartu Laba Bersih Dibuat Seimbang & Satu Kelompok Finansial yang Rapi
    Widget _buildUtamaFinancialGrid() {
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
            ),
            child: Column(
                children: [
                    Row(
                        children: [
                            Expanded(
                                child: _buildFinancialRowItem(
                                    label: 'Pemasukan',
                                    value: 'Rp 14.500.000',
                                    color: _successColor,
                                ),
                            ),
                            Container(width: 1, height: 40, color: _borderColor),
                            Expanded(
                                child: _buildFinancialRowItem(
                                    label: 'Pengeluaran',
                                    value: 'Rp 3.200.000',
                                    color: _errorColor,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                ),
                            ),
                        ],
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE8EAED), height: 1),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                                'Laba Bersih',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary),
                            ),
                            Flexible(
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                        'Rp 11.300.000',
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _successColor, letterSpacing: -0.2),
                                    ),
                                ),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }

    Widget _buildFinancialRowItem({required String label, required String value, required Color color, CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                    Text(label, style: TextStyle(fontSize: 12, color: _textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            value,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildRingkasanPeriodeCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
            ),
            child: Row(
                children: [
                    _buildRingkasanItem('Kamar Terisi', '28 Kamar', Icons.meeting_room_rounded),
                    _buildRingkasanItem('Kamar Kosong', '2 Kamar', Icons.no_meeting_room_rounded),
                    _buildRingkasanItem('Rasio Hunian', '93%', Icons.pie_chart_outline_rounded),
                ],
            ),
        );
    }

    Widget _buildRingkasanItem(String label, String value, IconData icon) {
        return Expanded(
            child: Column(
                children: [
                    Icon(icon, size: 16, color: _textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 6),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textPrimary)),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(label, style: TextStyle(fontSize: 11, color: _textSecondary)),
                    ),
                ],
            ),
        );
    }

    // REVISI 4: Upgrade Grafik Minimalis Dengan Indikator Skala Nominal Kiri & Garis Grid Samar
    Widget _buildChartTrenKeuangan() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('Pemasukan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _textSecondary)),
                            const SizedBox(width: 12),
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: _errorColor, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('Pengeluaran', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _textSecondary)),
                        ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                        children: [
                            // Kolom Skala Nominal Y-Axis Kiri
                            SizedBox(
                                height: 100,
                                width: 32,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text('15 Jt', style: TextStyle(fontSize: 9, color: _textSecondary.withOpacity(0.7), fontWeight: FontWeight.bold)),
                                        Text('10 Jt', style: TextStyle(fontSize: 9, color: _textSecondary.withOpacity(0.7), fontWeight: FontWeight.bold)),
                                        Text('5 Jt', style: TextStyle(fontSize: 9, color: _textSecondary.withOpacity(0.7), fontWeight: FontWeight.bold)),
                                        Text('0', style: TextStyle(fontSize: 9, color: _textSecondary.withOpacity(0.7), fontWeight: FontWeight.bold)),
                                    ],
                                ),
                            ),
                            // Area Grafik Garis Utama
                            Expanded(
                                child: SizedBox(
                                    height: 100,
                                    child: CustomPaint(
                                        painter: _LineChartPainter(blueLine: _primaryColor, redLine: _errorColor, gridColor: _borderColor.withOpacity(0.4)),
                                    ),
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'].map((month) {
                                return Text(month, style: TextStyle(fontSize: 10, color: _textSecondary, fontWeight: FontWeight.bold));
                            }).toList(),
                        ),
                    ),
                ],
            ),
        );
    }

    // REVISI 5: Perbaikan Jarak Konsisten & Format Teks Ringkas Ikon di Sisi Kiri
    Widget _buildInsightOtomatisCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    _buildInsightRow('📈', 'Pemasukan naik 12% dibanding bulan lalu'),
                    const SizedBox(height: 12),
                    _buildInsightRow('⚡', 'Pengeluaran listrik meningkat Rp 250.000'),
                    const SizedBox(height: 12),
                    _buildInsightRow('🏠', 'Tingkat hunian stabil aman di atas 90%'),
                ],
            ),
        );
    }

    Widget _buildInsightRow(String emoji, String text) {
        return Row(
            children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: _textPrimary, fontWeight: FontWeight.w500, letterSpacing: -0.1),
                    ),
                ),
            ],
        );
    }

    // REVISI 6 & 7: Metrik Bisnis Ditata Simetris Tanpa Kotak Kosong (Baris Akhir Full-Width & Penamaan Jelas)
    Widget _buildStatistikOperasionalGrid() {
        return Column(
            children: [
                Row(
                    children: [
                        Expanded(child: _buildBusinessTile('Kamar Terisi', '28 Kamar', _textPrimary)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBusinessTile('Kamar Kosong', '2 Unit', _textSecondary)),
                    ],
                ),
                const SizedBox(height: 12),
                Row(
                    children: [
                        Expanded(child: _buildBusinessTile('Rerata Pendapatan', 'Rp 520.000 /Kmr', _primaryColor)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBusinessTile('Biaya Terbesar', 'Listrik PLN', _errorColor)),
                    ],
                ),
                const SizedBox(height: 12),
                // Baris Terakhir Dibuat Full-Width Simetris Sesuai Target Produksi Premium
                _buildBusinessTile('Pembayaran Tepat Waktu', '95% Penyewa Membayar Tepat Waktu', _successColor, isFullWidth: true),
            ],
        );
    }

    Widget _buildBusinessTile(String title, String count, Color countColor, {bool isFullWidth = false}) {
        return Container(
            width: isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderColor),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        title,
                        style: TextStyle(fontSize: 11, color: _textSecondary, fontWeight: FontWeight.w500, letterSpacing: 0.1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            count,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countColor, letterSpacing: -0.1),
                        ),
                    ),
                ],
            ),
        );
    }
}

// Custom Painter Dua Garis Tren Finansial Beserta Garis Bantu Grid Samar Khas Aplikasi Kos Premium
class _LineChartPainter extends CustomPainter {
    final Color blueLine;
    final Color redLine;
    final Color gridColor;
    _LineChartPainter({required this.blueLine, required this.redLine, required this.gridColor});

    @override
    void paint(Canvas canvas, Size size) {
        final paintGrid = Paint()
            ..color = gridColor
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

        // Menggambar 4 Baris Garis Bantu Grid Horisontal Samar
        canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paintGrid);
        canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), paintGrid);
        canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width, size.height * 0.66), paintGrid);
        canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paintGrid);

        final paintBlue = Paint()
            ..color = blueLine
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

        final paintRed = Paint()
            ..color = redLine
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

        // Koordinat Titik Pemasukan Kos
        final List<Offset> bluePoints = [
            Offset(0, size.height * 0.65),
            Offset(size.width * 0.2, size.height * 0.58),
            Offset(size.width * 0.4, size.height * 0.45),
            Offset(size.width * 0.6, size.height * 0.40),
            Offset(size.width * 0.8, size.height * 0.25),
            Offset(size.width, size.height * 0.15),
        ];

        // Koordinat Titik Pengeluaran Kos
        final List<Offset> redPoints = [
            Offset(0, size.height * 0.85),
            Offset(size.width * 0.2, size.height * 0.80),
            Offset(size.width * 0.4, size.height * 0.88),
            Offset(size.width * 0.6, size.height * 0.75),
            Offset(size.width * 0.8, size.height * 0.78),
            Offset(size.width, size.height * 0.70),
        ];

        // Jalur Pemasukan
        final pathBlue = Path()..moveTo(bluePoints[0].dx, bluePoints[0].dy);
        for (int i = 1; i < bluePoints.length; i++) {
            final prev = bluePoints[i - 1];
            final current = bluePoints[i];
            pathBlue.cubicTo((prev.dx + current.dx) / 2, prev.dy, (prev.dx + current.dx) / 2, current.dy, current.dx, current.dy);
        }
        canvas.drawPath(pathBlue, paintBlue);

        // Jalur Pengeluaran
        final pathRed = Path()..moveTo(redPoints[0].dx, redPoints[0].dy);
        for (int i = 1; i < redPoints.length; i++) {
            final prev = redPoints[i - 1];
            final current = redPoints[i];
            pathRed.cubicTo((prev.dx + current.dx) / 2, prev.dy, (prev.dx + current.dx) / 2, current.dy, current.dx, current.dy);
        }
        canvas.drawPath(pathRed, paintRed);
    }

    @override
    bool shouldRepaint(covariant _LineChartPainter oldDelegate) => false;
}
