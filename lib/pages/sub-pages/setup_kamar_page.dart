import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetupKamarPage extends StatefulWidget {
    const SetupKamarPage({Key? key}) : super(key: key);

    @override
    State<SetupKamarPage> createState() => _SetupKamarPageState();
}

class _SetupKamarPageState extends State<SetupKamarPage> with SingleTickerProviderStateMixin {
    late TabController _tabController;

    // Background & Palette Styles
    final Color _bgColor = const Color(0xffffffff);
    final Color _bgSecondary = const Color(0xfff8fafc);
    final Color _borderColor = const Color(0xffe5e7eb);
    final Color _textPrimary = const Color(0xff202124);
    final Color _textSecondary = const Color(0xff6b7280);
    final Color _accentColor = const Color(0xff059669);

    // Controller Input Satuan
    final TextEditingController _namaKamarController = TextEditingController();
    final TextEditingController _hargaController = TextEditingController();
    final TextEditingController _tipeKamarController = TextEditingController();
    final TextEditingController _fasilitasTambahanController = TextEditingController();

    // Controller Input Massal
    final TextEditingController _prefixController = TextEditingController();
    final TextEditingController _nomorAwalController = TextEditingController();
    final TextEditingController _nomorAkhirController = TextEditingController();
    final TextEditingController _hargaDefaultController = TextEditingController();
    final TextEditingController _tipeDefaultController = TextEditingController();

    // State Fasilitas Satuan (Sistem Lama)
    final Map<String, bool> _fasilitasMap = {
        'AC': false,
        'Kamar Mandi Dalam': false,
        'Kasur': false,
        'WiFi': false,
        'Water Heater': false,
        'Lemari': false,
        'Meja & Kursi': false,
    };

    // State Preview Massal
    List<String> _generatedMassalList = [];

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 2, vsync: this);
        
        // Listener Realtime Preview Massal
        _prefixController.addListener(_generateMassalPreview);
        _nomorAwalController.addListener(_generateMassalPreview);
        _nomorAkhirController.addListener(_generateMassalPreview);
    }

    @override
    void dispose() {
        _tabController.dispose();
        _namaKamarController.dispose();
        _hargaController.dispose();
        _tipeKamarController.dispose();
        _fasilitasTambahanController.dispose();
        _prefixController.dispose();
        _nomorAwalController.dispose();
        _nomorAkhirController.dispose();
        _hargaDefaultController.dispose();
        _tipeDefaultController.dispose();
        super.dispose();
    }

    void _generateMassalPreview() {
        final String prefix = _prefixController.text;
        final int? awal = int.tryParse(_nomorAwalController.text);
        final int? akhir = int.tryParse(_nomorAkhirController.text);

        if (awal != null && akhir != null && awal <= akhir) {
            List<String> temp = [];
            for (int i = awal; i <= akhir; i++) {
                temp.add('$prefix$i');
            }
            setState(() {
                _generatedMassalList = temp;
            });
        } else {
            setState(() {
                _generatedMassalList = [];
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
                backgroundColor: _bgColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                    'Setup Kamar',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                    ),
                ),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(40), // Dikurangi sedikit agar lebih proporsional
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                            color: _bgSecondary,
                            borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                                color: _bgColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _borderColor),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                    ),
                                ],
                            ),
                            labelColor: _textPrimary,
                            unselectedLabelColor: _textSecondary,
                            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            tabs: const [
                                Tab(text: 'Input Satuan'),
                                Tab(text: 'Input Massal'),
                            ],
                        ),
                    ),
                ),
            ),
            body: SafeArea(
                child: Column(
                    children: [
                        Expanded(
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                    _buildInputSatuanContent(),
                                    _buildInputMassalContent(),
                                ],
                            ),
                        ),
                        _buildStickyFooter(),
                    ],
                ),
            ),
        );
    }

    // ==========================================
    // LAYOUT INPUT SATUAN
    // ==========================================
    Widget _buildInputSatuanContent() {
        // Logika internal untuk mengumpulkan fasilitas jika dibutuhkan saat submit
        List<String> fasilitasAktif = [];
        _fasilitasMap.forEach((key, value) {
            if (value) fasilitasAktif.add(key);
        });
        if (_fasilitasTambahanController.text.isNotEmpty) {
            final splitFasilitas = _fasilitasTambahanController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
            fasilitasAktif.addAll(splitFasilitas);
        }

        return ListView(
            padding: const EdgeInsets.all(24),
            physics: const ClampingScrollPhysics(),
            children: [
                _buildSectionTitle('Identitas Kamar'),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _namaKamarController,
                    label: 'Nama / Nomor Kamar',
                    hint: 'Contoh: A1 atau 101',
                    isMandatory: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _hargaController,
                    label: 'Harga Sewa Bulanan',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    isMandatory: true,
                    prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                            'Rp',
                            style: TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                    ),
                    inputFormatters: [_CurrencyFormat()],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _tipeKamarController,
                    label: 'Tipe Kamar',
                    hint: 'Ketik tipe kamar, contoh: Standar, Eksekutif',
                    isMandatory: false,
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Fasilitas'),
                const SizedBox(height: 16),
                Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _fasilitasMap.keys.map((String key) {
                        final bool isSelected = _fasilitasMap[key]!;
                        return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: FilterChip(
                                label: Text(key),
                                selected: isSelected,
                                onSelected: (bool value) {
                                    setState(() {
                                        _fasilitasMap[key] = value;
                                    });
                                },
                                selectedColor: _accentColor.withOpacity(0.08),
                                checkmarkColor: _accentColor,
                                labelStyle: TextStyle(
                                    color: isSelected ? _accentColor : _textPrimary,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                                backgroundColor: _bgColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: isSelected ? _accentColor : _borderColor,
                                        width: isSelected ? 1.5 : 1,
                                    ),
                                ),
                                showCheckmark: true,
                            ),
                        );
                    }).toList(),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                    controller: _fasilitasTambahanController,
                    label: 'Fasilitas Tambahan',
                    hint: 'Pisahkan dengan koma jika lebih dari satu',
                    isMandatory: false,
                ),
            ],
        );
    }

    // ==========================================
    // LAYOUT INPUT MASSAL
    // ==========================================
    Widget _buildInputMassalContent() {
        return ListView(
            padding: const EdgeInsets.all(24),
            physics: const ClampingScrollPhysics(),
            children: [
                _buildMassalPreviewPanel(),
                const SizedBox(height: 32),
                _buildSectionTitle('Skema Penomoran'),
                const SizedBox(height: 16),
                Row(
                    children: [
                        Expanded(
                            flex: 2,
                            child: _buildTextField(
                                controller: _prefixController,
                                label: 'Prefix Nama',
                                hint: 'Contoh: A',
                                isMandatory: true,
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 2,
                            child: _buildTextField(
                                controller: _nomorAwalController,
                                label: 'No. Awal',
                                hint: '1',
                                keyboardType: TextInputType.number,
                                isMandatory: true,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 2,
                            child: _buildTextField(
                                controller: _nomorAkhirController,
                                label: 'No. Akhir',
                                hint: '10',
                                keyboardType: TextInputType.number,
                                isMandatory: true,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Konfigurasi Default'),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _hargaDefaultController,
                    label: 'Harga Default',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    isMandatory: true,
                    prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                            'Rp',
                            style: TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                    ),
                    inputFormatters: [_CurrencyFormat()],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _tipeDefaultController,
                    label: 'Tipe Default',
                    hint: 'Masukkan nilai default tipe kamar',
                    isMandatory: false,
                ),
            ],
        );
    }

    // ==========================================
    // UTILS & REUSABLE WIDGETS
    // ==========================================
    Widget _buildSectionTitle(String title) {
        return Text(
            title,
            style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
            ),
        );
    }

    Widget _buildTextField({
        required TextEditingController controller,
        required String label,
        required String hint,
        bool isMandatory = false,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        Widget? prefixIcon,
    }) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text(
                            label,
                            style: TextStyle(
                                color: _textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                        if (isMandatory)
                            Text(
                                ' *',
                                style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                    ],
                ),
                const SizedBox(height: 6),
                TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    style: TextStyle(color: _textPrimary, fontSize: 15),
                    cursorColor: _accentColor,
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: _bgColor,
                        filled: true,
                        prefixIcon: prefixIcon,
                        prefixIconConstraints: prefixIcon != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _borderColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _accentColor, width: 1.5),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildMassalPreviewPanel() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    'PREVIEW GENERATE KAMAR',
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                    ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: _bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor, width: 1),
                    ),
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _generatedMassalList.isEmpty
                                ? Text(
                                        'Masukkan skema penomoran untuk melihat preview.',
                                        style: TextStyle(
                                            color: _textSecondary, 
                                            fontSize: 13, 
                                            fontStyle: FontStyle.italic,
                                        ),
                                    )
                                : Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: _generatedMassalList.map((kamar) {
                                            return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: _bgColor,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: _borderColor),
                                                ),
                                                child: Text(
                                                    kamar,
                                                    style: TextStyle(
                                                        color: _textPrimary,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                    ),
                                                ),
                                            );
                                        }).toList(),
                                    ),
                    ),
                ),
            ],
        );
    }

    Widget _buildStickyFooter() {
        return ListenableBuilder(
            listenable: _tabController,
            builder: (context, child) {
                final bool isMassal = _tabController.index == 1;
                final String submitText = isMassal 
                        ? (_generatedMassalList.isNotEmpty ? 'Buat ${_generatedMassalList.length} Kamar' : 'Buat Kamar')
                        : 'Simpan Kamar';

                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                        color: _bgColor,
                        border: Border(top: BorderSide(color: _borderColor, width: 1)),
                    ),
                    child: Row(
                        children: [
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(color: _borderColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        backgroundColor: _bgColor,
                                        elevation: 0,
                                    ),
                                    child: Text(
                                        'Batal',
                                        style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                        // Handle proses simpan internal sistem lama
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        backgroundColor: _accentColor,
                                        foregroundColor: _bgColor,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text(
                                        submitText,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                ),
                            ),
                        ],
                    ),
                );
            },
        );
    }
}

// Formatter khusus untuk format Rupiah otomatis saat user mengetik
class _CurrencyFormat extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
        if (newValue.text.isEmpty) {
            return newValue.copyWith(text: '');
        }

        String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanText.isEmpty) {
            return const TextEditingValue(text: '');
        }

        String formatted = cleanText.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.'
        );

        int selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
        int newCursorPosition = formatted.length - selectionIndexFromTheRight;
        if (newCursorPosition < 0) newCursorPosition = 0;

        return TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: newCursorPosition),
        );
    }
}
