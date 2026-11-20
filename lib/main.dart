import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? baslatmaHatasi;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.setLanguageCode('tr');
  } catch (e) {
    baslatmaHatasi = e.toString();
  }
  runApp(SeymenAuthApp(baslatmaHatasi: baslatmaHatasi));
}

class SeymenAuthApp extends StatelessWidget {
  final String? baslatmaHatasi;
  const SeymenAuthApp({super.key, this.baslatmaHatasi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seymen Auth Sistemi',
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: baslatmaHatasi != null
          ? Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Firebase Baslatma Hatasi:\n' + baslatmaHatasi!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            )
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return const PanelEkrani();
                }
                return const GirisKayitEkrani();
              },
            ),
    );
  }
}

class GirisKayitEkrani extends StatefulWidget {
  const GirisKayitEkrani({super.key});

  @override
  State<GirisKayitEkrani> createState() => _GirisKayitEkraniState();
}

class _GirisKayitEkraniState extends State<GirisKayitEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _epostaController = TextEditingController();
  final _sifreController = TextEditingController();

  bool _girisModu = true;
  bool _yukleniyor = false;
  bool _sifreGizli = true;
  String? _hataMesaji;

  String _turkceHataMesaji(String kod) {
    switch (kod) {
      case 'invalid-email':
        return 'Ge\u00e7ersiz bir e-posta adresi girdiniz.';
      case 'user-not-found':
        return 'Bu e-posta ile kay\u0131tl\u0131 kullan\u0131c\u0131 bulunamad\u0131.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta adresi veya \u015fifre hatal\u0131.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kay\u0131tl\u0131.';
      case 'weak-password':
        return '\u015eifre en az 6 karakter uzunlu\u011funda olmal\u0131d\u0131r.';
      case 'user-disabled':
        return 'Bu kullan\u0131c\u0131 hesab\u0131 devre d\u0131\u015f\u0131 b\u0131rak\u0131lm\u0131\u015f.';
      case 'too-many-requests':
        return '\u00c7ok fazla hatal\u0131 deneme yapt\u0131n\u0131z. L\u00fctfen biraz bekleyin.';
      case 'network-request-failed':
        return '\u0130nternet ba\u011flant\u0131s\u0131 kurulamad\u0131.';
      case 'operation-not-allowed':
        return 'Firebase Console uzerinden Email/Password girisini aktif edin.';
      default:
        return '\u0130\u015flem ba\u015far\u0131s\u0131z (' + kod + '). Tekrar deneyin.';
    }
  }

  Future<void> _formuGonder() async {
    if (!_formKey.currentState!.validate()) return;

    final eposta = _epostaController.text.trim();
    final sifre = _sifreController.text.trim();

    setState(() {
      _yukleniyor = true;
      _hataMesaji = null;
    });

    try {
      if (_girisModu) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: eposta,
          password: sifre,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: eposta,
          password: sifre,
        );
      }
    } on FirebaseAuthException catch (e) {
      final mesaj = _turkceHataMesaji(e.code);
      setState(() => _hataMesaji = mesaj);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mesaj),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _hataMesaji = 'Beklenmeyen hata: ' + e.toString());
    } finally {
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  Future<void> _sifreSifirla() async {
    final eposta = _epostaController.text.trim();
    if (eposta.isEmpty || !eposta.contains('@')) {
      setState(() {
        _hataMesaji = '\u015eifre s\u0131f\u0131rlama ba\u011flant\u0131s\u0131 i\u00e7in ge\u00e7erli bir e-posta yaz\u0131n.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: eposta);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('S\u0131f\u0131rlama ba\u011flant\u0131s\u0131 ' + eposta + ' adresine g\u00f6nderildi.'),
            backgroundColor: Colors.teal.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _hataMesaji = _turkceHataMesaji(e.code));
    }
  }

  @override
  void dispose() {
    _epostaController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade700, Colors.teal.shade400],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _girisModu ? Icons.shield_outlined : Icons.person_add_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _girisModu ? 'Seymen - Giri\u015f Paneli' : 'Seymen - Yeni Kay\u0131t',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _epostaController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-posta Adresi',
                            hintText: 'ornek@mail.com',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (deger) {
                            if (deger == null || deger.trim().isEmpty) {
                              return 'E-posta alan\u0131 bo\u015f b\u0131rak\u0131lamaz';
                            }
                            if (!deger.contains('@')) {
                              return 'Ge\u00e7erli bir e-posta giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _sifreController,
                          obscureText: _sifreGizli,
                          decoration: InputDecoration(
                            labelText: '\u015eifre',
                            prefixIcon: const Icon(Icons.key_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _sifreGizli ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _sifreGizli = !_sifreGizli);
                              },
                            ),
                          ),
                          validator: (deger) {
                            if (deger == null || deger.trim().length < 6) {
                              return '\u015eifre en az 6 karakter olmal\u0131d\u0131r';
                            }
                            return null;
                          },
                        ),
                        if (_girisModu)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _yukleniyor ? null : _sifreSifirla,
                              child: const Text('\u015eifremi Unuttum'),
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                        if (_hataMesaji != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _hataMesaji!,
                                    style: TextStyle(color: Colors.red.shade900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        FilledButton(
                          onPressed: _yukleniyor ? null : _formuGonder,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _yukleniyor
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _girisModu ? 'Giri\u015f Yap' : 'Hesap Olu\u015ftur',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _yukleniyor
                              ? null
                              : () {
                                  setState(() {
                                    _girisModu = !_girisModu;
                                    _hataMesaji = null;
                                  });
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _girisModu
                                ? 'Hesab\u0131n yok mu? Kay\u0131t Ol'
                                : 'Zaten \u00fcye misin? Giri\u015f Yap',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PanelEkrani extends StatelessWidget {
  const PanelEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final User? kullanici = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Kullan\u0131c\u0131 Paneli'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: '\u00c7\u0131k\u0131\u015f Yap',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.teal.shade100,
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 42,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ho\u015f Geldin, Seymen!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Oturum ba\u015far\u0131yla do\u011fruland\u0131.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const Divider(height: 32),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.teal),
                      title: const Text('Kay\u0131tl\u0131 E-posta'),
                      subtitle: Text(kullanici?.email ?? 'Belirtilmemi\u015f'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.fingerprint, color: Colors.teal),
                      title: const Text('Kullan\u0131c\u0131 Kimli\u011fi (UID)'),
                      subtitle: Text(
                        kullanici?.uid ?? '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('G\u00fcvenli \u00c7\u0131k\u0131\u015f Yap'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}