import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Arsitektur Enum Modern untuk kejelasan status data halaman modul finansial
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

    // State dinamis internal berbasis enum
    late PengeluaranMode _currentMode;

    final Color _bgColor = const Color(0xFFF8F9FA);
    final Color _cardColor = const Color(0xFFFFFFFF);
    final Color _primaryColor = const Color(0xFF1A73E8);
    final Color _accentColor = const Color(0xFF059669); 
    final Color _textPrimary = const Color(0xFF202124);
    final Color _textSecondary = const Color(0xFF5F7A90);
    final Color _borderColor = const Color(0xFFE8EAED);
    final Color _errorColor = const Color(0xFFEA4335);

    final TextEditingController _namaController = TextEditingController();
    final TextEditingController _nominalController = TextEditingController();
    final TextEditingController _tanggalController = TextEditingController();
    final TextEditingController _tokoController = TextEditingController();
    final TextEditingController _notaController = TextEditingController();
    final TextEditingController _catatanController = TextEditingController();

    String? _selectedKategori;
    bool _hasReceiptPhoto = false;

    final List<String> _daftarKategori = [
        'Perawatan Bangunan',
        'Utilitas',
        'Operasional',
        'Perlengkapan',
        'Lainnya'
    ];

    // Helper getter status read-only untuk mempersingkat sintaksis form
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
        super.dispose();
    }

    Future<void> _selectTanggal() async {
        if (_isReadOnly) return;
        DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: _primaryColor,
                            onPrimary: _cardColor,
                            onSurface: _textPrimary,
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
                content: const Text('Foto nota berhasil dilampirkan (Simulasi)'),
                backgroundColor: _accentColor,
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
                final String pesanSukses = _currentMode == PengeluaranMode.add
                        ? 'Data pengeluaran berhasil ditambahkan'
                        : 'Perubahan data pengeluaran berhasil disimpan';

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(pesanSukses),
                        backgroundColor: _accentColor,
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
            backgroundColor: _bgColor,
            appBar: AppBar(
                backgroundColor: _cardColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                    appBarTitle,
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                    ),
                ),
                shape: Border(bottom: BorderSide(color: _borderColor, width: 1)),
            ),
            body: SafeArea(
                child: Column(
                    children: [
                        Expanded(
                            child: Form(
                                key: _formKey,
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                    physics: const ClampingScrollPhysics(),
                                    children: [
                                        _buildInformasiPengeluaranSection(),
                                        const SizedBox(height: 16),
                                        _buildDetailTambahanSection(),
                                        const SizedBox(height: 16),
                                        _buildBuktiPengeluaranSection(),
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

    Widget _buildInformasiPengeluaranSection() {
        return _buildAccordionCard(
            title: 'Informasi Pengeluaran',
            initiallyExpanded: true,
            icon: Icons.receipt_long_outlined,
            children: [
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
                    label: 'Nominal',
                    hint: '0',
                    isMandatory: true,
                    keyboardType: TextInputType.number,
                    prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Rp', style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    inputFormatters: [_CurrencyFormatFormatter()],
                    validator: (val) => val == null || val.isEmpty ? 'Nominal wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                Text('Tanggal', style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                                Text(' *', style: TextStyle(color: _errorColor, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                            controller: _tanggalController,
                            readOnly: true,
                            onTap: _selectTanggal,
                            validator: (val) => val == null || val.isEmpty ? 'Tanggal wajib diisi' : null,
                            style: TextStyle(color: _isReadOnly ? _textSecondary : _textPrimary, fontSize: 15),
                            decoration: InputDecoration(
                                hintText: 'Pilih Tanggal Pengeluaran',
                                hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                fillColor: _isReadOnly ? _bgColor : _cardColor,
                                filled: true,
                                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: _textSecondary),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor, width: 1)),
                                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor.withOpacity(0.6), width: 1)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
                                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1)),
                                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1.5)),
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                    label: 'Kategori',
                    hint: '-- Pilih Kategori Pengeluaran --',
                    value: _selectedKategori,
                    items: _daftarKategori,
                    isMandatory: true,
                    validator: (val) => val == null ? 'Kategori wajib dipilih' : null,
                    onChanged: (val) => setState(() => _selectedKategori = val),
                ),
            ],
        );
    }

    Widget _buildDetailTambahanSection() {
        return _buildAccordionCard(
            title: 'Detail Tambahan',
            initiallyExpanded: false,
            icon: Icons.assignment_outlined,
            children: [
                _buildTextField(
                    controller: _tokoController,
                    label: 'Nama Toko / Vendor',
                    hint: 'Contoh: TB Sinar Maju',
                    isMandatory: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _notaController,
                    label: 'Nomor Nota',
                    hint: 'Contoh: INV-98742',
                    isMandatory: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _catatanController,
                    label: 'Catatan',
                    hint: 'Masukkan keterangan tambahan jika ada...',
                    isMandatory: false,
                    maxLines: 4,
                ),
            ],
        );
    }

    Widget _buildBuktiPengeluaranSection() {
        return _buildAccordionCard(
            title: 'Bukti Pengeluaran',
            initiallyExpanded: false,
            icon: Icons.camera_alt_outlined,
            children: [
                Text('Foto Nota', style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                if (!_hasReceiptPhoto) ...[
                    GestureDetector(
                        onTap: _simulatePhotoSelection,
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                            decoration: BoxDecoration(
                                color: _bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderColor, width: 1, style: BorderStyle.solid),
                            ),
                            child: Column(
                                children: [
                                    Icon(Icons.cloud_upload_outlined, size: 36, color: _primaryColor.withOpacity(0.8)),
                                    const SizedBox(height: 10),
                                    Text('Belum Ada Nota Terunggah', style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(_isReadOnly ? 'Tidak ada bukti lampiran nota' : 'Ketuk area ini untuk mengunggah foto nota fisik', textAlign: TextAlign.center, style: TextStyle(color: _textSecondary, fontSize: 12)),
                                ],
                            ),
                        ),
                    ),
                ] else ...[
                    Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: _bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                Container(
                                    height: 160,
                                    decoration: BoxDecoration(color: _borderColor.withOpacity(0.4), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                                    child: Center(
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                Icon(Icons.receipt, color: _textSecondary, size: 24),
                                                const SizedBox(width: 8),
                                                Text('Preview_Nota_Fisik.jpg', style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                            ],
                                        ),
                                    ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                            TextButton.icon(
                                                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka foto nota penuh (Simulasi)'))); },
                                                icon: const Icon(Icons.visibility_outlined, size: 18),
                                                label: const Text('Lihat Nota'),
                                                style: TextButton.styleFrom(foregroundColor: _textPrimary),
                                            ),
                                            if (!_isReadOnly) ...[
                                                const SizedBox(width: 8),
                                                TextButton.icon(
                                                    onPressed: _simulatePhotoSelection,
                                                    icon: const Icon(Icons.refresh_outlined, size: 18),
                                                    label: const Text('Ganti Nota'),
                                                    style: TextButton.styleFrom(foregroundColor: _primaryColor),
                                                ),
                                            ],
                                        ],
                                    ),
                                )
                            ],
                        ),
                    ),
                ],
            ],
        );
    }

    Widget _buildAccordionCard({required String title, required bool initiallyExpanded, required IconData icon, required List<Widget> children}) {
        return Container(
            decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor, width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                child: ExpansionTile(
                    initiallyExpanded: initiallyExpanded,
                    leading: Icon(icon, color: _primaryColor, size: 22),
                    title: Text(title, style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
                    iconColor: _textSecondary,
                    collapsedIconColor: _textSecondary,
                    childrenPadding: const EdgeInsets.all(20).copyWith(top: 0),
                    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                ),
            ),
        );
    }

    Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required bool isMandatory, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, int maxLines = 1, Widget? prefixIcon}) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text(label, style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                        if (isMandatory) Text(' *', style: TextStyle(color: _errorColor, fontSize: 13, fontWeight: FontWeight.w600)),
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
                    style: TextStyle(color: _isReadOnly ? _textSecondary : _textPrimary, fontSize: 15),
                    cursorColor: _primaryColor,
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: _isReadOnly ? _bgColor : _cardColor,
                        filled: true,
                        prefixIcon: prefixIcon,
                        prefixIconConstraints: prefixIcon != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor, width: 1)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor.withOpacity(0.6), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
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
                        Text(label, style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                        if (isMandatory) Text(' *', style: TextStyle(color: _errorColor, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                    value: value,
                    items: items.map((String item) {
                        return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item, style: TextStyle(color: _textPrimary, fontSize: 15)),
                        );
                    }).toList(),
                    onChanged: _isReadOnly ? null : onChanged,
                    validator: validator,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSecondary, size: 20),
                    dropdownColor: _cardColor,
                    style: TextStyle(color: _textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: _isReadOnly ? _bgColor : _cardColor,
                        filled: true,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor, width: 1)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor.withOpacity(0.6), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errorColor, width: 1.5)),
                    ),
                ),
            ],
        );
    }

    Widget _buildStickyFooter() {
        final String cancelLabel = _isReadOnly ? 'Kembali' : 'Batal';
        final String primaryLabel = _isReadOnly ? 'Edit Data' : 'Simpan Data';

        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
                color: _cardColor,
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: _cardColor,
                                elevation: 0,
                            ),
                            child: Text(
                                cancelLabel,
                                style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: _handlePrimaryButtonAction,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: _isReadOnly ? _primaryColor : _accentColor,
                                foregroundColor: _cardColor,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                                primaryLabel,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
