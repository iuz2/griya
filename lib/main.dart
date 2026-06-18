import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/kamar_page.dart';
import 'pages/keuangan_page.dart';
import 'pages/lainnya_page.dart';
import 'pages/sub-pages/pembayaran_page.dart'; 
import 'pages/auth/login_page.dart'; 

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyB0dbEGCk58XyJqAOxd6E1hPo55wtDpk00", 
            appId: "1:720608313095:android:1bbcbd15589bcf84098fa2", 
            messagingSenderId: "720608313095", 
            projectId: "docu-merge-c7e70", 
            databaseURL: "https://docu-merge-c7e70-default-rtdb.firebaseio.com", 
            storageBucket: "docu-merge-c7e70.firebasestorage.app",
        ),
    );
    
    runApp(const GriyaApp());
}

class GriyaApp extends StatelessWidget {
    const GriyaApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Griya',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: const Color(0xFF0F766E), 
                scaffoldBackgroundColor: const Color(0xFFECEFF1),
                fontFamily: 'sans-serif',
            ),
            localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
                Locale('id', 'ID'), 
            ],
            home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                            body: Center(
                                child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                            ),
                        );
                    }
                    if (snapshot.hasData) {
                        return const MainScreen(); 
                    }
                    // KOREKSI MUTLAK: Kata kunci const dihapus agar kompilasi sah secara runtime
                    return const LoginPage(); 
                },
            ),
        );
    }
}

class MainScreen extends StatefulWidget {
    const MainScreen({Key? key}) : super(key: key);

    @override
    State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    int _selectedIndex = 0;

    final List<Widget> _pages = [
        const BerandaPage(),
        const KamarPage(),
        const KeuanganPage(),
        const LainnyaPage(),
    ];

    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: IndexedStack(
                index: _selectedIndex,
                children: _pages,
            ),
            bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFCFD8DC), width: 1)),
                ),
                child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    backgroundColor: Colors.white,
                    selectedItemColor: const Color(0xFF0F766E), 
                    unselectedItemColor: const Color(0xFF94A3B8), 
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    selectedFontSize: 15, 
                    unselectedFontSize: 15, 
                    iconSize: 26, 
                    items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.grid_view_rounded),
                            label: 'Beranda',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.door_sliding_outlined),
                            activeIcon: Icon(Icons.door_sliding_rounded),
                            label: 'Kamar',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.account_balance_wallet_outlined),
                            activeIcon: Icon(Icons.account_balance_wallet_rounded),
                            label: 'Keuangan',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.face_outlined),
                            activeIcon: Icon(Icons.face_rounded),
                            label: 'Lainnya',
                        ),
                    ],
                ),
            ),
        );
    }
}

class BerandaPage extends StatefulWidget {
    const BerandaPage({Key? key}) : super(key: key);

    @override
    State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;

    @override
    void initState() {
        super.initState();
        _animationController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 350),
        );
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );
        _animationController.forward();
    }

    @override
    void dispose() {
        _animationController.dispose();
        super.dispose();
    }

    Future<void> _handleRefresh() async {
        _animationController.reset();
        await Future.delayed(const Duration(milliseconds: 200));
        _animationController.forward();
    }

    String _getGreeting() {
        final hour = DateTime.now().hour;
        if (hour < 12) return 'Pagi';
        if (hour < 18) return 'Siang';
        return 'Malam';
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFECEFF1),
            appBar: AppBar(
                backgroundColor: const Color(0xFFECEFF1),
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 16, 
            ),
            body: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xFF0F766E),
                backgroundColor: Colors.white,
                child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 32.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildSimpleHeader(),
                                const SizedBox(height: 24),
                                _buildCardWrapper(child: _buildBigTextIncome()),
                                const SizedBox(height: 16),
                                _buildCardWrapper(child: _buildSimpleProgressOccupancy()),
                                const SizedBox(height: 16),
                                _buildJumboActionButtons(context),
                                const SizedBox(height: 24),
                                _buildCardWrapper(child: _buildCleanActivityLog()),
                            ],
                        ),
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
                border: Border.all(color: const Color(0xFFCFD8DC), width: 1.2),
            ),
            child: child,
        );
    }

    Widget _buildSimpleHeader() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    'Selamat ${_getGreeting()}, Budi',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Color(0xFF0F172A), letterSpacing: -0.4),
                ),
                const SizedBox(height: 4),
                const Text(
                    'Berikut adalah kondisi kos Anda hari ini.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w400),
                ),
            ],
        );
    }

    Widget _buildBigTextIncome() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    'Pemasukan Bulan Ini',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF64748B), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                    'Rp 4.500.000',
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w500, color: const Color(0xFF0F766E), letterSpacing: -1.0),
                ),
                const SizedBox(height: 6),
                const Text(
                    '↑ Naik 15% dari bulan lalu',
                    style: TextStyle(fontSize: 15, color: Color(0xFF0F766E), fontWeight: FontWeight.w500),
                ),
            ],
        );
    }

    Widget _buildSimpleProgressOccupancy() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                        Text(
                            'Kamar Terisi (80%)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF0F172A)),
                        ),
                        Text(
                            '12 / 15 Unit',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF0F766E)),
                        ),
                    ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                        minHeight: 10, 
                    ),
                ),
                const SizedBox(height: 10),
                const Text(
                    'Tersisa 3 unit kamar kosong yang siap disewakan.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w400),
                ),
            ],
        );
    }

    Widget _buildJumboActionButtons(BuildContext context) {
        return Row(
            children: [
                Expanded(child: _buildLargeActionTile(Icons.add_box_rounded, 'Catat Kas', const Color(0xFF0F766E), () {
                    // Terkunci aman
                })),
                const SizedBox(width: 14),
                Expanded(child: _buildLargeActionTile(Icons.check_circle_rounded, 'Verifikasi', const Color(0xFF1E293B), () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PembayaranPage()),
                    );
                })),
            ],
        );
    }

    Widget _buildLargeActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
        return ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(icon, size: 22, color: Colors.white),
                    const SizedBox(width: 10),
                    Flexible(
                        child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.3),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildCleanActivityLog() {
        final List<Map<String, String>> logs = [
            {'unit': 'Kamar 101', 'action': 'Pembayaran sewa lunas', 'time': '15:30', 'val': '+Rp 450.000'},
            {'unit': 'Kamar 105', 'action': 'Tagihan baru dibuat', 'time': '14:00', 'val': 'Rp 400.000'},
            {'unit': 'Kamar 103', 'action': 'Pembayaran sewa lunas', 'time': 'Kemarin', 'val': '+Rp 450.000'},
        ];

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => const Divider(height: 28, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                        final item = logs[index];
                        final isPlus = item['val']!.startsWith('+');
                        return Row(
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                item['unit']!,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF0F172A)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                '${item['action']} • ${item['time']}',
                                                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w400),
                                            ),
                                        ],
                                    ),
                                ),
                                Text(
                                    item['val']!,
                                    style: TextStyle(
                                        fontSize: 16, 
                                        fontWeight: FontWeight.w500, 
                                        color: isPlus ? const Color(0xFF0F766E) : const Color(0xFF0F172A),
                                    ),
                                ),
                            ],
                        );
                    },
                ),
            ],
        );
    }
}
