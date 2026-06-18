import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CatatPembayaranPage extends StatefulWidget {
    final Map<String, dynamic>? kamar;

    const CatatPembayaranPage({
        Key? key,
        this.kamar,
    }) : super(key: key);

    @override
    State<CatatPembayaranPage> createState() => _CatatPembayaranPageState();
}

class _CatatPembayaranPageState extends State<CatatPembayaranPage> {
    final _formKey = GlobalKey<FormState>();
    bool _isLoading = false;

    final TextEditingController _etPeriode = TextEditingController();
    final TextEditingController _etBulan = TextEditingController(text: "1");
    final TextEditingController _etNominal = TextEditingController();

    String? _selectedPenghuni;
    String? _selectedMetode;
    
    File? _buktiFile;
    Uint8List? _webImageBytes; // Wadah murni penyimpan data bytes khusus Flutter Web Preview
    final ImagePicker _picker = ImagePicker();

    // Kunci Konstanta Warna V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);
    final Color _errorColor = const Color(0xFFEF4444);

    final List<String> _listMetode = ["Tunai / Cash", "Transfer Bank Manual", "QRIS / Dompet Digital"];
    final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    int _hargaKamarAsli = 0;

    @override
    void initState() {
        super.initState();
        _initializeFormWithData();
    }

    void _initializeFormWithData() {
        if (widget.kamar != null) {
            final String namaTenant = widget.kamar!['tenant_name'] ?? 'Penyewa Aktif';
            final String namaUnit = widget.kamar!['room_name'] ?? '-';
            
            _selectedPenghuni = "$namaTenant (Kamar $namaUnit)";
            
            _hargaKamarAsli = widget.kamar!['price'] ?? 0;
            _hitungNominalOtomatis();
            
            final DateTime sekarang = DateTime.now();
            _etPeriode.text = "${sekarang.year}-${sekarang.month.toString().padLeft(2, '0')}";
        }
    }

    void _hitungNominalOtomatis() {
        final int jumlahBulan = int.tryParse(_etBulan.text.trim()) ?? 0;
        setState(() {
            _etNominal.text = (_hargaKamarAsli * jumlahBulan).toString();
        });
    }

    @override
    void dispose() {
        _etPeriode.dispose();
        _etBulan.dispose();
        _etNominal.dispose();
        super.dispose();
    }

    Future<void> _selectPeriodeDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
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
                _etPeriode.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}";
            });
        }
    }

    void _showImageSourceBottomSheet() {
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
            final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 60);
            if (pickedFile != null) {
                // AMAN LINTAS PLATFORM: Ambil bytes mentah dari XFile sebelum diubah ke File io
                final Uint8List bytes = await pickedFile.readAsBytes();
                setState(() {
                    _webImageBytes = bytes;
                    _buktiFile = File(pickedFile.path);
                });
                _showSnackBar('Bukti transaksi berhasil dilampirkan', _tealPrimary);
            }
        } catch (e) {
            _showSnackBar('Gagal mengambil gambar bukti transfer', _errorColor);
        }
    }

    void _handleSavePayment() async {
        if (!_formKey.currentState!.validate() || _selectedMetode == null || widget.kamar == null) {
            _showSnackBar("Mohon lengkapi nominal dan metode transaksi secara valid!", _errorColor);
            return;
        }

        setState(() => _isLoading = true);

        final String roomId = widget.kamar!['room_id']?.toString() ?? '';
        final int? nominalBayar = int.tryParse(_etNominal.text.trim());

        if (roomId.isEmpty || nominalBayar == null || nominalBayar <= 0) {
            _showSnackBar("Nominal transaksi tidak valid!", _errorColor);
            setState(() => _isLoading = false);
            return;
        }

        final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
        final String? paymentId = dbRef.child('users_data/$_currentUid/laporan_kas').push().key;

        if (paymentId == null) {
            setState(() => _isLoading = false);
            return;
        }

        String buktiStorageUrl = "";

        // PROSES UPLOAD ADAPTIF MULTI-PLATFORM STERIL
        if (_webImageBytes != null || _buktiFile != null) {
            try {
                final Reference storageRef = FirebaseStorage.instance
                    .ref()
                    .child('users_data/$_currentUid/payment_proofs/$paymentId.jpg');
                
                UploadTask uploadTask;
                if (kIsWeb && _webImageBytes != null) {
                    // Jika di Web Preview, upload data bytes mentah asli non-corrupt
                    uploadTask = storageRef.putData(
                        _webImageBytes!, 
                        SettableMetadata(contentType: 'image/jpeg')
                    );
                } else {
                    // Jika di HP Android APK, gunakan file upload murni
                    uploadTask = storageRef.putFile(_buktiFile!);
                }
                
                final TaskSnapshot snapshot = await uploadTask;
                buktiStorageUrl = await snapshot.ref.getDownloadURL();
            } catch (e) {
                _showSnackBar("Gagal mengunggah gambar bukti transfer: ${e.toString()}", _errorColor);
                setState(() => _isLoading = false);
                return;
            }
        }

        final String tanggalHariIni = DateTime.now().toString().split(' ')[0];

        final Map<String, dynamic> transaksionalPayload = {
            'users_data/$_currentUid/laporan_kas/$paymentId': {
                'payment_id': paymentId,
                'room_id': roomId,
                'room_name': widget.kamar!['room_name'] ?? '-',
                'tenant_name': widget.kamar!['tenant_name'] ?? '-',
                'amount': nominalBayar,
                'payment_method': _selectedMetode,
                'billing_period': _etPeriode.text.trim(),
                'transaction_date': tanggalHariIni,
                'type': 'pemasukan',
                'proof_url': buktiStorageUrl, 
                'duration_months': int.tryParse(_etBulan.text.trim()) ?? 1,
            },
            'users_data/$_currentUid/rooms/$roomId/has_pending': false,
            'users_data/$_currentUid/rooms/$roomId/pending_amount': 0,
            'users_data/$_currentUid/rooms/$roomId/last_paid_period': _etPeriode.text.trim(),
        };

        try {
            await dbRef.update(transaksionalPayload);
            _showSnackBar("🧾 Pembayaran kas berhasil dicatat dan status kamar diperbarui!", _tealPrimary);
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
                    "Pencatatan Pembayaran",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textSlatePrimary),
                ),
                centerTitle: true,
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            ),
            body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0), 
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            _buildFormCard(context),
                            const SizedBox(height: 16),
                            _buildHistorySection(),
                            const SizedBox(height: 24),
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

    Widget _buildFormCard(BuildContext context) {
        final List<String> dinamisPenghuniList = _selectedPenghuni != null ? [_selectedPenghuni!] : [];

        return _buildCardWrapper(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    _buildFieldLabel("Nama Penghuni Aktif"),
                    _buildDropdownField(
                        value: _selectedPenghuni,
                        hint: "Pilih nama penghuni...",
                        icon: Icons.person_outline_rounded,
                        items: dinamisPenghuniList,
                        onChanged: null,
                    ),
                    
                    _buildFieldLabel("Periode Tagihan Buku"),
                    _buildDatePickerField(context),

                    _buildFieldLabel("Durasi Pembayaran (Bulan)"),
                    _buildBulanField(),
                    
                    _buildFieldLabel("Nominal Setoran Bayar (Otomatis)"),
                    _buildNominalField(),
                    
                    _buildFieldLabel("Metode Transaksi"),
                    _buildDropdownField(
                        value: _selectedMetode,
                        hint: "Pilih metode transaksi...",
                        icon: Icons.account_balance_wallet_outlined,
                        items: _listMetode,
                        onChanged: (val) => setState(() => _selectedMetode = val),
                    ),

                    _buildFieldLabel("Unggah Lampiran Bukti Transfer (Opsional)"),
                    _buildBuktiUploadContent(),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSavePayment,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _tealPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text(
                                        "Simpan Pembayaran Kas", 
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildHistorySection() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                    child: Text(
                        "Riwayat Transaksi Unit",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary),
                    ),
                ),
                _buildCardWrapper(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text("🧾", style: TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                    "Belum Ada Pembayaran",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _textSlatePrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "Data setoran pembayaran penghuni akan muncul di sini",
                                    style: TextStyle(fontSize: 13, color: _textSlateMuted, fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.center,
                                ),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildFieldLabel(String label) {
        return Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 8.0, top: 12.0),
            child: Text(
                label,
                style: TextStyle(fontSize: 14, color: _textSlateMuted, fontWeight: FontWeight.w400),
            ),
        );
    }

    Widget _buildDropdownField({
        required String? value,
        required String hint,
        required IconData icon,
        required List<String> items,
        required ValueChanged<String?>? onChanged,
    }) {
        return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: DropdownButtonFormField<String>(
                value: value,
                hint: Text(hint, style: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 15)),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSlateMuted),
                decoration: InputDecoration(
                    prefixIcon: Icon(icon, color: _textSlateMuted, size: 20),
                    border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 15, color: _textSlatePrimary, fontWeight: FontWeight.w400),
                items: items.map((String val) {
                    return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: onChanged,
            ),
        );
    }

    Widget _buildDatePickerField(BuildContext context) {
        return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: TextField(
                controller: _etPeriode,
                readOnly: true,
                onTap: () => _selectPeriodeDate(context),
                style: TextStyle(fontSize: 15, color: _textSlatePrimary, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                    hintText: "Pilih periode pembayaran",
                    hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 15),
                    prefixIcon: Icon(Icons.calendar_month_outlined, color: _textSlateMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
            ),
        );
    }

    Widget _buildBulanField() {
        return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: TextField(
                controller: _etBulan,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _textSlatePrimary),
                onChanged: (val) => _hitungNominalOtomatis(),
                decoration: InputDecoration(
                    hintText: "Masukkan jumlah bulan sewa",
                    prefixIcon: Icon(Icons.timelapse_rounded, color: _textSlateMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
            ),
        );
    }

    Widget _buildNominalField() {
        return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), 
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: TextField(
                controller: _etNominal,
                readOnly: true, 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _tealPrimary),
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.payments_outlined, color: _tealPrimary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
            ),
        );
    }

    Widget _buildBuktiUploadContent() {
        if (_webImageBytes == null && _buktiFile == null) {
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
                            Icon(Icons.cloud_upload_outlined, size: 30, color: _tealPrimary),
                            const SizedBox(height: 8),
                            Text('Belum ada lampiran struk', style: TextStyle(color: _textSlatePrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            const Text('Ketuk di sini untuk unggah berkas bukti pembayaran', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
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
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: kIsWeb && _webImageBytes != null
                                    ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                                    : Image.file(_buktiFile!, fit: BoxFit.cover),
                            ),
                        ),
                        GestureDetector(
                            onTap: _showImageSourceBottomSheet,
                            child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                                    border: Border(top: BorderSide(color: _borderSlateLight)),
                                ),
                                child: Text('Ganti Lampiran Bukti Transfer', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _tealPrimary)),
                            ),
                        ),
                    ],
                ),
            );
        }
    }
}
