import 'package:flutter/material.dart';

class PengaturanPenyewaPage extends StatefulWidget {
    const PengaturanPenyewaPage({Key? key}) : super(key: key);

    @override
    State<PengaturanPenyewaPage> createState() => _PengaturanPenyewaPageState();
}

class _PengaturanPenyewaPageState extends State<PengaturanPenyewaPage> {
    bool _isInputMode = false; // Switcher antara mode daftar penyewa vs input form

    // Controller Form Penyewa Utama
    final TextEditingController _etNama = TextEditingController();
    final TextEditingController _etPhone = TextEditingController();
    final TextEditingController _etFamilyName = TextEditingController();
    final TextEditingController _etFamilyPhone = TextEditingController();

    // State Alokasi Kamar (Dropdown)
    String? _selectedRoom;
    // Mock Data List Kamar (Nanti dihubungkan otomatis ke Firebase real-time stream Anda)
    final List<String> _availableRooms = ["Kamar A1", "Kamar A2", "Kamar 101", "Kamar 102"];

    @override
    void dispose() {
        _etNama.dispose();
        _etPhone.dispose();
        _etFamilyName.dispose();
        _etFamilyPhone.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC), // Latar Slate 50 bersih
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
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
                    style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF0F172A)
                    ),
                ),
                centerTitle: true,
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            ),
            body: _isInputMode ? _buildInputFormLayout() : _buildListPenyewaLayout(),
            floatingActionButton: _isInputMode 
                ? null 
                : FloatingActionButton.extended(
                    onPressed: () => setState(() => _isInputMode = true),
                    backgroundColor: const Color(0xFF0F172A), // Hitam elegan senada
                    foregroundColor: Colors.white,
                    elevation: 2,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text("Tambah Penghuni", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
        );
    }

    // =========================================================================
    // LAYOUT 1: DAFTAR PENGHUNI (LIST MODE)
    // =========================================================================
    Widget _buildListPenyewaLayout() {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), // Latar Blue soft
                            borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Text("👥", style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        "Belum ada data penghuni",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                        "Ketuk tombol kanan bawah untuk meregistrasi",
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                ],
            ),
        );
    }

    // =========================================================================
    // LAYOUT 2: FORM REGISTRASI INPUT PENYEWA
    // =========================================================================
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
                                _buildFieldLabel("Nama Lengkap"),
                                _buildFlatInputField(controller: _etNama, hint: "Contoh: Budi Santoso", icon: Icons.person_outline_rounded),
                                
                                _buildFieldLabel("Nomor WhatsApp"),
                                _buildFlatInputField(controller: _etPhone, hint: "Contoh: 08123456789", icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                                
                                _buildFieldLabel("Nama Keluarga / Penanggung Jawab"),
                                _buildFlatInputField(controller: _etFamilyName, hint: "Contoh: Siti Aminah (Ibu)", icon: Icons.family_restroom_rounded),
                                
                                _buildFieldLabel("Nomor WA Keluarga"),
                                _buildFlatInputField(controller: _etFamilyPhone, hint: "Contoh: 08129876543", icon: Icons.contact_phone_outlined, keyboardType: TextInputType.phone),
                                
                                _buildFieldLabel("Alokasi Kamar"),
                                _buildModernDropdownField(),
                                
                                _buildFieldLabel("Foto Identitas / KTP (Opsional)"),
                                _buildModernPhotoUploader(),
                                const SizedBox(height: 24),
                            ],
                        ),
                    ),
                ),
                _buildStickySaveButton(),
            ],
        );
    }

    // KOMPONEN PEMBANTU 1: LABEL TEXT
    Widget _buildFieldLabel(String label) {
        return Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 12.0),
            child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
        );
    }

    // KOMPONEN PEMBANTU 2: TEXT INPUT FLAT MODERN (Aman dari Bug EdgeInsets)
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
                border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                ),
            ),
        );
    }

    // KOMPONEN PEMBANTU 3: DROPDOWN KAMAR MODERN MATERIAL 3
    Widget _buildModernDropdownField() {
        return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonFormField<String>(
                value: _selectedRoom,
                hint: const Text("Pilih alokasi unit kamar...", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.meeting_room_outlined, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                items: _availableRooms.map((String room) {
                    return DropdownMenuItem<String>(
                        value: room,
                        child: Text(room),
                    );
                }).toList(),
                onChanged: (String? value) {
                    setState(() {
                        _selectedRoom = value;
                    });
                },
            ),
        );
    }

    // KOMPONEN PEMBANTU 4: BOX UPLOAD KTP FLAT MODERN
    Widget _buildModernPhotoUploader() {
        return InkWell(
            onTap: () {
                // Alur pemicu ImagePicker galeri/kamera ditaruh disini nanti
            },
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5, style: BorderStyle.solid), // Flat border tipis bersih
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                        Icon(Icons.add_photo_alternate_outlined, size: 36, color: Color(0xFF059669)), // Warna aksen Emerald
                        SizedBox(height: 8),
                        Text(
                            "Unggah Foto KTP / Identitas",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        SizedBox(height: 4),
                        Text(
                            "Format JPG, PNG maksimal 5MB",
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                    ],
                ),
            ),
        );
    }

    // KOMPONEN PEMBANTU 5: STICKY SAVE BUTTON
    Widget _buildStickySaveButton() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: ElevatedButton(
                onPressed: () {
                    // Logika push set data map penyewa ke Firebase
                    setState(() => _isInputMode = false);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669), // Emerald Hijau
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                ),
                child: const Text("SIMPAN DATA PENGHUNI", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
        );
    }
}
