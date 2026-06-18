import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PengeluaranMode { add, view, edit }

class DetailPengeluaranPage extends StatefulWidget {
    final PengeluaranMode mode;
    final Map<String, dynamic>? pengeluaran;

    const DetailPengeluaranPage({
        Key? key,
        required this.mode,
        this.pengeluaran,
    }) : super(key: key);

    @override
    State<DetailPengeluaranPage> createState() => _DetailPengeluaranPageState();
}

class _DetailPengeluaranPageState extends State<DetailPengeluaranPage> {
    final _formKey = GlobalKey<FormState>();
    late PengeluaranMode _currentMode;

    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);
    final Color _errorColor = const Color(0xFFEF4444);

    final TextEditingController _namaController = TextEditingController();
    final TextEditingController _nominalController = TextEditingController();
    final TextEditingController _tanggalController = TextEditingController();
    final TextEditingController _tokoController = TextEditingController();
    final TextEditingController _notaController = TextEditingController();
    final TextEditingController _catatanController = TextEditingController();
    final TextEditingController _kategoriBaruController = TextEditingController(); 

    String? _selectedKategori;
    bool _hasReceiptPhoto = false;
    bool _isKategoriLainnyaSelected = false; 

    final List<String> _daftarKategori = [
        'Perawatan Bangunan',
        'Utilitas',
        'Operasional',
        'Perlengkapan',
        'Lainnya'
    ];

    bool get _isReadOnly => _currentMode == PengeluaranMode.view;

    @override
    void initState() {
        super.initState();
        _currentMode = widget.mode;
        _populateData();
    }

    void _populateData() {
        if (widget.pengeluaran != null) {
            _namaController.text = widget.pengeluaran!['nama'] ?? '';
            _nominalController.text = widget.pengeluaran!['nominal'] ?? '';
            _tanggalController.text = widget.pengeluaran!['tanggal'] ?? '';
            _tokoController.text = widget.pengeluaran!['toko'] ?? '';
            _notaController.text = widget.pengeluaran!['nomor_nota'] ?? '';
            _catatanController.text = widget.pengeluaran!['catatan'] ?? '';

            final String? kat = widget.pengeluaran!['kategori'];
            if (_daftarKategori.contains(kat)) {
                _selectedKategori = kat;
                if (kat == 'Lainnya') {
                    _isKategoriLainnyaSelected = true;
                    _kategoriBaruController.text = widget.pengeluaran!['kategori_kustom'] ?? '';
                }
            } else if (kat != null && kat.isNotEmpty) {
                _selectedKategori = 'Lainnya';
                _isKategoriLainnyaSelected = true;
                _kategoriBaruController.text = kat;
            }
            _hasReceiptPhoto = widget.pengeluaran!['has_nota'] ?? false;
        }
    }

    @override
    void dispose() {
        _namaController.dispose();
        _nominalController.dispose();
        _tanggalController.dispose();
        _tokoController.dispose();
        _notaController.dispose();
        _catatanController.dispose();
        _kategoriBaruController.dispose();
        super.dispose();
    }

    Future<void> _selectTanggal() async {
        if (_isReadOnly) return;
        DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            locale: const Locale('id', 'ID'), 
            confirmText: 'PILIH',
            cancelText: 'BATAL',
            helpText: 'PILIH TANGGAL NOTA',
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: _tealPrimary,
                            onPrimary: Colors.white,
                            onSurface: _textSlatePrimary,
                        ),
                    ),
                    child: child!,
                );
            },
        );
        if (picked != null) {
            setState(() {
                _tanggalController.text = "${picked.day} ${_getNamaBulan(picked.month)} ${picked.year}";
            });
        }
    }

    String _getNamaBulan(int month) {
        const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        return bulan[month - 1];
    }

    void _simulatePhotoSelection() {
        if (_isReadOnly) return;
        setState(() {
            _hasReceiptPhoto = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text('Foto nota berhasil dilampirkan'),
                backgroundColor: _tealPrimary,
                duration: const Duration(seconds: 2),
            ),
        );
    }

    void _handlePrimaryButtonAction() {
        if (_isReadOnly) {
            setState(() {
                _currentMode = PengeluaranMode.edit;
            });
        } else {
            if (_formKey.currentState!.validate()) {
                final String kategoriFinal = _isKategoriLainnyaSelected ? _kategoriBaruController.text.trim() : _selectedKategori!;

                final String pesanSukses = _currentMode == PengeluaranMode.add
                        ? 'Data pengeluaran berhasil ditambahkan'
                        : 'Perubahan data pengeluaran disimpan';

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('$pesanSukses ($kategoriFinal)'),
                        backgroundColor: _tealPrimary,
                    ),
                );
                Navigator.pop(context);
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        String appBarTitle = 'Tambah Pengeluaran';
        if (_currentMode == PengeluaranMode.view) {
            appBarTitle = 'Detail Pengeluaran';
        } else if (_currentMode == PengeluaranMode.edit) {
            appBarTitle = 'Edit Pengeluaran';
        }

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
                    appBarTitle,
                    style: TextStyle(color: _textSlatePrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            ),
            body: SafeArea(
                child: Column(
                    children: [
                        Expanded(
                            child: Form(
                                key: _formKey,
                                child: ListView(
                                    padding: const EdgeInsets.all(24),
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                        _buildCardWrapper(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    const Text('Informasi Utama', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                    const SizedBox(height: 16),
                                                    _buildTextField(
                                                        controller: _namaController,
                                                        label: 'Nama Pengeluaran',
                                                        hint: 'Contoh: Perbaikan Atap Kamar 102',
                                                        isMandatory: true,
                                                        validator: (val) => val == null || val.trim().isEmpty ? 'Nama pengeluaran wajib diisi' : null,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildTextField(
                                                        controller: _nominalController,
                                                        label: 'Nominal Biaya',
                                                        hint: '0',
                                                        isMandatory: true,
                                                        keyboardType: TextInputType.number,
                                                        prefix: Padding(
                                                            padding: const EdgeInsets.only(right: 8.0),
                                                            child: Text('Rp', style: TextStyle(color: _textSlatePrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                                                        ),
                                                        inputFormatters: [_CurrencyFormatFormatter()],
                                                        validator: (val) => val == null || val.isEmpty ? 'Nominal wajib diisi' : null,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildTanggalField(),
                                                    const SizedBox(height: 16),
                                                    _buildDropdownField(
                                                        label: 'Kategori Pengeluaran',
                                                        hint: 'Pilih kategori',
                                                        value: _selectedKategori,
                                                        items: _daftarKategori,
                                                        isMandatory: true,
                                                        validator: (val) => val == null ? 'Kategori wajib dipilih' : null,
                                                        onChanged: (val) {
                                                            setState(() {
                                                                _selectedKategori = val;
                                                                _isKategoriLainnyaSelected = (val == 'Lainnya');
                                                            });
                                                        },
                                                    ),
                                                    if (_isKategoriLainnyaSelected) ...[
                                                        const SizedBox(height: 16),
                                                        _buildTextField(
                                                            controller: _kategoriBaruController,
                                                            label: 'Nama Kategori Baru',
                                                            hint: 'Contoh: Pajak Bumi Bangunan',
                                                            isMandatory: true,
                                                            validator: (val) => val == null || val.trim().isEmpty ? 'Nama kategori baru wajib diisi' : null,
                                                        ),
                                                    ],
                                                ],
                                            ),
                                        ),
                                        const SizedBox(height: 16),

                                        _buildCardWrapper(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    const Text('Detail Tambahan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                    const SizedBox(height: 16),
                                                    _buildTextField(
                                                        controller: _tokoController,
                                                        label: 'Nama Toko / Vendor',
                                                        hint: 'Contoh: TB Sinar Maju',
                                                        isMandatory: false,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildTextField(
                                                        controller: _notaController,
                                                        label: 'Nomor Nota Fisik',
                                                        hint: 'Contoh: INV-98742',
                                                        isMandatory: false,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    _buildTextField(
                                                        controller: _catatanController,
                                                        label: 'Catatan Keterangan',
                                                        hint: 'Masukkan keterangan tambahan jika ada...',
                                                        isMandatory: false,
                                                        maxLines: 3,
                                                    ),
                                                ],
                                            ),
                                        ),
                                        const SizedBox(height: 16),

                                        _buildCardWrapper(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    const Text('Bukti Pembelian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                    const SizedBox(height: 14),
                                                    _buildBuktiPengeluaranContent(),
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
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
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: _borderSlateLight, width: 1),
            ),
            child: child,
        );
    }

    Widget _buildTanggalField() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text('Tanggal Transaksi', style: TextStyle(color: _textSlateMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(' *', style: TextStyle(color: _errorColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                    controller: _tanggalController,
                    readOnly: true,
                    onTap: _selectTanggal,
                    validator: (val) => val == null || val.isEmpty ? 'Tanggal wajib diisi' : null,
                    style: TextStyle(color: _isReadOnly ? _textSlateMuted : _textSlatePrimary, fontSize: 15),
                    decoration: InputDecoration(
                        hintText: 'Pilih tanggal pengeluaran',
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: _isReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
                        filled: true,
                        suffixIcon: Icon(Icons.calendar_today_rounded, size: 16, color: _tealPrimary),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight, width: 1)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight.withOpacity(0.6), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1.5)),
                    ),
                ),
            ],
        );
    }

    Widget _buildBuktiPengeluaranContent() {
        if (!_hasReceiptPhoto) {
            return GestureDetector(
                onTap: _simulatePhotoSelection,
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _borderSlateLight, width: 1),
                    ),
                    child: Column(
                        children: [
                            Icon(Icons.cloud_upload_outlined, size: 32, color: _tealPrimary),
                            const SizedBox(height: 8),
                            Text('Belum ada nota terlampir', style: TextStyle(color: _textSlatePrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(_isReadOnly ? 'Tidak ada bukti foto' : 'Ketuk di sini untuk unggah nota fisik', textAlign: TextAlign.center, style: TextStyle(color: _textSlateMuted, fontSize: 12)),
                        ],
                    ),
                ),
            );
        } else {
            return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderSlateLight),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.receipt_long_rounded, color: _tealPrimary, size: 22),
                                    const SizedBox(width: 8),
                                    Text('Preview_Nota_Fisik.jpg', style: TextStyle(color: _textSlatePrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                            ),
                        ),
                        if (!_isReadOnly)
                            GestureDetector(
                                onTap: _simulatePhotoSelection,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                                        border: Border(top: BorderSide(color: _borderSlateLight)),
                                    ),
                                    child: Text('Ganti Lampiran Nota', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _tealPrimary)),
                                ),
                            ),
                    ],
                ),
            );
        }
    }

    Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required bool isMandatory, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, int maxLines = 1, Widget? prefix}) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text(label, style: TextStyle(color: _textSlateMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                        if (isMandatory) Text(' *', style: TextStyle(color: _errorColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                    controller: controller,
                    enabled: !_isReadOnly,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    validator: validator,
                    maxLines: maxLines,
                    style: TextStyle(color: _isReadOnly ? _textSlateMuted : _textSlatePrimary, fontSize: 15),
                    cursorColor: _tealPrimary,
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: _isReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
                        filled: true,
                        prefix: prefix,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight, width: 1)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight.withOpacity(0.6), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1.5)),
                    ),
                ),
            ],
        );
    }

    Widget _buildDropdownField({required String label, required String hint, required String? value, required List<String> items, required bool isMandatory, String? Function(String?)? validator, required void Function(String?) onChanged}) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text(label, style: TextStyle(color: _textSlateMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                        if (isMandatory) Text(' *', style: TextStyle(color: _errorColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                    value: value,
                    items: items.map((String item) {
                        return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item, style: TextStyle(color: _textSlatePrimary, fontSize: 15)),
                        );
                    }).toList(),
                    onChanged: _isReadOnly ? null : onChanged,
                    validator: validator,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSlateMuted, size: 20),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: _textSlatePrimary, fontSize: 15),
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.6), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: _isReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight, width: 1)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderSlateLight.withOpacity(0.6), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _tealPrimary, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1.5)),
                    ),
                ),
            ],
        );
    }

    Widget _buildStickyFooter() {
        final String cancelLabel = _isReadOnly ? 'Kembali' : 'Batal';
        final String primaryLabel = _isReadOnly ? 'Edit Data' : 'Simpan Nota';

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
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: _borderSlateLight),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                backgroundColor: Colors.white,
                            ),
                            child: Text(
                                cancelLabel,
                                style: TextStyle(color: _textSlatePrimary, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: _handlePrimaryButtonAction,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: _tealPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                                primaryLabel,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}

class _CurrencyFormatFormatter extends TextInputFormatter {
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
