import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailPenyewaPage extends StatefulWidget {
    final bool isEditMode;
    final bool isReadOnly;
    final Map<String, dynamic>? penyewa;

    const DetailPenyewaPage({
        Key? key,
        required this.isEditMode,
        required this.isReadOnly,
        this.penyewa,
    }) : super(key: key);

    @override
    State<DetailPenyewaPage> createState() => _DetailPenyewaPageState();
}

class _DetailPenyewaPageState extends State<DetailPenyewaPage> {
    final _formKey = GlobalKey<FormState>();

    late bool _currentReadOnly;
    late bool _currentEditMode;

    final Color _bgColor = const Color(0xfff8fafc);
    final Color _cardColor = const Color(0xffffffff);
    final Color _borderColor = const Color(0xffe2e8f0);
    final Color _textPrimary = const Color(0xff202124);
    final Color _textSecondary = const Color(0xff6b7280);
    final Color _accentColor = const Color(0xff059669);

    // Controllers
    final TextEditingController _namaController = TextEditingController();
    final TextEditingController _waController = TextEditingController();
    final TextEditingController _tanggalMasukController = TextEditingController();
    final TextEditingController _namaPjController = TextEditingController();
    final TextEditingController _waPjController = TextEditingController();
    final TextEditingController _alamatAsalController = TextEditingController();
    final TextEditingController _catatanController = TextEditingController();

    String? _selectedKamar;
    String? _selectedHubungan;
    bool _hasIdPhoto = false; 

    final List<String> _daftarKamar = ['Kamar A1', 'Kamar A2', 'Kamar B1', 'Kamar B2', 'Kamar 101', 'Kamar 102', 'Kamar 103', 'Kamar 104', 'Kamar 105'];
    final List<String> _daftarHubungan = ['Orang Tua', 'Suami / Istri', 'Saudara Kandung', 'Kerabat', 'Teman', 'Lainnya'];

    @override
    void initState() {
        super.initState();
        _currentReadOnly = widget.isReadOnly;
        _currentEditMode = widget.isEditMode;
        _populateData();
    }

    void _populateData() {
        if (widget.penyewa != null) {
            _namaController.text = widget.penyewa!['nama'] ?? '';
            _waController.text = widget.penyewa!['whatsapp'] ?? '';
            _tanggalMasukController.text = widget.penyewa!['tanggal_masuk'] ?? '';
            _namaPjController.text = widget.penyewa!['nama_pj'] ?? '';
            _waPjController.text = widget.penyewa!['whatsapp_pj'] ?? '';
            _alamatAsalController.text = widget.penyewa!['alamat_asal'] ?? '';
            _catatanController.text = widget.penyewa!['catatan_internal'] ?? '';
            
            final String? kamarPenyewa = widget.penyewa!['kamar'];
            if (_daftarKamar.contains(kamarPenyewa)) {
                _selectedKamar = kamarPenyewa;
            } else if (kamarPenyewa != null) {
                _daftarKamar.add(kamarPenyewa);
                _selectedKamar = kamarPenyewa;
            }

            final String? hubunganPj = widget.penyewa!['hubungan_pj'];
            if (_daftarHubungan.contains(hubunganPj)) {
                _selectedHubungan = hubunganPj;
            }
            
            _hasIdPhoto = widget.penyewa!['has_foto'] ?? false;
        }
    }

    @override
    void dispose() {
        _namaController.dispose();
        _waController.dispose();
        _tanggalMasukController.dispose();
        _namaPjController.dispose();
        _waPjController.dispose();
        _alamatAsalController.dispose();
        _catatanController.dispose();
        super.dispose();
    }

    Future<void> _selectTanggalMasuk() async {
        if (_currentReadOnly) return;
        DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: _accentColor,
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
                _tanggalMasukController.text = "${picked.day} ${_getNamaBulan(picked.month)} ${picked.year}";
            });
        }
    }

    String _getNamaBulan(int month) {
        const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        return bulan[month - 1];
    }

    void _simulateIdPhotoSelection() {
        if (_currentReadOnly) return;
        setState(() {
            _hasIdPhoto = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text('Foto identitas berhasil diperbarui (Simulasi)'),
                backgroundColor: _accentColor,
                duration: const Duration(seconds: 2),
            ),
        );
    }

    void _handlePrimaryButtonAction() {
        if (_currentReadOnly) {
            setState(() {
                _currentReadOnly = false;
                _currentEditMode = true;
            });
        } else {
            if (_formKey.currentState!.validate()) {
                final String pesanSukses = widget.penyewa == null || !widget.isEditMode
                        ? 'Data penyewa baru berhasil disimpan' 
                        : 'Perubahan data penyewa berhasil disimpan';
                        
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
        String appBarTitle = 'Tambah Penyewa Baru';
        if (_currentReadOnly) {
            appBarTitle = 'Detail Penyewa';
        } else if (_currentEditMode) {
            appBarTitle = 'Edit Data Penyewa';
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
                                        _buildInformasiPenghuniSection(),
                                        const SizedBox(height: 16),
                                        _buildHunianSection(),
                                        const SizedBox(height: 16),
                                        _buildKontakDaruratSection(),
                                        const SizedBox(height: 16),
                                        _buildIdentitasSection(),
                                        const SizedBox(height: 16),
                                        _buildInformasiTambahanSection(),
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

    // ==========================================
    // SECTION 1 - INFORMASI PENGHUNI
    // ==========================================
    Widget _buildInformasiPenghuniSection() {
        return _buildAccordionCard(
            title: 'Informasi Penghuni',
            initiallyExpanded: true,
            icon: Icons.person_outline_rounded,
            children: [
                _buildTextField(
                    controller: _namaController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama sesuai KTP',
                    isMandatory: true,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _waController,
                    label: 'WhatsApp',
                    hint: 'Contoh: 0812xxxxxxxx',
                    isMandatory: true,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nomor WhatsApp wajib diisi' : null,
                ),
            ],
        );
    }

    // ==========================================
    // SECTION 2 - HUNIAN
    // ==========================================
    Widget _buildHunianSection() {
        return _buildAccordionCard(
            title: 'Hunian',
            initiallyExpanded: false,
            icon: Icons.bed_outlined,
            children: [
                _buildDropdownField(
                    label: 'Kamar',
                    hint: '-- Pilih Alokasi Kamar --',
                    value: _selectedKamar,
                    items: _daftarKamar,
                    isMandatory: true,
                    validator: (val) => val == null ? 'Kamar wajib dipilih' : null,
                    onChanged: (val) => setState(() => _selectedKamar = val),
                ),
                const SizedBox(height: 16),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                Text('Tanggal Masuk', style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                                Text(' *', style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                            controller: _tanggalMasukController,
                            readOnly: true,
                            onTap: _selectTanggalMasuk,
                            validator: (val) => val == null || val.isEmpty ? 'Tanggal masuk wajib diisi' : null,
                            style: TextStyle(color: _currentReadOnly ? _textSecondary : _textPrimary, fontSize: 15),
                            decoration: InputDecoration(
                                hintText: 'Pilih Tanggal Masuk',
                                hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                fillColor: _currentReadOnly ? _bgColor : _cardColor,
                                filled: true,
                                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: _textSecondary),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor, width: 1)),
                                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor.withOpacity(0.6), width: 1)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor, width: 1.5)),
                                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1)),
                                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
                            ),
                        ),
                    ],
                ),
            ],
        );
    }

    // ==========================================
    // SECTION 3 - KONTAK DARURAT
    // ==========================================
    Widget _buildKontakDaruratSection() {
        return _buildAccordionCard(
            title: 'Kontak Darurat',
            initiallyExpanded: false,
            icon: Icons.contact_emergency_outlined,
            children: [
                _buildTextField(
                    controller: _namaPjController,
                    label: 'Nama',
                    hint: 'Nama Penanggung Jawab',
                    isMandatory: false,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                    label: 'Hubungan',
                    hint: '-- Pilih Hubungan --',
                    value: _selectedHubungan,
                    items: _daftarHubungan,
                    isMandatory: false,
                    onChanged: (val) => setState(() => _selectedHubungan = val),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _waPjController,
                    label: 'WhatsApp',
                    hint: 'Nomor WhatsApp Penanggung Jawab',
                    isMandatory: false,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
            ],
        );
    }

    // ==========================================
    // SECTION 4 - IDENTITAS
    // ==========================================
    Widget _buildIdentitasSection() {
        return _buildAccordionCard(
            title: 'Identitas',
            initiallyExpanded: false,
            icon: Icons.badge_outlined,
            children: [
                Text('Foto KTP/SIM', style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                if (!_hasIdPhoto) ...[
                    GestureDetector(
                        onTap: _simulateIdPhotoSelection,
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
                                    Icon(Icons.cloud_upload_outlined, size: 36, color: _accentColor.withOpacity(0.8)),
                                    const SizedBox(height: 10),
                                    Text('Belum Ada Dokumen Terunggah', style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(_currentReadOnly ? 'Tidak ada lampiran foto identitas' : 'Ketuk area ini untuk mengunggah foto KTP/SIM', textAlign: TextAlign.center, style: TextStyle(color: _textSecondary, fontSize: 12)),
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
                                                Icon(Icons.image, color: _textSecondary, size: 24),
                                                const SizedBox(width: 8),
                                                Text('Preview_Identitas_Penyewa.jpg', style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
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
                                                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka detail foto (Simulasi)'))); },
                                                icon: const Icon(Icons.visibility_outlined, size: 18),
                                                label: const Text('Lihat Foto'),
                                                style: TextButton.styleFrom(foregroundColor: _textPrimary),
                                            ),
                                            if (!_currentReadOnly) ...[
                                                const SizedBox(width: 8),
                                                TextButton.icon(
                                                    onPressed: _simulateIdPhotoSelection,
                                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                                    label: const Text('Ganti Foto'),
                                                    style: TextButton.styleFrom(foregroundColor: _accentColor),
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

    // ==========================================
    // SECTION 5 - INFORMASI TAMBAHAN
    // ==========================================
    Widget _buildInformasiTambahanSection() {
        return _buildAccordionCard(
            title: 'Informasi Tambahan',
            initiallyExpanded: false,
            icon: Icons.info_outline_rounded,
            children: [
                _buildTextField(
                    controller: _alamatAsalController,
                    label: 'Alamat Asal',
                    hint: 'Masukkan alamat asal sesuai KTP',
                    isMandatory: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _catatanController,
                    label: 'Catatan Internal',
                    hint: 'Tambahkan catatan khusus mengenai penyewa ini...',
                    isMandatory: false,
                ),
            ],
        );
    }

    // ==========================================
    // UTILS & CORE FIELD COMPONENTS
    // ==========================================
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
                    leading: Icon(icon, color: _accentColor, size: 22),
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

    Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required bool isMandatory, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator}) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text(label, style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                        if (isMandatory) Text(' *', style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                    controller: controller,
                    enabled: !_currentReadOnly,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    validator: validator,
                    style: TextStyle(color: _currentReadOnly ? _textSecondary : _textPrimary, fontSize: 15),
                    cursorColor: _accentColor,
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: _currentReadOnly ? _bgColor : _cardColor,
                        filled: true,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor, width: 1)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor.withOpacity(0.6), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
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
                        if (isMandatory) Text(' *', style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w600)),
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
                    onChanged: _currentReadOnly ? null : onChanged,
                    validator: validator,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSecondary, size: 20),
                    dropdownColor: _cardColor,
                    style: TextStyle(color: _textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: _currentReadOnly ? _bgColor : _cardColor,
                        filled: true,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor, width: 1)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor.withOpacity(0.6), width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
                    ),
                ),
            ],
        );
    }

    Widget _buildStickyFooter() {
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
                            child: Text(_currentReadOnly ? 'Kembali' : 'Batal', style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: _handlePrimaryButtonAction,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: _accentColor,
                                foregroundColor: _cardColor,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(_currentReadOnly ? 'Edit Data' : 'Simpan Data', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                    ),
                ],
            ),
        );
    }
}
