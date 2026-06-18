import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PengaturanPenyewaPage extends StatefulWidget {
    final String? targetRoomId;
    final String? targetRoomName;

    // Konstruktor fleksibel: Bisa dibuka mandiri atau dilempar dari Detail Kamar
    const PengaturanPenyewaPage({
        Key? key, 
        this.targetRoomId, 
        this.targetRoomName,
    }) : super(key: key);

    @override
    State<PengaturanPenyewaPage> createState() => _PengaturanPenyewaPageState();
}

class _PengaturanPenyewaPageState extends State<PengaturanPenyewaPage> {
    bool _isInputMode = false;
    bool _isLoading = false;

    // Aksen Warna Konsisten Pakem V4 Modern Teal
    final Color _tealPrimary = const Color(0xFF0F766E);
    final Color _textSlatePrimary = const Color(0xFF0F172A);
    final Color _textSlateMuted = const Color(0xFF64748B);
    final Color _borderSlateLight = const Color(0xFFCFD8DC);
    final Color _errorColor = const Color(0xFFEF4444);

    // Controller Form Penyewa Utama
    final TextEditingController _etNama = TextEditingController();
    final TextEditingController _etPhone = TextEditingController();
    final TextEditingController _etFamilyName = TextEditingController();
    final TextEditingController _etFamilyPhone = TextEditingController();
    final TextEditingController _etAddress = TextEditingController();

    // Map Ruangan Dinamis Pengait Firebase
    String? _selectedRoomId;
    String? _selectedRoomName;
    
    // Wadah penampung lokal yang direset setiap kali render
    List<Map<String, dynamic>> _currentAvailableRooms = [];

    final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    @override
    void initState() {
        super.initState();
        // Jika dilempar dari halaman detail, otomatis kunci kamar & aktifkan mode input form
        if (widget.targetRoomId != null && widget.targetRoomName != null) {
            _selectedRoomId = widget.targetRoomId;
            _selectedRoomName = widget.targetRoomName;
            _isInputMode = true; 
        }
    }

    @override
    void dispose() {
        _etNama.dispose();
        _etPhone.dispose();
        _etFamilyName.dispose();
        _etFamilyPhone.dispose();
        _etAddress.dispose();
        super.dispose();
    }

    void _handleSaveTenant() async {
        final String nama = _etNama.text.trim();
        final String phone = _etPhone.text.trim();
        final String familyName = _etFamilyName.text.trim();
        final String familyPhone = _etFamilyPhone.text.trim();
        final String alamat = _etAddress.text.trim();

        if (nama.isEmpty || phone.isEmpty || _selectedRoomId == null) {
            _showSnackBar("Nama, No WA, dan Alokasi Kamar wajib diisi!", _errorColor);
            return;
        }

        setState(() => _isLoading = true);

        final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
        final String? tenantId = dbRef.child('users_data/$_currentUid/tenants').push().key;

        if (tenantId == null) {
            setState(() => _isLoading = false);
            return;
        }

        final String formatTanggalMasuk = DateTime.now().toString().split(' ')[0];

        final Map<String, dynamic> transaksionalPayload = {
            'users_data/$_currentUid/tenants/$tenantId': {
                'tenant_id': tenantId,
                'tenant_name': nama,
                'tenant_phone': phone,
                'emergency_contact_name': familyName,
                'emergency_contact_phone': familyPhone,
                'room_id': _selectedRoomId,
                'room_name': _selectedRoomName,
                'join_date': formatTanggalMasuk,
                'tenant_address': alamat.isEmpty ? '-' : alamat,
            },
            'users_data/$_currentUid/rooms/$_selectedRoomId/availability_status': 'occupied',
            'users_data/$_currentUid/rooms/$_selectedRoomId/tenant_name': nama,
            'users_data/$_currentUid/rooms/$_selectedRoomId/tenant_phone': phone,
            'users_data/$_currentUid/rooms/$_selectedRoomId/tenant_address': alamat.isEmpty ? '-' : alamat,
            'users_data/$_currentUid/rooms/$_selectedRoomId/start_date': formatTanggalMasuk,
        };

        try {
            await dbRef.update(transaksionalPayload);
            _showSnackBar("👥 Penghuni baru berhasil diregistrasikan ke $_selectedRoomName!", _tealPrimary);
            
            _etNama.clear();
            _etPhone.clear();
            _etFamilyName.clear();
            _etFamilyPhone.clear();
            _etAddress.clear();
            _selectedRoomId = null;
            _selectedRoomName = null;

            setState(() => _isInputMode = false);
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
        final Query tenantsQuery = FirebaseDatabase.instance.ref().child('users_data/$_currentUid/tenants');
        final Query roomsQuery = FirebaseDatabase.instance.ref().child('users_data/$_currentUid/rooms');

        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1), 
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textSlatePrimary),
                    onPressed: () {
                        if (_isInputMode) {
                            setState(() => _isInputMode = false);
                        } else {
                            Navigator.pop(context);
                        }
                    },
                ),
                title: Text(
                    _isInputMode ? "Tambah Penghuni Baru" : "Manajemen Penghuni",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textSlatePrimary),
                ),
                centerTitle: true,
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            ),
            body: StreamBuilder<DatabaseEvent>(
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

                    // Gabungkan data parameter dari detail kamar agar tidak hilang dari dropdown item
                    if (widget.targetRoomId != null && widget.targetRoomName != null) {
                        bool exists = liveAvailableRooms.any((r) => r['room_id'] == widget.targetRoomId);
                        if (!exists) {
                            liveAvailableRooms.insert(0, {
                                'room_id': widget.targetRoomId!,
                                'room_name': widget.targetRoomName!,
                            });
                        }
                    }

                    _currentAvailableRooms = liveAvailableRooms;

                    if (roomsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)));
                    }

                    if (_isInputMode) {
                        return _buildInputFormLayout();
                    }

                    return StreamBuilder<DatabaseEvent>(
                        stream: tenantsQuery.onValue,
                        builder: (context, tenantsSnapshot) {
                            List<Map<String, dynamic>> listPenyewa = [];

                            if (tenantsSnapshot.hasData && tenantsSnapshot.data!.snapshot.value != null) {
                                final Map<dynamic, dynamic> mapPenyewa = tenantsSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                                mapPenyewa.forEach((key, val) {
                                    final item = val as Map<dynamic, dynamic>;
                                    listPenyewa.add({
                                        'id': item['tenant_id'] ?? key.toString(),
                                        'nama': item['tenant_name'] ?? '-',
                                        'phone': item['tenant_phone'] ?? '-',
                                        'room_name': item['room_name'] ?? 'Unit Keluar',
                                        'join_date': item['join_date'] ?? '-',
                                    });
                                });
                                listPenyewa.sort((a, b) => a['nama'].compareTo(b['nama']));
                            }

                            if (tenantsSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)));
                            }

                            if (listPenyewa.isEmpty) {
                                return _buildEmptyStateLayout();
                            }

                            return _buildListPenyewaLayout(listPenyewa);
                        },
                    );
                },
            ),
            floatingActionButton: _isInputMode 
                ? null 
                : FloatingActionButton.extended(
                    onPressed: () => setState(() => _isInputMode = true),
                    backgroundColor: _tealPrimary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                    label: const Text("Tambah Penghuni", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                ),
        );
    }

    Widget _buildListPenyewaLayout(List<Map<String, dynamic>> dataPenyewa) {
        return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            itemCount: dataPenyewa.length,
            itemBuilder: (context, index) {
                final penyewa = dataPenyewa[index];
                return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: _borderSlateLight, width: 1.2),
                    ),
                    child: Row(
                        children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Row(
                                            children: [
                                                Text(penyewa['nama'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                                                const SizedBox(width: 10),
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(8)),
                                                    child: Text(
                                                        'Kamar ${penyewa['room_name']}',
                                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _tealPrimary),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text('WhatsApp: ${penyewa['phone']}', style: TextStyle(fontSize: 14, color: _textSlateMuted, fontWeight: FontWeight.w400)),
                                        const SizedBox(height: 4),
                                        Text('Tanggal Masuk: ${penyewa['join_date']}', style: TextStyle(fontSize: 13, color: _textSlateMuted.withOpacity(0.8), fontWeight: FontWeight.w400)),
                                    ],
                                ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _textSlateMuted.withOpacity(0.5)),
                        ],
                    ),
                );
            },
        );
    }

    Widget _buildEmptyStateLayout() {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
                        alignment: Alignment.center,
                        child: const Text("👥", style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(height: 16),
                    Text("Belum ada data penghuni", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _textSlatePrimary)),
                    const SizedBox(height: 4),
                    Text("Ketuk tombol kanan bawah untuk meregistrasi", style: TextStyle(fontSize: 13, color: _textSlateMuted)),
                ],
            ),
        );
    }

    Widget _buildInputFormLayout() {
        return Column(
            children: [
                Expanded(
                    child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildFieldLabel("Nama Lengkap Sesuai KTP"),
                                _buildFlatInputField(controller: _etNama, hint: "Contoh: Budi Santoso", icon: Icons.person_outline_rounded),
                                
                                _buildFieldLabel("Nomor WhatsApp Aktif"),
                                _buildFlatInputField(controller: _etPhone, hint: "Contoh: 08123456789", icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                                
                                _buildFieldLabel("Alamat Domisili KTP"),
                                _buildFlatInputField(controller: _etAddress, hint: "Masukkan detail alamat kota asal...", icon: Icons.location_on_outlined),

                                _buildFieldLabel("Nama Kontak Darurat / Keluarga"),
                                _buildFlatInputField(controller: _etFamilyName, hint: "Contoh: Siti Aminah (Ibu)", icon: Icons.family_restroom_rounded),
                                
                                _buildFieldLabel("Nomor WA Kontak Darurat"),
                                _buildFlatInputField(controller: _etFamilyPhone, hint: "Contoh: 08129876543", icon: Icons.contact_phone_outlined, keyboardType: TextInputType.phone),
                                
                                _buildFieldLabel("Alokasi Unit Kamar Kosong"),
                                _buildModernDropdownField(),
                            ],
                        ),
                    ),
                ),
                _buildStickySaveButton(),
            ],
        );
    }

    Widget _buildFieldLabel(String label) {
        return Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 8.0, top: 12.0),
            child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _textSlateMuted)),
        );
    }

    Widget _buildFlatInputField({
        required TextEditingController controller,
        required String hint,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
    }) {
        return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: TextStyle(fontSize: 15, color: _textSlatePrimary, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14),
                    prefixIcon: Icon(icon, color: _textSlateMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                ),
            ),
        );
    }

    Widget _buildModernDropdownField() {
        return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: _borderSlateLight, width: 1.2),
            ),
            child: DropdownButtonFormField<String>(
                value: _selectedRoomId,
                hint: Text("Pilih alokasi unit kamar kosong...", style: TextStyle(color: _textSlateMuted.withOpacity(0.5), fontSize: 14)),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSlateMuted),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.meeting_room_outlined, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 15, color: _textSlatePrimary, fontWeight: FontWeight.w400),
                items: _currentAvailableRooms.map((Map<String, dynamic> room) {
                    return DropdownMenuItem<String>(
                        value: room['room_id'],
                        child: Text(room['room_name'].toString().startsWith('Kamar') ? room['room_name'] : 'Kamar ${room['room_name']}'),
                    );
                }).toList(),
                onChanged: (String? value) {
                    setState(() {
                        _selectedRoomId = value;
                        _selectedRoomName = _currentAvailableRooms.firstWhere((r) => r['room_id'] == value)['room_name'];
                    });
                },
            ),
        );
    }

    Widget _buildStickySaveButton() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _borderSlateLight, width: 1)),
            ),
            child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveTenant,
                style: ElevatedButton.styleFrom(
                    backgroundColor: _tealPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("SIMPAN DATA PENGHUNI", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
            ),
        );
    }
}
