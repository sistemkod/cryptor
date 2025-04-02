import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as Enc;

void main() {
  runApp(const Basepage());
}

/// Basit Flutter uygulaması
class Basepage extends StatelessWidget {
  const Basepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cryptor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Home(),
    );
  }
}

/// Ana sayfa
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

/// Ekran state yönetimi
class _HomeState extends State<Home> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController  = TextEditingController();
  final TextEditingController _ivController   = TextEditingController();

  String _result = ''; // Şifrelenmiş veya çözülmüş metni göstermek için
  final Cryptor _cryptor = Cryptor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cryptor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Metin girişi
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Text (To be encrypted or decrypted)',
              ),
            ),
            const SizedBox(height: 16),
            
            // Key girişi
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Key (Base64) - If left blank it will be generated automatically',
              ),
            ),
            const SizedBox(height: 16),

            // IV girişi
            TextField(
              controller: _ivController,
              decoration: const InputDecoration(
                labelText: 'IV (Base64) - Automatically generated if left blank',
              ),
            ),
            const SizedBox(height: 16),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _encryptText();
                  },
                  child: const Text('Encrypt'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _decryptText();
                  },
                  child: const Text('Decrypt'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sonuç gösterimi
            SelectableText(
              _result,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Şifreleme işlemi
  void _encryptText() {
    final String txt = _textController.text.trim();
    final String userKey = _keyController.text.trim();
    final String userIv  = _ivController.text.trim();

    if (txt.isEmpty) {
      setState(() {
        _result = "Please enter text to encrypt.";
      });
      return;
    }

    // Key ve IV atamaları
    _cryptor.setKeyAndIV(userKey.isEmpty ? null : userKey, 
                         userIv.isEmpty  ? null : userIv);

    // Şifreleme
    final encrypted = _cryptor.strEncrypt(txt);
    setState(() {
      _result = "ENCRYPTED: $encrypted\nKEY: ${_cryptor.key}\nIV: ${_cryptor.iv}";
    });
  }

  /// Şifre çözme işlemi
  void _decryptText() {
    final String txt = _textController.text.trim();
    final String userKey = _keyController.text.trim();
    final String userIv  = _ivController.text.trim();

    if (txt.isEmpty || userKey.isEmpty || userIv.isEmpty) {
      setState(() {
        _result = "Please enter the ciphertext, key and iv values ​​to decrypt.";
      });
      return;
    }

    // Key ve IV atamaları
    _cryptor.setKeyAndIV(userKey, userIv);

    // Şifre çözme
    try {
      final decrypted = _cryptor.strDecrypt(txt);
      setState(() {
        _result = decrypted;
      });
    } catch (e) {
      setState(() {
        _result = "Error: ${e.toString()}";
      });
    }
  }
}

/// Cryptor sınıfı
class Cryptor {
  Enc.Key? _key;
  Enc.IV? _iv;

  String get key{
    return "${_key!.base64}";
  }

  String get iv{
    return "${_iv!.base64}";
  }

  /// Kullanıcının girdiği (ya da otomatik üretilen) key ve iv'leri ayarla
  void setKeyAndIV(String? base64Key, String? base64Iv) {
    if (base64Key == null) {
      // 32 byte -> AES-256
      _key = Enc.Key.fromSecureRandom(32);
    } else {
      _key = Enc.Key.fromBase64(base64Key);
    }

    if (base64Iv == null) {
      _iv = Enc.IV.fromSecureRandom(16);
    } else {
      _iv = Enc.IV.fromBase64(base64Iv);
    }
  }

  /// Metni şifreler: geri dönüş olarak Base64 string döner.
  String strEncrypt(String txt) {
    final List<int> content = utf8.encode(txt);
    final Uint8List encryptedData = encryptUint8List(content);
    // Şifreli veriyi base64 encode ederek stringe çeviriyoruz
    final String encryptedBase64 = base64Encode(encryptedData);
    return encryptedBase64;
  }

  /// Şifrelenmiş base64 stringi çözerek orijinal metni döndürür.
  String strDecrypt(String base64Text) {
    final Uint8List data = base64Decode(base64Text);
    final List<int> decryptedData = decryptUint8List(data);
    final String decrypted = utf8.decode(decryptedData);
    return decrypted;
  }

  /// Uint8List şifreler
  Uint8List encryptUint8List(List<int> data) {
    final encrypter = Enc.Encrypter(Enc.AES(_key!));
    // Gzip ile sıkıştırıp sonra şifreliyoruz
    final compressed = gzip.encode(data);
    final encrypted = encrypter.encryptBytes(compressed, iv: _iv!);
    return encrypted.bytes;
  }

  /// Uint8List şifresini çözer
  Uint8List decryptUint8List(List<int> data) {
    final encrypter = Enc.Encrypter(Enc.AES(_key!));
    final encrypted = Enc.Encrypted(Uint8List.fromList(data));
    final decryptedBytes = encrypter.decryptBytes(encrypted, iv: _iv!);

    // Gzip ile sıkıştırılmış olduğu için tekrar açıyoruz
    final uncompressed = gzip.decode(decryptedBytes);
    return Uint8List.fromList(uncompressed);
  }
}
