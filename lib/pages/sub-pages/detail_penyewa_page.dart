import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

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
    bool _isLoading = false;

    // Konsistensi Skema Warna Mutlak Pakem V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);
    final Color _errorColor = const Color(0xFFEF4444);

    // Controllers
    final TextEditingController _namaController = TextEditingController();
    final TextEditingController _waController = TextEditingController();
    final TextEditingController _tanggalMasukController = TextEditingController();
    final TextEditingController _namaPjController = TextEditingController();
    final TextEditingController _waPjController = TextEditingController();
    final TextEditingController _alamatAsalController = TextEditingController();
    final TextEditingController _catatanController = TextEditingController();

    String? _selectedKamarId;
    String? _selectedKamarName;
    String? _selectedHubungan;
    
    File? _imageFile;
    final ImagePicker _picker = ImagePicker();

    List<Map<String, dynamic>> _liveRoomsFromFirebase = [];
    final List<String> _daftarHubungan = ['Orang Tua', 'Suami / Istri', 'Saudara Kandung', 'Kerabat', 'Teman', 'Lainnya'];
    final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

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
            
            _selectedKamarId = widget.penyewa!['room_id'];
            _selectedKamarName = widget.penyewa!['kamar']?.toString().replaceAll('Kamar ', '');

            final String? hubunganPj = widget.penyewa!['hubungan_pj'];
            if (_daftarHubungan.contains(hubunganPj)) {
                _selectedHubungan = hubunganPj;
            }
            
            final String? localPath = widget.penyewa!['foto_ktp_local'];
            if (localPath != null && localPath.isNotEmpty) {
                _imageFile = File(localPath);
            }
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
            locale: const Locale('id', 'ID'), 
            confirmText: 'PILIH',
            cancelText: 'BATAL',
            helpText: 'PILIH TANGGAL MASUK KOS',
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
                _tanggalMasukController.text = "${picked.day} ${_getNamaBulan(picked.month)} ${picked.year}";
            });
        }
    }

    String _getNamaBulan(int month) {
        const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        return bulan[month - 1];
    }

    void _showImageSourceBottomSheet() {
        if (_currentReadOnly) return;
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
                return SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                ListTile(
                                    leading: Icon(Icons.camera_alt_outlined, color: _tealPrimary),
                                    title: const Text('Ambil Lewat Kamera HP', style: TextStyle(fontSize: 15)),
                                    onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.camera);
                                    },
                                ),
                                ListTile(
                                    leading: Icon(Icons.photo_library_outlined, color: _tealPrimary),
                                    title: const Text('Ambil Dari Galeri Foto', style: TextStyle(fontSize: 15)),
                                    onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.gallery);
                                    },
                                ),
                            ],
                        ),
                    ),
                );
            },
        );
    }

    Future<void> _pickImage(ImageSource source) async {
        try {
            final XFile? pickedFile = await _picker.pickImage(
                source: source,
                imageQuality: 70,
            );
            if (pickedFile != null) {
                setState(() {
                    _imageFile = File(pickedFile.path);
                });
                _showSnackBar('Foto dokumen identitas berhasil diperbarui', _tealPrimary);
            }
        } catch (e) {
            _showSnackBar('Gagal mengambil gambar perangkat', _errorColor);
        }
    }

    void _handlePrimaryButtonAction() async {
        if (_currentReadOnly) {
            setState(() {
                _currentReadOnly = false;
                _currentEditMode = true;
            });
            return;
        }

        if (!_formKey.currentState!.validate() || _selectedKamarId == null) {
            _showSnackBar("Mohon lengkapi seluruh kolom input wajib!", _errorColor);
            return;
        }

        setState(() => _isLoading = true);

        final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
        
        String? tenantId = widget.penyewa?['tenant_id'];
        if (tenantId == null || tenantId.isEmpty) {
            tenantId = dbRef.child('users_data/$_currentUid/tenants').push().key;
        }

        if (tenantId == null) {
            setState(() => _isLoading = false);
            return;
        }

        final Map<String, dynamic> transaksionalUpdatePayload = {
            'users_data/$_currentUid/tenants/$tenantId': {
                'tenant_id': tenantId,
                'tenant_name': _namaController.text.trim(),
                'tenant_phone': _waController.text.trim(),
                'emergency_contact_name': _namaPjController.text.trim(),
                'emergency_contact_phone': _waPjController.text.trim(),
                'room_id': _selectedKamarId,
                'room_name': _selectedKamarName,
                'join_date': _tanggalMasukController.text.trim(),
                'tenant_address': _alamatAsalController.text.trim().isEmpty ? '-' : _alamatAsalController.text.trim(),
                'notes': _catatanController.text.trim(),
                'hubungan_pj': _selectedHubungan,
                'foto_ktp_local': _imageFile?.path ?? '',
            },
            'users_data/$_currentUid/rooms/$_selectedKamarId/availability_status': 'occupied',
            'users_data/$_currentUid/rooms/$_selectedKamarId/tenant_name': _namaController.text.trim(),
            'users_data/$_currentUid/rooms/$_selectedKamarId/tenant_phone': _waController.text.trim(),
            'users_data/$_currentUid/rooms/$_selectedKamarId/tenant_address': _alamatAsalController.text.trim().isEmpty ? '-' : _alamatAsalController.text.trim(),
            'users_data/$_currentUid/rooms/$_selectedKamarId/start_date': _tanggalMasukController.text.trim(),
            'users_data/$_currentUid/rooms/$_selectedKamarId/notes': _catatanController.text.trim(),
        };

        try {
            await dbRef.update(transaksionalUpdatePayload);
            _showSnackBar("Data penyewa baru berhasil disimpan secara permanen!", _tealPrimary);
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
                content: Text(message),
                backgroundColor: bgColor,
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        final Query roomsQuery = FirebaseDatabase.instance.ref().child('users_data/$_currentUid/rooms');

        String appBarTitle = 'Tambah Penyewa Baru';
        if (_currentReadOnly) {
            appBarTitle = 'Detail Berkas Penyewa';
        } else if (_currentEditMode) {
            appBarTitle = 'Edit Data Penyewa';
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
                child: StreamBuilder<DatabaseEvent>(
                    stream: roomsQuery.onValue,
                    builder: (context, roomsSnapshot) {
                        List<Map<String, dynamic>> liveAvailableRooms = [];

                        if (roomsSnapshot.hasData && roomsSnapshot.data!.snapshot.value != null) {
                            final Map<dynamic, dynamic> mapKamar = roomsSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            mapKamar.forEach((key, val) {
                                final item = val as Map<dynamic, dynamic>;
                                if (item['availability_status'] == 'empty') {
                                    liveAvailableRooms.add({
                                        'room_id': item['room_id']?.toString() ?? key.toString(),
                                        'room_name': item['room_name']?.toString() ?? 'Kamar Tanpa Nama',
                                    });
                                }
                            });
                            liveAvailableRooms.sort((a, b) => a['room_name'].compareTo(b['room_name']));
                        }

                        if (_selectedKamarId != null && _selectedKamarName != null) {
                            bool exists = liveAvailableRooms.any((r) => r['room_id'] == _selectedKamarId);
                            if (!exists) {
                                liveAvailableRooms.insert(0, {
                                    'room_id': _selectedKamarId!,
                                    'room_name': _selectedKamarName!,
                                });
                            }
                        }

                        _liveRoomsFromFirebase = liveAvailableRooms;

                        return Column(
                            children: [
                                Expanded(
                                    child: Form(
                                        key: _formKey,
                                        child: ListView(
                                            padding: const EdgeInsets.all(24),
                                            physics: const BouncingScrollPhysics(),
                                            children: [
                                                _buildCardWrapper(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            const Text('Informasi Penghuni', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                            const SizedBox(height: 16),
                                                            _buildTextField(
                                                                controller: _namaController,
                                                                label: 'Nama Lengkap Penghuni',
                                                                hint: 'Masukkan nama sesuai KTP',
                                                                isMandatory: true,
                                                                validator: (val) => val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
                                                            ),
                                                            const SizedBox(height: 16),
                                                            _buildTextField(
                                                                controller: _waController,
                                                                label: 'Nomor WhatsApp Aktif',
                                                                hint: 'Contoh: 0812xxxxxxxx',
                                                                isMandatory: true,
                                                                keyboardType: TextInputType.phone,
                                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                                validator: (val) => val == null || val.trim().isEmpty ? 'Nomor WhatsApp wajib diisi' : null,
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                const SizedBox(height: 16),

                                                _buildCardWrapper(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            const Text('Hunian Properti', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                            const SizedBox(height: 16),
                                                            _buildDropdownField(
                                                                label: 'Alokasi Unit Kamar',
                                                                hint: 'Pilih unit kamar',
                                                                value: _selectedKamarId,
                                                                items: _liveRoomsFromFirebase,
                                                                isMandatory: true,
                                                                validator: (val) => val == null ? 'Kamar wajib dipilih' : null,
                                                                onChanged: (val) {
                                                                    setState(() {
                                                                        _selectedKamarId = val;
                                                                        _selectedKamarName = _liveRoomsFromFirebase.firstWhere((r) => r['room_id'] == val)['room_name'];
                                                                    });
                                                                },
                                                            ),
                                                            const SizedBox(height: 16),
                                                            _buildTanggalMasukField(),
                                                        ],
                                                    ),
                                                ),
                                                const SizedBox(height: 16),

                                                _buildCardWrapper(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            const Text('Kontak Darurat Penanggung Jawab', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                            const SizedBox(height: 16),
                                                            _buildTextField(
                                                                controller: _namaPjController,
                                                                label: 'Nama Lengkap Wali',
                                                                hint: 'Nama penanggung jawab',
                                                                isMandatory: false,
                                                            ),
                                                            const SizedBox(height: 16),
                                                            _buildSimpleDropdownField(
                                                                label: 'Hubungan Kekerabatan',
                                                                hint: 'Pilih hubungan kekerabatan',
                                                                value: _selectedHubungan,
                                                                items: _daftarHubungan,
                                                                isMandatory: false,
                                                                onChanged: (val) => setState(() => _selectedHubungan = val),
                                                            ),
                                                            const SizedBox(height: 16),
                                                            _buildTextField(
                                                                controller: _waPjController,
                                                                label: 'Nomor WhatsApp Wali',
                                                                hint: 'Nomor WhatsApp penanggung jawab',
                                                                isMandatory: false,
                                                                keyboardType: TextInputType.phone,
                                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                const SizedBox(height: 16),

                                                _buildCardWrapper(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            const Text('Dokumen Lampiran Resmi (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                            const SizedBox(height: 14),
                                                            _buildIdentitasUploadContent(),
                                                        ],
                                                    ),
                                                ),
                                                const SizedBox(height: 16),

                                                _buildCardWrapper(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            const Text('Informasi Tambahan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                            const SizedBox(height: 16),
                                                            _buildTextField(
                                                                controller: _alamatAsalController,
                                                                label: 'Alamat Asal KTP',
                                                                hint: 'Masukkan alamat lengkap sesuai KTP',
                                                                isMandatory: false,
                                                            ),
                                                            const SizedBox(height: 16),
                                                            _buildTextField(
                                                                controller: _catatanController,
                                                                label: 'Catatan Keterangan Internal',
                                                                hint: 'Tambahkan catatan khusus mengenai penyewa ini...',
                                                                isMandatory: false,
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                                _buildStickyFooter(),
                            ],
                        );
                    },
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

    Widget _buildTanggalMasukField() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Text('Tanggal Resmi Masuk Kos', style: TextStyle(color: _textSlateMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(' *', style: TextStyle(color: _errorColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                    controller: _tanggalMasukController,
                    readOnly: true,
                    onTap: _selectTanggalMasuk,
                    validator: (val) => val == null || val.isEmpty ? 'Tanggal masuk wajib diisi' : null,
                    style: TextStyle(color: _currentReadOnly ? _textSlateMuted : _textSlatePrimary, fontSize: 15),
                    decoration: InputDecoration(
                        hintText: 'Pilih tanggal masuk',
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: _currentReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
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

    Widget _buildIdentitasUploadContent() {
        if (_imageFile == null) {
            return GestureDetector(
                onTap: _showImageSourceBottomSheet,
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
                            Text('Belum ada dokumen terunggah', style: TextStyle(color: _textSlatePrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(_currentReadOnly ? 'Tidak ada lampiran dokumen identitas' : 'Ketuk di sini untuk ambil foto KTP dari Kamera/Galeri', textAlign: TextAlign.center, style: TextStyle(color: _textSlateMuted, fontSize: 12)),
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
                            height: 160,
                            padding: const EdgeInsets.all(8),
                            // KOREKSI AMAN: Kondisional rendering lintas platform (Web Blob URL vs APK Android File Path)
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: kIsWeb 
                                    ? Image.network(
                                        _imageFile!.path,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                        ),
                        if (!_currentReadOnly)
                            GestureDetector(
                                onTap: _showImageSourceBottomSheet,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                                        border: Border(top: BorderSide(color: _borderSlateLight)),
                                    ),
                                    child: Text('Ganti Lampiran Berkas KTP', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _tealPrimary)),
                                ),
                            ),
                    ],
                ),
            );
        }
    }

    Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required bool isMandatory, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator}) {
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
                    enabled: !_currentReadOnly,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    validator: validator,
                    style: TextStyle(color: _currentReadOnly ? _textSlateMuted : _textSlatePrimary, fontSize: 15),
                    cursorColor: _tealPrimary,
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: _currentReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
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

    Widget _buildDropdownField({required String label, required String hint, required String? value, required List<Map<String, dynamic>> items, required bool isMandatory, String? Function(String?)? validator, required void Function(String?) onChanged}) {
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
                    items: items.map((Map<String, dynamic> room) {
                        final String name = room['room_name'].toString();
                        return DropdownMenuItem<String>(
                            value: room['room_id'].toString(),
                            child: Text(name.startsWith('Kamar') ? name : 'Kamar $name', style: TextStyle(color: _textSlatePrimary, fontSize: 15)),
                        );
                    }).toList(),
                    onChanged: _currentReadOnly ? null : onChanged,
                    validator: validator,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSlateMuted, size: 20),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: _textSlatePrimary, fontSize: 15),
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.6), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: _currentReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
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

    Widget _buildSimpleDropdownField({required String label, required String hint, required String? value, required List<String> items, required bool isMandatory, String? Function(String?)? validator, required void Function(String?) onChanged}) {
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
                    onChanged: _currentReadOnly ? null : onChanged,
                    validator: validator,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSlateMuted, size: 20),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: _textSlatePrimary, fontSize: 15),
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.6), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: _currentReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
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
                            child: Text(_currentReadOnly ? 'Kembali' : 'Batal', style: TextStyle(color: _textSlatePrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: _isLoading ? null : _handlePrimaryButtonAction,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: _tealPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(_currentReadOnly ? 'Edit Data' : 'Simpan Data', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                    ),
                ],
            ),
        );
    }
}
