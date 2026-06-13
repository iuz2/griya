import 'package:flutter/material.dart';

class PengaturanGatewayPage extends StatefulWidget {
    const PengaturanGatewayPage({Key? key}) : super(key: key);

    @override
    State<PengaturanGatewayPage> createState() => _PengaturanGatewayPageState();
}

class _PengaturanGatewayPageState extends State<PengaturanGatewayPage> {
    bool _isGatewayActive = false; // State untuk sakelar otomatisasi Midtrans
    bool _isServerKeyObscured = true; // State pengontrol intip Server Key

    // Controller Input Kredensial API
    final TextEditingController _etMerchantId = TextEditingController();
    final TextEditingController _etClientKey = TextEditingController();
    final TextEditingController _etServerKey = TextEditingController();

    @override
    void dispose() {
        _etMerchantId.dispose();
        _etClientKey.dispose();
        _etServerKey.dispose();
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
                    onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                    "Payment Gateway",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
                        _buildSwitchGatewayCard(),
                        const SizedBox(height: 16),
                        _buildCredentialsFormCard(),
                    ],
                ),
            ),
        );
    }

    // =========================================================================
    // 1. SAKELAR AKTIVASI GERBANG OTOMATIS (SWITCH CARD)
    // =========================================================================
    Widget _buildSwitchGatewayCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            const Text(
                                "Aktifkan Pembayaran Otomatis",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Switch.adaptive(
                                value: _isGatewayActive,
                                activeColor: const Color(0xFF059669), // Emerald
                                onChanged: (bool value) {
                                    setState(() {
                                        _isGatewayActive = value;
                                    });
                                },
                            ),
                        ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        "Jika aktif, tenant akan diarahkan membayar melalui gateway Midtrans (QRIS/VA) tanpa perlu unggah bukti transfer manual ke aplikasi.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                    ),
                ],
            ),
        );
    }

    // =========================================================================
    // 2. FORM KREDENSIAL API MIDTRANS
    // =========================================================================
    Widget _buildCredentialsFormCard() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        "Kredensial API Midtrans",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFieldLabel("MERCHANT ID"),
                    _buildFlatInputField(controller: _etMerchantId, hint: "Masukkan Merchant ID", icon: Icons.badge_outlined),
                    
                    _buildFieldLabel("CLIENT KEY"),
                    _buildFlatInputField(controller: _etClientKey, hint: "SB-Mid-client-...", icon: Icons.vpn_key_outlined),
                    
                    _buildFieldLabel("SERVER KEY"),
                    _buildServerKeyInputField(),
                    const SizedBox(height: 1
