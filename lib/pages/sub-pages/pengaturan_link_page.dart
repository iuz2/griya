import 'package:flutter/material.dart';

class PengaturanLinkPage extends StatelessWidget {
    const PengaturanLinkPage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC), // Slate 50 bersih
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
                    onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                    "Link Pembayaran PRO",
                    style: TextStyle(
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
            body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    children: [
                        _buildQRCodeCard(),
                        const SizedBox(height: 20),
                        _buildActionButtons(context),
                        const SizedBox(height: 28),
                        _buildMinimalistTipsCard(),
                    ],
                ),
            ),
        );
    }

    // =========================================================================
    // 1. KOTAK KONTEN QR CODE & DISPLAY LINK TAUTAN (FLAT MINIMALIS)
    // =========================================================================
    Widget _buildQRCodeCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
                children: [
                    const Text(
                        "QR Code Pembayaran",
                        style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1E293B)
                        ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Kontainer QR Placeholder Bersih (Emerald Soft Frame)
                    Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                            "📸\n[ QR Code Placeholder ]\n(Firebase Link Generator)",
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            textAlign: TextAlign.center,
                        ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Box Tampilan Text Link Web Publik Netlify Anda
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9), // Slate 100
                            borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                            children: const [
                                Icon(Icons.link_rounded, color: Color(0xFF64748B), size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        "https://griya-bayar.netlify.app/?owner=twilight",
                                        style: TextStyle(
                                            fontSize: 12, 
                                            color: Color(0xFF475569),
                                            fontFamily: 'Courier', // Gaya font tautan
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    // =========================================================================
    // 2. GRID ACTION BUTTONS (SIMPAN & BAGIKAN)
    // =========================================================================
    Widget _buildActionButtons(BuildContext context) {
        return Row(
            children: [
                // Tombol Simpan Gambar QR ke Galeri HP
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                            // Logika ekspor widget gambar ke storage lokal HP nanti ditaruh disini
                        },
                        icon: const Icon(Icons.file_download_outlined, size: 18),
                        label: const Text("SIMPAN QR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0FDF4), // Emerald super soft tint
                            foregroundColor: const Color(0xFF059669), // Emerald Hijau
                            elevation: 0,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                                side: const BorderSide(color: Color(0xFFA7F3D0), width: 1),
                            ),
                        ),
                    ),
                ),
                const SizedBox(width: 16),
                
                // Tombol Share Teks Link Tautan ke WhatsApp Penyewa
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                            // Jalankan library Share intent bawaan OS
                        },
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text("BAGIKAN LINK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A), // Hitam minimalis elegan
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                    ),
                ),
            ],
        );
    }

    // =========================================================================
    // 3. INFORMASI BOX TIPS PENGGUNAAN (MODERN SOFT EMERALD)
    // =========================================================================
    Widget _buildMinimalistTipsCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4), // Emerald Soft Green Background
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: const [
                            Text("💡", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                                "Tips Penggunaan:",
                                style: TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.bold, 
                                    color: Color(0xFF065F46)
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipsRow("1.", "Simpan QR Code ke galeri lalu cetak dan tempel di area mading atau pintu kamar kos."),
                    const SizedBox(height: 8),
                    _buildTipsRow("2.", "Bagikan link langsung ke WhatsApp penyewa untuk konfirmasi tagihan cepat tanpa manual."),
                ],
            ),
        );
    }

    Widget _buildTipsRow(String number, String text) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    "$number ",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                ),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(
                        text,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF065F46), height: 1.4),
                    ),
                ),
            ],
        );
    }
}
