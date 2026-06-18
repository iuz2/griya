import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'detail_penyewa_page.dart';
import 'catat_pembayaran_page.dart';

class DetailKamarPage extends StatelessWidget {
    final Map<String, dynamic> kamar;

    const DetailKamarPage({
        Key? key,
        required this.kamar,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        // Konsistensi Skema Warna Mutlak V4 Modern Teal
        const Color tealPrimary = Color(0xFF0F766E);
        const Color textSlatePrimary = Color(0xFF0F172A);
        const Color textSlateMuted = Color(0xFF64748B);
        const Color borderSlateLight = Color(0xFFCFD8DC);

        final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final String roomId = (kamar['room_id'] ?? '').toString();

        // Jalur referensi database murni sesuai struktur ekspor RTDB Anda
        final DatabaseReference roomRef = FirebaseDatabase.instance
            .ref()
            .child('users_data/$currentUid/rooms/$roomId');

        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1), 
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                iconTheme: const IconThemeData(color: textSlatePrimary),
                title: const Text(
                    'Detail Unit Kamar',
                    style: TextStyle(color: textSlatePrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
            ),
            body: StreamBuilder<DatabaseEvent>(
                stream: roomRef.onValue,
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: tealPrimary));
                    }

                    // Ambil blueprint dari database server jika tersedia, gunakan data lemparan sebagai fallback
                    Map<dynamic, dynamic> dbData = {};
                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                        dbData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    }

                    // Parsing Variabel Riil Sinkron Database Anda
                    final String nomorKamar = (dbData['room_name'] ?? kamar['nomor_kamar'] ?? '-').toString();
                    final String roomType = (dbData['room_type'] ?? kamar['room_type'] ?? 'Standard').toString();
                    final int hargaRaw = dbData['price'] ?? kamar['harga_sewa'] ?? 0;
                    final String availability = (dbData['availability_status'] ?? '').toString();
                    final bool hasPending = dbData['has_pending'] ?? false;

                    // Konversi Status Lokalisasi Visual V4
                    String statusKamar = 'Kosong';
                    if (availability == 'occupied') {
                        statusKamar = hasPending ? 'Belum Bayar' : 'Terisi';
                    }

                    // Data Dinamis Opsional (Sesuai ketersediaan mapping node penyewa Anda nanti)
                    final String namaPenghuni = availability == 'occupied' ? (dbData['tenant_name'] ?? 'Penyewa Aktif').toString() : 'Belum Ada Penghuni';
                    final String telepon = (dbData['tenant_phone'] ?? '-').toString();
                    final String alamat = (dbData['tenant_address'] ?? '-').toString();
                    final String tanggalMasuk = (dbData['start_date'] ?? '-').toString();
                    final String jatuhTempo = (dbData['due_date'] ?? '15 tiap bulan').toString();
                    final String statusPembayaran = hasPending ? 'Belum Lunas' : (availability == 'occupied' ? 'Lunas' : '-');
                    final String totalTunggakan = hasPending ? 'Rp ${dbData['pending_amount'] ?? hargaRaw}' : '0';
                    final String catatan = (dbData['notes'] ?? 'Tidak ada catatan tambahan.').toString();

                    final bool isTerisi = availability == 'occupied';
                    final bool isLunas = statusPembayaran.toLowerCase() == 'lunas';

                    final Map<String, dynamic> dummyPenyewaData = {
                        'room_id': roomId,
                        'nama': namaPenghuni,
                        'whatsapp': telepon != '-' ? telepon : '',
                        'nama_pj': 'Keluarga $namaPenghuni',
                        'whatsapp_pj': '',
                        'kamar': 'Kamar $nomorKamar',
                        'has_foto': true,
                    };

                    return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20.0), 
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // 1. CARD UTAMA: STATUS UNIT & INFORMASI KEUANGAN SEWA
                                _buildCardWrapper(
                                    borderSlateLight,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Text('Kamar $nomorKamar', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: textSlatePrimary)),
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        decoration: BoxDecoration(
                                                            color: isTerisi ? (hasPending ? const Color(0xFFFEE2E2) : const Color(0xFFCCFBF1)) : const Color(0xFFF1F5F9),
                                                            borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                            statusKamar,
                                                            style: TextStyle(
                                                                fontSize: 12, 
                                                                fontWeight: FontWeight.bold, 
                                                                color: isTerisi ? (hasPending ? const Color(0xFF991B1B) : const Color(0xFF115E59)) : textSlateMuted,
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text('$namaPenghuni • Tipe $roomType', style: const TextStyle(fontSize: 16, color: textSlateMuted, fontWeight: FontWeight.w400)),
                                            const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                            ),
                                            _buildDataRowItem("Harga Sewa", 'Rp $hargaRaw / bulan', tealPrimary),
                                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                            _buildDataRowItem("Tanggal Masuk", tanggalMasuk, textSlatePrimary),
                                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                            _buildDataRowItem("Siklus Jatuh Tempo", jatuhTempo, textSlatePrimary),
                                            const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                            _buildDataRowItem("Status Invoice", statusPembayaran, isLunas ? tealPrimary : const Color(0xFF991B1B)),
                                            if (hasPending) ...[
                                                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                                _buildDataRowItem("Total Tunggakan", totalTunggakan, const Color(0xFF991B1B)),
                                            ],
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 16),

                                // 2. CARD PENGATURAN & AKSI HUB
                                if (isTerisi) ...[
                                    _buildCardWrapper(
                                        borderSlateLight,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const Text('Manajemen Penghuni', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textSlatePrimary)),
                                                const SizedBox(height: 12),
                                                _buildMenuRowItem("Lihat Berkas Detail Penyewa", Icons.account_circle_outlined, () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPenyewaPage(isEditMode: false, isReadOnly: true, penyewa: dummyPenyewaData)));
                                                }),
                                                _buildMenuRowItem("Proses Ganti / Alih Penghuni", Icons.published_with_changes_rounded, () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPenyewaPage(isEditMode: true, isReadOnly: false, penyewa: dummyPenyewaData)));
                                                }),
                                                if (telepon != '-') _buildMenuRowItem("Hubungi Penghuni (WhatsApp)", Icons.chat_bubble_outline_rounded, () {}),
                                            ],
                                        ),
                                    ),
                                    const SizedBox(height: 16),
                                ],

                                // 3. CARD DATA PENGHUNI & ASAL
                                if (isTerisi) ...[
                                    _buildCardWrapper(
                                        borderSlateLight,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const Text('Biodata Alamat Asal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textSlatePrimary)),
                                                const SizedBox(height: 14),
                                                _buildDataRowItem("Nomor Telepon", telepon, textSlatePrimary),
                                                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                                _buildDataRowItem("Alamat KTP Asal", alamat, textSlatePrimary),
                                            ],
                                        ),
                                    ),
                                    const SizedBox(height: 16),
                                ],

                                // 4. CARD CATATAN INTERNAL
                                _buildCardWrapper(
                                    borderSlateLight,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text('Catatan Internal Kos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textSlatePrimary)),
                                            const SizedBox(height: 8),
                                            Text(catatan, style: const TextStyle(fontSize: 14, color: textSlateMuted, height: 1.4, fontWeight: FontWeight.w300)),
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 24),

                                // 5. TOMBOL UTAMA ELEGAN MELEKAT DI BAWAH
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: () {
                                            if (isTerisi) {
                                                // Paket gabungan data murni server & fallback data lemparan internal
                                                final Map<String, dynamic> paketLembaranKamar = {
                                                    'room_id': roomId,
                                                    'room_name': nomorKamar,
                                                    'tenant_name': namaPenghuni,
                                                    'price': hargaRaw,
                                                    'pending_amount': dbData['pending_amount'] ?? (hasPending ? hargaRaw : 0),
                                                };
                                                
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => CatatPembayaranPage(kamar: paketLembaranKamar),
                                                    ),
                                                );
                                            } else {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPenyewaPage(isEditMode: false, isReadOnly: false, penyewa: {'kamar': 'Kamar $nomorKamar', 'room_id': roomId})));
                                            }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: tealPrimary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 18), 
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        child: Text(
                                            isTerisi ? 'Catat Pembayaran Kas' : 'Daftarkan Penyewa Baru',
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500), 
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 24),
                            ],
                        ),
                    );
                },
            ),
        );
    }

    Widget _buildCardWrapper(Color borderColor, {required Widget child}) {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0), 
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0), 
                border: Border.all(color: borderColor, width: 1.2),
            ),
            child: child,
        );
    }

    Widget _buildDataRowItem(String title, String value, Color valueColor) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w400)),
                Flexible(
                    child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: valueColor), 
                    ),
                ),
            ],
        );
    }

    Widget _buildMenuRowItem(String title, IconData icon, VoidCallback onTap) {
        return ListTile(
            onTap: onTap,
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: const Color(0xFF0F766E), size: 20),
            title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF1E293B))),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
        );
    }
}
