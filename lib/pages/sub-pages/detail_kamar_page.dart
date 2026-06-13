import 'package:flutter/material.dart';
import 'detail_penyewa_page.dart';

class DetailKamarPage extends StatelessWidget {
    final Map<String, dynamic> kamar;

    const DetailKamarPage({
        Key? key,
        required this.kamar,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        // Skema Warna Sesuai Panduan Bahasa Desain Griya
        const Color primaryColor = Color(0xFF1976D2);
        const Color secondaryColor = Color(0xFF455A64);
        const Color backgroundColor = Color(0xFFF8F9FA);
        const Color cardColor = Colors.white;
        const Color borderTextColor = Color(0xFFE0E0E0);
        
        // Parsing Data Dinamis dari Map dengan Fallback / Default Value
        final String nomorKamar = (kamar['nomor_kamar'] ?? '-').toString();
        final String statusKamar = (kamar['status'] ?? 'Tersedia').toString();
        final String namaPenghuni = (kamar['nama_penghuni'] ?? 'Belum Ada Penghuni').toString();
        final String telepon = (kamar['telepon'] ?? '-').toString();
        final String alamat = (kamar['alamat'] ?? '-').toString();
        final String hargaSewa = (kamar['harga_sewa'] ?? '-').toString();
        final String tanggalMasuk = (kamar['tanggal_masuk'] ?? '-').toString();
        final String jatuhTempo = (kamar['jatuh_tempo'] ?? '-').toString();
        final String statusPembayaran = (kamar['status_pembayaran'] ?? '-').toString();
        final String totalTunggakan = (kamar['total_tunggakan'] ?? '0').toString();
        final String catatan = (kamar['catatan'] ?? 'Tidak ada catatan tambahan.').toString();

        // Evaluasi Warna Badge Status Kamar
        final bool isTerisi = statusKamar.toLowerCase() == 'terisi' || statusKamar.toLowerCase() == 'belum bayar';
        final Color statusBadgeColor = isTerisi ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);
        final Color statusTextColor = isTerisi ? primaryColor : const Color(0xFF2E7D32);

        // Evaluasi Warna Badge Status Pembayaran
        final bool isLunas = statusPembayaran.toLowerCase() == 'lunas';
        final Color bayarBadgeColor = isLunas ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
        final Color bayarTextColor = isLunas ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

        // Dummy Data untuk dikirim ke halaman DetailPenyewaPage
        final Map<String, dynamic> dummyPenyewaData = {
            'nama': namaPenghuni,
            'whatsapp': telepon != '-' ? telepon : '',
            'nama_pj': 'Keluarga $namaPenghuni',
            'whatsapp_pj': '',
            'kamar': 'Kamar $nomorKamar',
            'has_foto': true,
        };

        return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
                backgroundColor: cardColor,
                elevation: 0,
                iconTheme: const IconThemeData(color: Color(0xFF212121)),
                title: const Text(
                    'Detail Kamar',
                    style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.edit_outlined, color: primaryColor),
                        tooltip: 'Edit Kamar',
                        onPressed: () {},
                    ),
                ],
                shape: const Border(
                    bottom: BorderSide(color: borderTextColor, width: 1),
                ),
            ),
            body: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, child) {
                    return Opacity(
                        opacity: value,
                        child: Transform.translate(
                            offset: Offset(0, 10 * (1 - value)),
                            child: child,
                        ),
                    );
                },
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            // ========================================== SUMMARY CARD (HERO-LIKE)
                            Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderTextColor, width: 1),
                                ),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                        Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.meeting_room_rounded, color: primaryColor, size: 28),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(
                                                        'Kamar $nomorKamar',
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF212121),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                        namaPenghuni,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w500,
                                                            color: isTerisi ? const Color(0xFF212121) : secondaryColor,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                                color: statusBadgeColor,
                                                borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                                statusKamar,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusTextColor,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // ========================================== INFORMASI SEWA & PEMBAYARAN
                            _buildSectionHeader('Informasi Sewa'),
                            Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderTextColor, width: 1),
                                ),
                                child: Column(
                                    children: [
                                        _buildDetailRow('Harga Sewa', hargaSewa, isBoldValue: true, valueColor: primaryColor),
                                        _buildDivider(),
                                        _buildDetailRow('Tanggal Masuk', tanggalMasuk),
                                        _buildDivider(),
                                        _buildDetailRow('Jatuh Tempo', jatuhTempo),
                                        _buildDivider(),
                                        _buildDetailRow(
                                            'Status Pembayaran', 
                                            statusPembayaran,
                                            customValueWidget: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: bayarBadgeColor,
                                                    borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                    statusPembayaran,
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: bayarTextColor),
                                                ),
                                            )
                                        ),
                                        if (!isLunas && totalTunggakan != '0') ...[
                                            _buildDivider(),
                                            _buildDetailRow('Total Tunggakan', totalTunggakan, valueColor: bayarTextColor, isBoldValue: true),
                                        ],
                                    ],
                                ),
                            ),

                            const SizedBox(height: 16),

                            // ========================================== INFORMASI PENGHUNI
                            if (isTerisi) ...[
                                _buildSectionHeader('Informasi Penghuni'),
                                Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderTextColor, width: 1),
                                    ),
                                    child: Column(
                                        children: [
                                            _buildDetailRow('Nama Penghuni', namaPenghuni),
                                            _buildDivider(),
                                            _buildDetailRow('Nomor HP', telepon),
                                            _buildDivider(),
                                            _buildDetailRow('Alamat Asal', alamat),
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 16),
                            ],

                            // ========================================== CATATAN TAMBAHAN
                            _buildSectionHeader('Catatan Internal'),
                            Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderTextColor, width: 1),
                                ),
                                child: Text(
                                    catatan,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF424242),
                                        height: 1.5,
                                    ),
                                ),
                            ),

                            const SizedBox(height: 32),

                            // ========================================== TOMBOL AKSI UTAMA
                            if (isTerisi) ...[
                                ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.receipt_long_rounded, size: 20),
                                    label: const Text('Catat Pembayaran Sewa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                    children: [
                                        Expanded(
                                            child: OutlinedButton.icon(
                                                onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => DetailPenyewaPage(
                                                                isEditMode: false,
                                                                isReadOnly: true,
                                                                penyewa: dummyPenyewaData,
                                                            ),
                                                        ),
                                                    );
                                                },
                                                icon: const Icon(Icons.account_circle_outlined, size: 20),
                                                label: const Text('Detail Penyewa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                                style: OutlinedButton.styleFrom(
                                                    foregroundColor: primaryColor,
                                                    side: const BorderSide(color: primaryColor, width: 1),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    backgroundColor: cardColor,
                                                ),
                                            ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: OutlinedButton.icon(
                                                onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => DetailPenyewaPage(
                                                                isEditMode: true,
                                                                isReadOnly: false,
                                                                penyewa: dummyPenyewaData,
                                                            ),
                                                        ),
                                                    );
                                                },
                                                icon: const Icon(Icons.published_with_changes_rounded, size: 20),
                                                label: const Text('Ganti Penyewa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                                style: OutlinedButton.styleFrom(
                                                    foregroundColor: secondaryColor,
                                                    side: const BorderSide(color: borderTextColor, width: 1),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    backgroundColor: cardColor,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                                if (telepon != '-') ...[
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                                        label: const Text('Hubungi Penghuni', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: secondaryColor,
                                            side: const BorderSide(color: borderTextColor, width: 1),
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            backgroundColor: cardColor,
                                        ),
                                    ),
                                ],
                            ] else ...[
                                ElevatedButton.icon(
                                    onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DetailPenyewaPage(
                                                    isEditMode: false,
                                                    isReadOnly: false,
                                                    penyewa: {
                                                        'kamar': 'Kamar $nomorKamar',
                                                    },
                                                ),
                                            ),
                                        );
                                    },
                                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                                    label: const Text('Tambah Penyewa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xff059669),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                ),
                            ],
                            const SizedBox(height: 24),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildSectionHeader(String title) {
        return Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455A64),
                    letterSpacing: 0.2,
                ),
            ),
        );
    }

    Widget _buildDetailRow(String label, String value, {bool isBoldValue = false, Color? valueColor, Widget? customValueWidget}) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Expanded(
                        flex: 4,
                        child: Text(
                            label,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                        ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 6,
                        child: customValueWidget ?? Text(
                            value,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
                                color: valueColor ?? const Color(0xFF212121),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildDivider() {
        return const Divider(
            color: Color(0xFFECEFF1),
            thickness: 1,
            height: 16,
        );
    }
}
