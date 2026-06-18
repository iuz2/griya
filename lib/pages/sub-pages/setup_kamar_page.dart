import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SetupKamarPage extends StatefulWidget {
    const SetupKamarPage({Key? key}) : super(key: key);

    @override
    State<SetupKamarPage> createState() => _SetupKamarPageState();
}

class _SetupKamarPageState extends State<SetupKamarPage> with SingleTickerProviderStateMixin {
    late TabController _tabController;
    bool _isLoading = false;

    // Kunci Konstanta Warna V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);
    final Color _errorColor = const Color(0xFFEF4444);

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

    // State Fasilitas Satuan
    final Map<String, bool> _fasilitasMap = {
        'AC': false,
        'Kamar Mandi Dalam': false,
        'Kasur': false,
        'WiFi': false,
        'Water Heater': false,
        'Lemari': false,
        'Meja & Kursi': false,
    };

    List<String> _generatedMassalList = [];

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 2, vsync: this);
        
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

    // ==========================================
    // LOGIKA PROSES SIMPAN KE FIREBASE
    // ==========================================
    void _handleSubmitData() async {
        final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        if (currentUid.isEmpty) {
            _showSnackBar("Sesi masuk habis. Silakan login kembali!", _errorColor);
            return;
        }

        setState(() => _isLoading = true);
        final DatabaseReference rootRoomsRef = FirebaseDatabase.instance.ref().child('users_data/$currentUid/rooms');

        try {
            if (_tabController.index == 0) {
                // EKSEKUSI JALUR INPUT SATUAN
                final String namaKamar = _namaKamarController.text.trim();
                final String hargaClean = _hargaController.text.replaceAll('.', '');
                final int? hargaSewa = int.tryParse(hargaClean);
                final String tipeKamar = _tipeKamarController.text.trim().isEmpty ? 'Standard' : _tipeKamarController.text.trim();

                if (namaKamar.isEmpty || hargaSewa == null || hargaSewa <= 0) {
                    _showSnackBar("Nama kamar dan harga wajib diisi secara valid!", _errorColor);
                    setState(() => _isLoading = false);
                    return;
                }

                // Ambil ID acak push dari nodepath Firebase murni
                final DatabaseReference newRoomPushRef = rootRoomsRef.push();
                final String? generatedRoomId = newRoomPushRef.key;

                final Map<String, dynamic> singleRoomPayload = {
                    'room_id': generatedRoomId,
                    'room_name': namaKamar,
                    'room_type': tipeKamar,
                    'price': hargaSewa,
                    'availability_status': 'empty', // Kunci dasar status kosong murni huni
                    'has_pending': false,
                    'pending_amount': 0,
                };

                await newRoomPushRef.set(singleRoomPayload);
                _showSnackBar("🚪 Kamar $namaKamar berhasil ditambahkan!", _tealPrimary);

            } else {
                // EKSEKUSI JALUR INPUT MASSAL (MULTI-UPDATE TRANSAKSIONAL)
                final String hargaDefaultClean = _hargaDefaultController.text.replaceAll('.', '');
                final int? hargaDefault = int.tryParse(hargaDefaultClean);
                final String tipeDefault = _tipeDefaultController.text.trim().isEmpty ? 'Standard' : _tipeDefaultController.text.trim();

                if (_generatedMassalList.isEmpty || hargaDefault == null || hargaDefault <= 0) {
                    _showSnackBar("Skema penomoran dan harga default wajib dilengkapi!", _errorColor);
                    setState(() => _isLoading = false);
                    return;
                }

                final Map<String, dynamic> massalUpdatePayload = {};

                for (String namaKamarMassal in _generatedMassalList) {
                    final DatabaseReference tempPush = rootRoomsRef.push();
                    final String? massalId = tempPush.key;

                    massalUpdatePayload['$massalId'] = {
                        'room_id': massalId,
                        'room_name': namaKamarMassal,
                        'room_type': tipeDefault,
                        'price': hargaDefault,
                        'availability_status': 'empty',
                        'has_pending': false,
                        'pending_amount': 0,
                    };
                }

                // Kirim paket map besar sekaligus dalam satu kali ketukan koneksi jaringan
                await rootRoomsRef.update(massalUpdatePayload);
                _showSnackBar("⚡ Berhasil membuat ${_generatedMassalList.length} unit kamar sekaligus!", _tealPrimary);
            }

            if (mounted) Navigator.pop(context);

        } catch (e) {
            _showSnackBar(e.toString(), _errorColor);
        } finally {
            if (mounted) setState(() => _isLoading = false);
        }
    }

    void _showSnackBar(String message, Color bgColor) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                backgroundColor: bgColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1), 
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textSlatePrimary, size: 18),
                    onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                    'Setup Unit Properti',
                    style: TextStyle(color: _textSlatePrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                        ),
                        child: TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _borderSlateLight, width: 1.2),
                            ),
                            labelColor: _tealPrimary,
                            unselectedLabelColor: _textSlateMuted,
                            labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
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

    Widget _buildInputSatuanContent() {
        return ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
                _buildCardWrapper(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Identitas Kamar Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                            const SizedBox(height: 18),
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
                                prefix: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('Rp', style: TextStyle(color: _textSlatePrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                                inputFormatters: [_CurrencyFormat()],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _tipeKamarController,
                                label: 'Tipe / Kelas Kamar',
                                hint: 'Contoh: Standar, Eksekutif, VIP',
                                isMandatory: false,
                            ),
                        ],
                    ),
                ),
                const SizedBox(height: 16),
                _buildCardWrapper(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Fasilitas Internal Unit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                            const SizedBox(height: 16),
                            Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: _fasilitasMap.keys.map((String key) {
                                    final bool isSelected = _fasilitasMap[key]!;
                                    return FilterChip(
                                        label: Text(key),
                                        selected: isSelected,
                                        onSelected: (bool value) {
                                            setState(() {
                                                _fasilitasMap[key] = value;
                                            });
                                        },
                                        selectedColor: const Color(0xFFCCFBF1),
                                        checkmarkColor: _tealPrimary,
                                        labelStyle: TextStyle(
                                            color: isSelected ? _tealPrimary : _textSlatePrimary,
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                                        ),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                                color: isSelected ? _tealPrimary : _borderSlateLight,
                                                width: 1.2,
                                            ),
                                        ),
                                        showCheckmark: true,
                                    );
                                }).toList(),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                                controller: _fasilitasTambahanController,
                                label: 'Fasilitas Tambahan Kustom',
                                hint: 'Pisahkan dengan koma (contoh: TV, Balkon)',
                                isMandatory: false,
                            ),
                        ],
                    ),
                ),
            ],
        );
    }

    Widget _buildInputMassalContent() {
        return ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
                _buildMassalPreviewPanel(),
                const SizedBox(height: 16),
                _buildCardWrapper(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Skema Struktur Penomoran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                            const SizedBox(height: 18),
                            _buildTextField(
                                controller: _prefixController,
                                label: 'Prefix / Awalan Nama',
                                hint: 'Contoh: Kamar K, Blok A',
                                isMandatory: true,
                            ),
                            const SizedBox(height: 16),
                            Row(
                                children: [
                                    Expanded(
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
                        ],
                    ),
                ),
                const SizedBox(height: 16),
                _buildCardWrapper(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Konfigurasi Nilai Default', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                            const SizedBox(height: 18),
                            _buildTextField(
                                controller: _hargaDefaultController,
                                label: 'Harga Sewa Default',
                                hint: '0',
                                keyboardType: TextInputType.number,
                                isMandatory: true,
                                prefix: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('Rp', style: TextStyle(color: _textSlatePrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                                inputFormatters: [_CurrencyFormat()],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _tipeDefaultController,
                                label: 'Tipe Kamar Default',
                                hint: 'Contoh: Standar Reguler',
                                isMandatory: false,
                            ),
                        ],
                    ),
                ),
            ],
        );
    }

    Widget _buildTextField({
        required TextEditingController controller,
        required String label,
        required String hint,
        bool isMandatory = false,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        Widget? prefix,
    }) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text(label, style: TextStyle(color: _textSlateMuted, fontSize: 14, fontWeight: FontWeight.w400)),
                        if (isMandatory) Text(' *', style: TextStyle(color: _errorColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                ),
                const SizedBox(height: 6),
                TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    style: TextStyle(color: _textSlatePrimary, fontSize: 16, fontWeight: FontWeight.w400),
                    cursorColor: _tealPrimary,
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 15),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: Colors.white,
                        filled: true,
                        prefix: prefix,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight, width: 1.2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
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
                    'PRATINJAU GENERATE UNIT MASSAL',
                    style: TextStyle(color: _textSlateMuted, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                _buildCardWrapper(
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _generatedMassalList.isEmpty
                                ? Text(
                                        'Masukkan skema struktur penomoran untuk melihat preview daftar unit.',
                                        style: TextStyle(color: _textSlateMuted, fontSize: 14, fontWeight: FontWeight.w300),
                                    )
                                : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _generatedMassalList.map((kamar) {
                                            return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: _borderSlateLight),
                                                ),
                                                child: Text(
                                                    kamar,
                                                    style: TextStyle(color: _textSlatePrimary, fontSize: 14, fontWeight: FontWeight.w500),
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
                        ? (_generatedMassalList.isNotEmpty ? 'Generate ${_generatedMassalList.length} Unit Kamar' : 'Buat Unit Massal')
                        : 'Simpan Data Kamar';

                return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: _borderSlateLight, width: 1)),
                    ),
                    child: Row(
                        children: [
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: _borderSlateLight),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        backgroundColor: Colors.white,
                                    ),
                                    child: Text(
                                        'Batal',
                                        style: TextStyle(color: _textSlatePrimary, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleSubmitData,
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: _tealPrimary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : Text(
                                                submitText,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
