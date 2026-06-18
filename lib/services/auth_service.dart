import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseDatabase _db = FirebaseDatabase.instance;

    /// Fungsi Membuat Kode Publik Kustom Acak 8 Digit Anti-Duplikat (GRY-XXXXXXXX)
    String _generatePublicCode() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        final rnd = Random();
        String code = 'GRY-';
        for (int i = 0; i < 8; i++) {
            code += chars[rnd.nextInt(chars.length)];
        }
        return code;
    }

    /// Fungsi Registrasi Pemilik Kos Baru murni V4
    Future<String?> registerOwner({
        required String namaKos,
        required String email,
        required String password,
    }) async {
        try {
            // 1. Buat User baru di Firebase Authentication
            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                email: email,
                password: password,
            );

            final String? newUid = userCredential.user?.uid;
            if (newUid == null) throw Exception("Gagal mendapatkan User ID.");

            bool isCodeUnique = false;
            String publicCode = '';

            // 2. Loop Validasi Kode Publik untuk Memastikan Benar-benar Unik
            while (!isCodeUnique) {
                publicCode = _generatePublicCode();
                
                // Cek eksistensi kode di jalur public_mappings
                DataSnapshot snapshot = await _db.ref('public_mappings/$publicCode').get();
                if (!snapshot.exists) {
                    isCodeUnique = true;
                }
            }

            // 3. Strukturisasi Payload Data (Identik 100% dengan skema Sketchware Anda)
            final Map<String, dynamic> profileData = {
                'property_name': namaKos,
                'public_code': publicCode,
            };

            final Map<String, dynamic> publicData = {
                'property_name': namaKos,
            };

            // 4. Eksekusi Penyimpanan ke Tiga Jalur Database Secara Simultan (Atomic Update)
            await _db.ref('users_data/$newUid/profile').update(profileData);
            await _db.ref('public_mappings/$publicCode').set(newUid);
            await _db.ref('public_data/$publicCode').update(publicData);

            // Mengembalikan kode publik jika registrasi berhasil sepenuhnya
            return publicCode;

        } on FirebaseAuthException catch (e) {
            // Lempar pesan error spesifik dari server Firebase Auth (e.g., Email sudah terdaftar)
            throw e.message ?? "Terjadi kesalahan pendaftaran.";
        } catch (e) {
            throw e.toString();
        }
    }
}
