import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget {
    const LaporanPage({Key? key}) : super(key: key);

    @override
    State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
    String _selectedPeriod = 'Juni 2026';

    // Kunci Konstanta Warna V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);

    // Mock Data Laporan Ringkas
    final String _pemasukan = 'Rp 14.500.000';
    final String _pengeluaran = 'Rp 3.200.000';
    final String _labaBersih = 'Rp 11.300.000';

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1), 
            body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    color: _tealPrimary,
                    child: CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                            SliverAppBar(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                scrolledUnderElevation: 0,
                                pinned: false,
                                leading: IconButton(
                                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textSlatePrimary, size: 18),
                                    onPressed: () => Navigator.pop(context),
                                ),
                                title: Text(
                                    'Analisis Laporan Kos',
                                    style: TextStyle(color: _textSlatePrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                centerTitle: true,
                            ),

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

                            SliverPadding(
                                padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 80.0),
                                sliver: SliverList(
                                    delegate: SliverChildListDelegate([
                                        _buildCardWrapper(child: _buildFinancialSummaryContent()),
                                        const SizedBox(height: 16),
                                        _buildCardWrapper(child: _buildChartTrenContent()),
                                        const SizedBox(height: 16),
                                        _buildCardWrapper(child: _buildInsightOtomatisContent()),
                                        const SizedBox(height: 16),
                                        _buildCardWrapper(child: _buildExportDocumentMenuHub()),
                                    ]),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildCardWrapper({required Widget child}) {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: child,
        );
    }

    Widget _buildPeriodFilterRow() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(
                    "Buku Laporan",
                    style: TextStyle(fontSize: 16, color: _textSlateMuted, fontWeight: FontWeight.w400),
                ),
                Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderSlateLight, width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: _selectedPeriod,
                            icon: Icon(Icons.arrow_drop_down_rounded, color: _tealPrimary, size: 24),
                            style: TextStyle(color: _tealPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                            onChanged: (String? val) {
                                if (val != null) setState(() => _selectedPeriod = val);
                            },
                            items: <String>['Juni 2026', 'Mei 2026', 'April 2026'].map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildFinancialSummaryContent() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text('Ikhtisar Pembukuan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                const SizedBox(height: 18),
                _buildDataRowItem("Pemasukan Sewa", _pemasukan, _tealPrimary),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildDataRowItem("Pengeluaran Nota", _pengeluaran, _textSlatePrimary),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildDataRowItem("Laba Bersih Riil", _labaBersih, _tealPrimary),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                            "Rasio Hunian Kamar Aktif", 
                            style: TextStyle(fontSize: 15, color: _textSlateMuted, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Text(
                            "28 Unit Terisi  •  2 Unit Kosong (93%)", 
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _textSlateMuted),
                        ),
                    ],
                ),
            ],
        );
    }

    Widget _buildDataRowItem(String title, String value, Color valueColor) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(title, style: TextStyle(fontSize: 15, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: valueColor)),
            ],
        );
    }

    Widget _buildChartTrenContent() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text('Tren Kas 6 Bulan Terakhir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                const SizedBox(height: 18),
                Row(
                    children: [
                        SizedBox(
                            height: 100,
                            width: 36,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text('15 Jt', style: TextStyle(fontSize: 11, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                                    Text('10 Jt', style: TextStyle(fontSize: 11, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                                    Text('5 Jt', style: TextStyle(fontSize: 11, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                                    Text('0', style: TextStyle(fontSize: 11, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                                ],
                            ),
                        ),
                        Expanded(
                            child: SizedBox(
                                height: 100,
                                child: CustomPaint(
                                    painter: _LineChartPainter(blueLine: _tealPrimary, redLine: _textSlatePrimary, gridColor: const Color(0xFFF1F5F9)),
                                ),
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 12),
                Padding(
                    padding: const EdgeInsets.only(left: 36.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'].map((month) {
                            return Text(month, style: TextStyle(fontSize: 12, color: _textSlateMuted, fontWeight: FontWeight.w400));
                        }).toList(),
                    ),
                ),
                
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 36.0),
                    child: Row(
                        children: [
                            _buildLegendItem("Pemasukan", _tealPrimary),
                            const SizedBox(width: 24),
                            _buildLegendItem("Pengeluaran", _textSlatePrimary),
                        ],
                    ),
                ),
            ],
        );
    }

    Widget _buildLegendItem(String label, Color color) {
        return Row(
            children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                    label, 
                    style: TextStyle(fontSize: 13, color: _textSlateMuted, fontWeight: FontWeight.w400),
                ),
            ],
        );
    }

    Widget _buildInsightOtomatisContent() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text('Analisis Keuangan Otomatis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                const SizedBox(height: 16),
                _buildInsightRowItem("•", "Pemasukan unit sewa bergerak stabil naik sebesar 12%"),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInsightRowItem("•", "Biaya pengeluaran operasional listrik terdeteksi wajar"),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInsightRowItem("•", "Okupansi hunian konsisten aman di kisaran angka 93%"),
            ],
        );
    }

    Widget _buildInsightRowItem(String bullet, String text) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(bullet, style: TextStyle(color: _tealPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        text,
                        style: TextStyle(fontSize: 14, color: _textSlatePrimary, fontWeight: FontWeight.w300, height: 1.4),
                    ),
                ),
            ],
        );
    }

    Widget _buildExportDocumentMenuHub() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text('Dokumen Keluar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                const SizedBox(height: 12),
                ListTile(
                    onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('📊 Berkas Laporan_Kas.xlsx berhasil diunduh.'), backgroundColor: _tealPrimary),
                        );
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.description_outlined, color: _tealPrimary, size: 20),
                    title: Text('Ekspor Laporan ke Excel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                    subtitle: Text('Unduh berkas spreadsheet pembukuan kos lengkap', style: TextStyle(fontSize: 13, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
                ),
            ],
        );
    }
}

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

        final List<Offset> bluePoints = [
            Offset(0, size.height * 0.65),
            Offset(size.width * 0.2, size.height * 0.58),
            Offset(size.width * 0.4, size.height * 0.45),
            Offset(size.width * 0.6, size.height * 0.40),
            Offset(size.width * 0.8, size.height * 0.25),
            Offset(size.width, size.height * 0.15),
        ];

        final List<Offset> redPoints = [
            Offset(0, size.height * 0.85),
            Offset(size.width * 0.2, size.height * 0.80),
            Offset(size.width * 0.4, size.height * 0.88),
            Offset(size.width * 0.6, size.height * 0.75),
            Offset(size.width * 0.8, size.height * 0.78),
            Offset(size.width, size.height * 0.70),
        ];

        // REVISI MUTLAK: Pemisahan inisialisasi yang legal (bebas error void)
        final pathBlue = Path();
        pathBlue.moveTo(bluePoints[0].dx, bluePoints[0].dy);
        for (int i = 1; i < bluePoints.length; i++) {
            final prev = bluePoints[i - 1];
            final current = bluePoints[i];
            pathBlue.cubicTo((prev.dx + current.dx) / 2, prev.dy, (prev.dx + current.dx) / 2, current.dy, current.dx, current.dy);
        }
        canvas.drawPath(pathBlue, paintBlue);

        final pathRed = Path();
        pathRed.moveTo(redPoints[0].dx, redPoints[0].dy);
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
