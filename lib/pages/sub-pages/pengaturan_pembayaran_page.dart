import 'package:flutter/material.dart';

class PengaturanPembayaranPage extends StatefulWidget {
    const PengaturanPembayaranPage({Key? key}) : super(key: key);

    @override
    State<PengaturanPembayaranPage> createState() => _PengaturanPembayaranPageState();
}

class _PengaturanPembayaranPageState extends State<PengaturanPembayaranPage> {
    final TextEditingController _etPeriode = TextEditingController();
    final TextEditingController _etNominal = TextEditingController();

    String? _selectedPenghuni;
    String? _selectedMetode;

    final List<String> _listPenghuni = ["Budi Santoso (Kamar A1)", "Siti Aminah (Kamar 102)", "Andi Wijaya (Kamar VIP-2)"];
    final List<String> _listMetode = ["Tunai / Cash", "Transfer Bank Manual", "QRIS / Dompet Digital"];

    @override
    void dispose() {
        _etPeriode.dispose();
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
                        colorScheme: const ColorScheme.light(
                            primary: Color(0xFF059669),
                            onPrimary: Colors.white,
                            onSurface: Color(0xFF0F172A),
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

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
                    onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                    "Pencatatan Pembayaran",
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
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _buildFormCard(context),
                        _buildHistorySection(),
                    ],
                ),
            ),
        );
    }

    Widget _buildFormCard(BuildContext context) {
        return Container(
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    _buildFieldLabel("Penghuni"),
                    _buildDropdownField(
                        value: _selectedPenghuni,
                        hint: "Pilih nama penghuni...",
                        icon: Icons.person_outline_rounded,
                        items: _listPenghuni,
                        onChanged: (val) => setState(() => _selectedPenghuni = val),
                    ),
                    
                    _buildFieldLabel("Periode Tagihan"),
                    _buildDatePickerField(context),
                    
                    _buildFieldLabel("Nominal Bayar"),
                    _buildNominalField(),
                    
                    _buildFieldLabel("Metode Pembayaran"),
                    _buildDropdownField(
                        value: _selectedMetode,
                        hint: "Pilih metode transaksi...",
                        icon: Icons.account_balance_wallet_outlined,
                        items: _listMetode,
                        onChanged: (val) => setState(() => _selectedMetode = val),
                    ),
                    const SizedBox(height: 12),
                    
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                        child: const Text("SIMPAN PEMBAYARAN", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                ],
            ),
        );
    }

    Widget _buildHistorySection() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        "Riwayat Pembayaran",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 14),
                    
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text("🧾", style: TextStyle(fontSize: 26)),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                    "Belum ada pembayaran",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                    "Data pembayaran penghuni akan muncul di sini",
                                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                    textAlign: TextAlign.center,
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildFieldLabel(String label) {
        return Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 4.0),
            child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
        );
    }

    Widget _buildDropdownField({
        required String? value,
        required String hint,
        required IconData icon,
        required List<String> items,
        required ValueChanged<String?> onChanged,
    }) {
        return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonFormField<String>(
                value: value,
                hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                decoration: InputDecoration(
                    prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                items: items.map((String val) {
                    return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: onChanged,
            ),
        );
    }

    Widget _buildDatePickerField(BuildContext context) {
        return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
                controller: _etPeriode,
                readOnly: true,
                onTap: () => _selectPeriodeDate(context),
                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                    hintText: "Pilih periode pembayaran",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: Icon(Icons.calendar_month_outlined, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                ),
            ),
        );
    }

    Widget _buildNominalField() {
        return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
                controller: _etNominal,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                decoration: const InputDecoration(
                    hintText: "Rp 0",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.normal),
                    prefixIcon: Icon(Icons.payments_outlined, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                ),
            ),
        );
    }
}
