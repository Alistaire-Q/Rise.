import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  // Fungsi utama untuk memproses gambar menjadi angka
  Future<double?> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      // 1. Suruh Google ML Kit membaca semua teks di gambar
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      double maxAmount = 0.0;

      // 2. Siapkan "Penyaring" (Regex) untuk mencari format uang
      // Mencari angka yang mungkin ada titik/koma (contoh: 50.000, 12,500)
      final RegExp priceRegex = RegExp(r'[0-9]+[.,]?[0-9]*[.,]?[0-9]+');

      // 3. Loop setiap baris teks yang ditemukan
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.toLowerCase();
          
          // Bersihkan teks dari simbol mata uang & spasi agar mudah dibaca angka
          String cleanText = text.replaceAll('rp', '').replaceAll('idr', '').replaceAll(' ', '');
          
          // Coba cari pola angka di baris ini
          Iterable<Match> matches = priceRegex.allMatches(cleanText);
          
          for (var match in matches) {
            String numStr = match.group(0)!;
            
            // Normalisasi format angka (Hapus titik ribuan, ganti koma desimal jadi titik)
            // Contoh: "50.000" jadi "50000"
            // PENTING: Logic ini asumsi format Indonesia (titik = ribuan)
            numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
            
            try {
              double val = double.parse(numStr);
              
              // Filter Logika:
              // Kita cari angka TERBESAR di struk, karena biasanya "Total Bayar" 
              // adalah angka paling besar dibanding harga satuan barang.
              // Kita juga abaikan angka kecil (< 100 perak) biar bukan jumlah qty.
              if (val > maxAmount && val > 100) {
                maxAmount = val;
              }
            } catch (e) {
              // Skip jika gagal convert
            }
          }
        }
      }
      
      // Jika ketemu angka valid, kembalikan. Jika tidak, null.
      if (maxAmount > 0) return maxAmount;
      return null;

    } catch (e) {
      print('Error scanning receipt: $e');
      return null;
    } finally {
      // Wajib tutup recognizer biar hemat memori
      textRecognizer.close();
    }
  }
}
