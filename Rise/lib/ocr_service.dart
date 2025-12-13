import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final _picker = ImagePicker();
  // Menggunakan script Latin untuk membaca tulisan umum
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Fungsi baru: Langsung buka kamera -> Foto -> Deteksi Angka
  Future<double?> scanReceipt() async {
    try {
      // 1. Buka Kamera
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      // Jika user menekan tombol 'Back' / batal foto
      if (photo == null) return null;

      // 2. Proses Gambar dengan ML Kit
      final inputImage = InputImage.fromFilePath(photo.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 3. Cari Total Harga dari teks yang didapat
      return _extractTotalAmount(recognizedText);

    } catch (e) {
      print('Error scanning receipt: $e');
      return null;
    }
  }

  // Logika khusus untuk mencari angka Rupiah terbesar (Total Belanja)
  double? _extractTotalAmount(RecognizedText recognizedText) {
    double maxAmount = 0.0;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text.toLowerCase();
        
        // Bersihkan teks: Hapus huruf (rp, idr, total), spasi, dan simbol aneh
        // Kita hanya sisakan Angka (0-9), Titik (.), dan Koma (,)
        String cleanText = text.replaceAll(RegExp(r'[^0-9.,]'), '');

        if (cleanText.isEmpty) continue;

        // --- LOGIKA MATA UANG INDONESIA ---
        // Format Rupiah biasanya: 50.000 atau 50.000,00
        // Dart hanya mengerti format: 50000.00 (Titik sebagai desimal)
        
        // Langkah:
        // 1. Hapus semua titik ribuan (Contoh: "50.000" jadi "50000")
        // 2. Ganti koma menjadi titik desimal (Contoh: "50000,00" jadi "50000.00")
        String standardFormat = cleanText.replaceAll('.', '').replaceAll(',', '.');

        try {
          double val = double.parse(standardFormat);

          // Filter Cerdas:
          // 1. Abaikan angka kecil (< 1000) agar tidak salah baca tanggal (2024) atau qty (1 pcs)
          // 2. Ambil angka TERBESAR yang ditemukan, karena biasanya Total adalah nominal paling besar di struk.
          if (val > maxAmount && val > 1000) {
            maxAmount = val;
          }
        } catch (e) {
          // Abaikan jika teks bukan angka valid
          continue;
        }
      }
    }

    // Kembalikan null jika tidak ada angka valid yang ditemukan
    return maxAmount > 0 ? maxAmount : null;
  }

  // Penting: Tutup recognizer saat aplikasi dimatikan/tidak dipakai untuk hemat memori
  void dispose() {
    _textRecognizer.close();
  }
}