import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OcrTtsApp());
}

class AppText {
  static const String uk = 'uk';
  static const String en = 'en';

  static String normalizeUiLanguage(String value) {
    return value == uk ? uk : en;
  }

  static String t(String lang, String key) {
    final normalized = normalizeUiLanguage(lang);
    return _values[normalized]?[key] ?? _values[en]?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _values = {
    en: {
      'appTitle': 'OCR + TTS Reader',
      'scanTab': 'Scan',
      'savedTab': 'Saved',
      'settingsTab': 'Settings',
      'scanTitle': 'Scan printed text',
      'scanIntro':
          'Take a clear photo or choose an image from the gallery. The app recognizes text directly on the phone and reads it aloud.',
      'ocrTipsTitle': 'For better recognition',
      'ocrTips':
          'Use bright light, keep the page flat, avoid blur, and choose the exact OCR language. Use Mixed only when the image really contains both Ukrainian and English.',
      'takePhoto': 'Take photo',
      'chooseImage': 'Choose image',
      'rotateLeft': 'Rotate left',
      'rotateRight': 'Rotate right',
      'rotationHint': 'If the text is sideways, rotate the photo before recognition.',
      'imageNotSelected': 'No image selected yet',
      'imageSelected': 'Image selected. Press Recognize text.',
      'recognizeText': 'Recognize text',
      'recognizing': 'Recognizing text...',
      'readText': 'Read aloud',
      'stop': 'Stop',
      'resultTitle': 'Recognized text',
      'resultHint': 'Recognized text will appear here.',
      'noTextToSpeak': 'There is no text to read yet.',
      'selectImageFirst': 'Please take a photo or choose an image first.',
      'readyStatus': 'Ready. Choose an image to start.',
      'processingStatus': 'OCR is running locally on the phone.',
      'noTextFound':
          'No text was found. Try a clearer photo with better lighting.',
      'savedToHistory': 'Saved to history.',
      'notSaved': 'Auto save is disabled.',
      'donePrefix': 'Done.',
      'charactersRecognized': 'characters recognized',
      'inTime': 'in',
      'ocrUsed': 'OCR used',
      'milliseconds': 'ms',
      'ocrError': 'OCR error',
      'cameraGalleryError': 'Could not open camera or gallery',
      'savedTitle': 'Saved texts',
      'noSavedTexts':
          'No saved texts yet. Recognize text on the Scan screen first.',
      'open': 'Open',
      'delete': 'Delete',
      'favorite': 'Favorite',
      'removeFavorite': 'Remove favorite',
      'savedTextTitle': 'Saved text',
      'recordNotFound': 'Record was not found.',
      'settingsTitle': 'Settings',
      'interfaceSettings': 'Interface',
      'interfaceLanguage': 'Interface language',
      'englishInterface': 'English',
      'ukrainianInterface': 'Ukrainian',
      'ocrSettings': 'OCR',
      'ocrDescription':
          'OCR works on this phone. For best accuracy, select the language that matches the printed page.',
      'ocrLanguage': 'OCR language',
      'ttsSettings': 'Text to speech',
      'ttsLanguage': 'Voice language',
      'speechRate': 'Speech speed',
      'pitch': 'Voice pitch',
      'volume': 'Volume',
      'autoSave': 'Save results automatically',
      'saveSettings': 'Save settings',
      'testVoice': 'Test voice',
      'settingsSaved': 'Settings saved.',
      'testVoiceUk': 'This is a Ukrainian voice test.',
      'testVoiceEn': 'This is a test text to speech message.',
      'ukrainianEnglish': 'Mixed: Ukrainian + English',
      'ukrainian': 'Ukrainian only',
      'english': 'English only',
      'ukrainianTts': 'Ukrainian voice',
      'englishTts': 'English voice',
      'sourceCamera': 'Camera',
      'sourceGallery': 'Gallery',
      'sourceUnknown': 'Unknown',
      'chars': 'characters',
      'ocrQualityNote':
          'If the result is poor, try one-language mode instead of Mixed.',
      'untitledText': 'Untitled text',
      'ocrCodeUk': 'Ukrainian',
      'ocrCodeEn': 'English',
      'ocrCodeMixed': 'Mixed',
      'source': 'Source',
    },
    uk: {
      'appTitle': 'OCR + озвучування',
      'scanTab': 'Сканер',
      'savedTab': 'Збережені',
      'settingsTab': 'Налаштування',
      'scanTitle': 'Розпізнавання друкованого тексту',
      'scanIntro':
          'Зробіть чітке фото або виберіть зображення з галереї. Застосунок розпізнає текст прямо на телефоні та може озвучити його.',
      'ocrTipsTitle': 'Для кращого розпізнавання',
      'ocrTips':
          'Використовуйте хороше освітлення, тримайте сторінку рівно, уникайте розмиття та обирайте точну мову OCR. Змішаний режим використовуйте лише тоді, коли на зображенні справді є українська й англійська.',
      'takePhoto': 'Зробити фото',
      'chooseImage': 'Вибрати з галереї',
      'rotateLeft': 'Повернути вліво',
      'rotateRight': 'Повернути вправо',
      'rotationHint': 'Якщо текст повернутий боком, поверніть фото перед розпізнаванням.',
      'imageNotSelected': 'Зображення ще не вибрано',
      'imageSelected': 'Зображення вибрано. Натисніть Розпізнати текст.',
      'recognizeText': 'Розпізнати текст',
      'recognizing': 'Розпізнавання...',
      'readText': 'Озвучити',
      'stop': 'Зупинити',
      'resultTitle': 'Розпізнаний текст',
      'resultHint': 'Тут зʼявиться розпізнаний текст.',
      'noTextToSpeak': 'Поки немає тексту для озвучування.',
      'selectImageFirst': 'Спочатку зробіть фото або виберіть зображення.',
      'readyStatus': 'Готово. Виберіть зображення, щоб почати.',
      'processingStatus': 'OCR виконується локально на телефоні.',
      'noTextFound':
          'Текст не знайдено. Спробуйте зробити фото чіткіше та з кращим освітленням.',
      'savedToHistory': 'Збережено в історію.',
      'notSaved': 'Автозбереження вимкнено.',
      'donePrefix': 'Готово.',
      'charactersRecognized': 'символів розпізнано',
      'inTime': 'за',
      'ocrUsed': 'Використано OCR',
      'milliseconds': 'мс',
      'ocrError': 'Помилка OCR',
      'cameraGalleryError': 'Не вдалося відкрити камеру або галерею',
      'savedTitle': 'Збережені тексти',
      'noSavedTexts':
          'Збережених текстів поки немає. Спочатку розпізнайте текст на екрані Сканер.',
      'open': 'Відкрити',
      'delete': 'Видалити',
      'favorite': 'Обране',
      'removeFavorite': 'Прибрати з обраного',
      'savedTextTitle': 'Збережений текст',
      'recordNotFound': 'Запис не знайдено.',
      'settingsTitle': 'Налаштування',
      'interfaceSettings': 'Інтерфейс',
      'interfaceLanguage': 'Мова інтерфейсу',
      'englishInterface': 'Англійська',
      'ukrainianInterface': 'Українська',
      'ocrSettings': 'OCR',
      'ocrDescription':
          'OCR працює на цьому телефоні. Для кращої точності оберіть мову, яка відповідає тексту на сторінці.',
      'ocrLanguage': 'Мова OCR',
      'ttsSettings': 'Озвучування',
      'ttsLanguage': 'Мова голосу',
      'speechRate': 'Швидкість мовлення',
      'pitch': 'Висота голосу',
      'volume': 'Гучність',
      'autoSave': 'Автоматично зберігати результати',
      'saveSettings': 'Зберегти налаштування',
      'testVoice': 'Перевірити голос',
      'settingsSaved': 'Налаштування збережено.',
      'testVoiceUk': 'Це тестове озвучування українською мовою.',
      'testVoiceEn': 'This is a test text to speech message.',
      'ukrainianEnglish': 'Змішано: українська + англійська',
      'ukrainian': 'Тільки українська',
      'english': 'Тільки англійська',
      'ukrainianTts': 'Український голос',
      'englishTts': 'Англійський голос',
      'sourceCamera': 'Камера',
      'sourceGallery': 'Галерея',
      'sourceUnknown': 'Невідомо',
      'chars': 'символів',
      'ocrQualityNote':
          'Якщо результат поганий, спробуйте режим однієї мови замість змішаного.',
      'untitledText': 'Без назви',
      'ocrCodeUk': 'Українська',
      'ocrCodeEn': 'Англійська',
      'ocrCodeMixed': 'Змішано',
      'source': 'Джерело',
    },
  };
}

String tr(String lang, String key) => AppText.t(lang, key);

class OcrTtsApp extends StatelessWidget {
  const OcrTtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF4F5F9F);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR + TTS Reader',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF161622),
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          titleLarge: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
          titleMedium: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
          bodyLarge: TextStyle(fontSize: 20, height: 1.45),
          bodyMedium: TextStyle(fontSize: 18, height: 1.45),
          labelLarge: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 68),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 68),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 84,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class TextRecord {
  final int? id;
  final String title;
  final String recognizedText;
  final String textLanguage;
  final String sourceType;
  final int characterCount;
  final String createdAt;
  final String updatedAt;
  final int isFavorite;

  const TextRecord({
    this.id,
    required this.title,
    required this.recognizedText,
    required this.textLanguage,
    required this.sourceType,
    required this.characterCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'recognized_text': recognizedText,
      'text_language': textLanguage,
      'source_type': sourceType,
      'character_count': characterCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_favorite': isFavorite,
    };
  }

  factory TextRecord.fromMap(Map<String, Object?> map) {
    return TextRecord(
      id: map['id'] as int?,
      title: map['title'] as String,
      recognizedText: map['recognized_text'] as String,
      textLanguage: map['text_language'] as String,
      sourceType: map['source_type'] as String,
      characterCount: map['character_count'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      isFavorite: map['is_favorite'] as int,
    );
  }
}

class PlaybackSettings {
  final int? id;
  final int textRecordId;
  final String ttsLanguage;
  final String voiceName;
  final double speechRate;
  final double pitch;
  final double volume;

  const PlaybackSettings({
    this.id,
    required this.textRecordId,
    required this.ttsLanguage,
    required this.voiceName,
    required this.speechRate,
    required this.pitch,
    required this.volume,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'text_record_id': textRecordId,
      'tts_language': ttsLanguage,
      'voice_name': voiceName,
      'speech_rate': speechRate,
      'pitch': pitch,
      'volume': volume,
    };
  }

  factory PlaybackSettings.fromMap(Map<String, Object?> map) {
    return PlaybackSettings(
      id: map['id'] as int?,
      textRecordId: map['text_record_id'] as int,
      ttsLanguage: map['tts_language'] as String,
      voiceName: map['voice_name'] as String,
      speechRate: (map['speech_rate'] as num).toDouble(),
      pitch: (map['pitch'] as num).toDouble(),
      volume: (map['volume'] as num).toDouble(),
    );
  }
}

class AppSettings {
  final int id;
  final String interfaceLanguage;
  final String ocrLanguage;
  final String ttsLanguage;
  final String voiceName;
  final double speechRate;
  final double pitch;
  final double volume;
  final int autoSave;

  const AppSettings({
    this.id = 1,
    required this.interfaceLanguage,
    required this.ocrLanguage,
    required this.ttsLanguage,
    required this.voiceName,
    required this.speechRate,
    required this.pitch,
    required this.volume,
    required this.autoSave,
  });

  AppSettings copyWith({
    String? interfaceLanguage,
    String? ocrLanguage,
    String? ttsLanguage,
    String? voiceName,
    double? speechRate,
    double? pitch,
    double? volume,
    int? autoSave,
  }) {
    return AppSettings(
      id: id,
      interfaceLanguage: interfaceLanguage ?? this.interfaceLanguage,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
      voiceName: voiceName ?? this.voiceName,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      autoSave: autoSave ?? this.autoSave,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'interface_language': interfaceLanguage,
      'ocr_language': ocrLanguage,
      'tts_language': ttsLanguage,
      'voice_name': voiceName,
      'speech_rate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'auto_save': autoSave,
    };
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    return AppSettings(
      id: map['id'] as int,
      interfaceLanguage: (map['interface_language'] as String?) ?? AppText.uk,
      ocrLanguage: map['ocr_language'] as String,
      ttsLanguage: map['tts_language'] as String,
      voiceName: map['voice_name'] as String,
      speechRate: (map['speech_rate'] as num).toDouble(),
      pitch: (map['pitch'] as num).toDouble(),
      volume: (map['volume'] as num).toDouble(),
      autoSave: map['auto_save'] as int,
    );
  }

  static const AppSettings defaults = AppSettings(
    interfaceLanguage: AppText.uk,
    ocrLanguage: 'ukr',
    ttsLanguage: 'uk-UA',
    voiceName: '',
    speechRate: 0.48,
    pitch: 1.0,
    volume: 1.0,
    autoSave: 1,
  );
}

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'ocr_tts_local_accessible_v3.db');

    return openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE text_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            recognized_text TEXT NOT NULL,
            text_language TEXT NOT NULL,
            source_type TEXT NOT NULL,
            character_count INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE playback_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text_record_id INTEGER NOT NULL,
            tts_language TEXT NOT NULL,
            voice_name TEXT NOT NULL,
            speech_rate REAL NOT NULL,
            pitch REAL NOT NULL,
            volume REAL NOT NULL,
            FOREIGN KEY(text_record_id) REFERENCES text_records(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE app_settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            interface_language TEXT NOT NULL,
            ocr_language TEXT NOT NULL,
            tts_language TEXT NOT NULL,
            voice_name TEXT NOT NULL,
            speech_rate REAL NOT NULL,
            pitch REAL NOT NULL,
            volume REAL NOT NULL,
            auto_save INTEGER NOT NULL
          )
        ''');

        await db.insert('app_settings', AppSettings.defaults.toMap());
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
              "ALTER TABLE app_settings ADD COLUMN interface_language TEXT NOT NULL DEFAULT 'uk'",
            );
          } catch (_) {

          }
        }
      },
    );
  }

  Future<AppSettings> getSettings() async {
    final db = await database;
    final rows = await db.query('app_settings', where: 'id = ?', whereArgs: [1]);

    if (rows.isEmpty) {
      await db.insert('app_settings', AppSettings.defaults.toMap());
      return AppSettings.defaults;
    }

    return AppSettings.fromMap(rows.first);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.insert(
      'app_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertRecord({
    required String recognizedText,
    required String textLanguage,
    required String sourceType,
    required AppSettings settings,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final title = _makeTitle(recognizedText, settings.interfaceLanguage);

    return db.transaction<int>((txn) async {
      final recordId = await txn.insert(
        'text_records',
        TextRecord(
          title: title,
          recognizedText: recognizedText,
          textLanguage: textLanguage,
          sourceType: sourceType,
          characterCount: recognizedText.length,
          createdAt: now,
          updatedAt: now,
          isFavorite: 0,
        ).toMap(),
      );

      await txn.insert(
        'playback_settings',
        PlaybackSettings(
          textRecordId: recordId,
          ttsLanguage: settings.ttsLanguage,
          voiceName: settings.voiceName,
          speechRate: settings.speechRate,
          pitch: settings.pitch,
          volume: settings.volume,
        ).toMap(),
      );

      return recordId;
    });
  }

  Future<List<TextRecord>> getRecords() async {
    final db = await database;
    final rows = await db.query('text_records', orderBy: 'created_at DESC');
    return rows.map(TextRecord.fromMap).toList();
  }

  Future<TextRecord?> getRecordById(int id) async {
    final db = await database;
    final rows = await db.query('text_records', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return TextRecord.fromMap(rows.first);
  }

  Future<PlaybackSettings?> getPlaybackSettings(int recordId) async {
    final db = await database;
    final rows = await db.query(
      'playback_settings',
      where: 'text_record_id = ?',
      whereArgs: [recordId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PlaybackSettings.fromMap(rows.first);
  }

  Future<void> toggleFavorite(TextRecord record) async {
    if (record.id == null) return;

    final db = await database;
    await db.update(
      'text_records',
      {
        'is_favorite': record.isFavorite == 1 ? 0 : 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete('text_records', where: 'id = ?', whereArgs: [id]);
  }

  String _makeTitle(String text, String uiLanguage) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return tr(uiLanguage, 'untitledText');
    return normalized.length > 46 ? '${normalized.substring(0, 46)}...' : normalized;
  }
}



class OcrResult {
  final String text;
  final String usedLanguage;
  final String pageSegmentationMode;
  final String imageMode;
  final double score;

  const OcrResult({
    required this.text,
    required this.usedLanguage,
    required this.pageSegmentationMode,
    required this.imageMode,
    required this.score,
  });
}

class _OcrCandidate {
  final String language;
  final String psm;
  final double bonus;

  const _OcrCandidate(this.language, this.psm, this.bonus);
}

class _PreparedOcrImage {
  final String path;
  final String mode;
  final double bonus;

  const _PreparedOcrImage({
    required this.path,
    required this.mode,
    required this.bonus,
  });
}

class _LuminanceData {
  final Uint8List luma;
  final List<int> histogram;

  const _LuminanceData({
    required this.luma,
    required this.histogram,
  });
}

class _RgbaImageData {
  final Uint8List rgba;
  final int width;
  final int height;

  const _RgbaImageData({
    required this.rgba,
    required this.width,
    required this.height,
  });
}

class _OcrPreprocessor {
  static const int _targetMinWidth = 1500;
  static const int _targetMaxWidth = 2200;

  Future<List<_PreparedOcrImage>> prepare(
    String imagePath, {
    required int rotationTurns,
    required bool includeProcessedImages,
  }) async {
    final originalBytes = await File(imagePath).readAsBytes();
    final decodedImage = await _decodeForOcr(originalBytes);
    final byteData = await decodedImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (byteData == null) {
      return [
        _PreparedOcrImage(path: imagePath, mode: 'original', bonus: 0),
      ];
    }

    final normalizedTurns = rotationTurns % 4;
    final source = _RgbaImageData(
      rgba: Uint8List.fromList(byteData.buffer.asUint8List()),
      width: decodedImage.width,
      height: decodedImage.height,
    );
    final oriented = normalizedTurns == 0 ? source : _rotateRgba(source, normalizedTurns);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final orientedPath = '$imagePath.ocr_oriented_$timestamp.png';
    await _writePng(orientedPath, oriented.rgba, oriented.width, oriented.height);

    final images = <_PreparedOcrImage>[
      _PreparedOcrImage(path: orientedPath, mode: _rotationMode(normalizedTurns), bonus: 7),
    ];
    if (!includeProcessedImages) return images;

    final lumaData = _buildLuminanceData(oriented.rgba, oriented.width, oriented.height);
    final grayBytes = _makeContrastGrayRgba(
      lumaData.luma,
      lumaData.histogram,
      oriented.width,
      oriented.height,
    );
    final bwBytes = _makeCleanThresholdRgba(
      lumaData.luma,
      lumaData.histogram,
      oriented.width,
      oriented.height,
    );

    final grayPath = '$imagePath.ocr_gray_$timestamp.png';
    final bwPath = '$imagePath.ocr_bw_$timestamp.png';

    await _writePng(grayPath, grayBytes, oriented.width, oriented.height);
    await _writePng(bwPath, bwBytes, oriented.width, oriented.height);

    images.addAll([
      _PreparedOcrImage(path: grayPath, mode: '${_rotationMode(normalizedTurns)}_gray', bonus: 5),
      _PreparedOcrImage(path: bwPath, mode: '${_rotationMode(normalizedTurns)}_bw', bonus: 2),
    ]);

    return images;
  }

  String _rotationMode(int turns) {
    switch (turns % 4) {
      case 1:
        return 'manual_rotate_90';
      case 2:
        return 'manual_rotate_180';
      case 3:
        return 'manual_rotate_270';
      default:
        return 'upright';
    }
  }

  Future<ui.Image> _decodeForOcr(Uint8List bytes) async {
    final firstCodec = await ui.instantiateImageCodec(bytes);
    final firstFrame = await firstCodec.getNextFrame();
    final firstImage = firstFrame.image;
    final width = firstImage.width;

    final targetWidth = width < _targetMinWidth
        ? _targetMinWidth
        : width > _targetMaxWidth
            ? _targetMaxWidth
            : width;

    if (targetWidth == width) return firstImage;

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  _RgbaImageData _rotateRgba(_RgbaImageData image, int turns) {
    final normalizedTurns = turns % 4;
    if (normalizedTurns == 0) return image;

    final source = image.rgba;
    final sourceWidth = image.width;
    final sourceHeight = image.height;
    final targetWidth = normalizedTurns == 2 ? sourceWidth : sourceHeight;
    final targetHeight = normalizedTurns == 2 ? sourceHeight : sourceWidth;
    final target = Uint8List(targetWidth * targetHeight * 4);

    for (var y = 0; y < sourceHeight; y++) {
      for (var x = 0; x < sourceWidth; x++) {
        late int nx;
        late int ny;

        if (normalizedTurns == 1) {
          nx = sourceHeight - 1 - y;
          ny = x;
        } else if (normalizedTurns == 2) {
          nx = sourceWidth - 1 - x;
          ny = sourceHeight - 1 - y;
        } else {
          nx = y;
          ny = sourceWidth - 1 - x;
        }

        final sourceOffset = (y * sourceWidth + x) * 4;
        final targetOffset = (ny * targetWidth + nx) * 4;
        target[targetOffset] = source[sourceOffset];
        target[targetOffset + 1] = source[sourceOffset + 1];
        target[targetOffset + 2] = source[sourceOffset + 2];
        target[targetOffset + 3] = source[sourceOffset + 3];
      }
    }

    return _RgbaImageData(rgba: target, width: targetWidth, height: targetHeight);
  }

  _LuminanceData _buildLuminanceData(Uint8List rgba, int width, int height) {
    final pixelCount = width * height;
    final luma = Uint8List(pixelCount);
    final histogram = List<int>.filled(256, 0);

    var pixelIndex = 0;
    for (var offset = 0; offset < rgba.length; offset += 4) {
      final r = rgba[offset];
      final g = rgba[offset + 1];
      final b = rgba[offset + 2];
      final value =
          (0.299 * r + 0.587 * g + 0.114 * b).round().clamp(0, 255).toInt();
      luma[pixelIndex] = value;
      histogram[value]++;
      pixelIndex++;
    }

    return _LuminanceData(luma: luma, histogram: histogram);
  }

  Uint8List _makeContrastGrayRgba(
    Uint8List luma,
    List<int> histogram,
    int width,
    int height,
  ) {
    final low = _histogramPercentile(histogram, luma.length, 0.025);
    final high = _histogramPercentile(histogram, luma.length, 0.975);
    final range = math.max(1, high - low);

    final out = Uint8List(width * height * 4);
    for (var i = 0; i < luma.length; i++) {
      final stretched =
          (((luma[i] - low) * 255) / range).round().clamp(0, 255).toInt();

      final offset = i * 4;
      out[offset] = stretched;
      out[offset + 1] = stretched;
      out[offset + 2] = stretched;
      out[offset + 3] = 255;
    }

    return out;
  }

  Uint8List _makeCleanThresholdRgba(
    Uint8List luma,
    List<int> histogram,
    int width,
    int height,
  ) {
    final low = _histogramPercentile(histogram, luma.length, 0.025);
    final high = _histogramPercentile(histogram, luma.length, 0.975);
    final range = math.max(1, high - low);

    final stretched = Uint8List(luma.length);
    final stretchedHistogram = List<int>.filled(256, 0);

    for (var i = 0; i < luma.length; i++) {
      final value =
          (((luma[i] - low) * 255) / range).round().clamp(0, 255).toInt();
      stretched[i] = value;
      stretchedHistogram[value]++;
    }

    final threshold = _otsuThreshold(stretchedHistogram, stretched.length);
    final out = Uint8List(width * height * 4);

    var white = 0;
    var black = 0;

    for (var i = 0; i < stretched.length; i++) {
      final value = stretched[i] > threshold - 6 ? 255 : 0;
      if (value == 255) {
        white++;
      } else {
        black++;
      }

      final offset = i * 4;
      out[offset] = value;
      out[offset + 1] = value;
      out[offset + 2] = value;
      out[offset + 3] = 255;
    }

    if (black > white) _invertBlackWhite(out);

    return out;
  }

  int _histogramPercentile(List<int> histogram, int total, double percentile) {
    final target = (total * percentile).round().clamp(0, total);
    var cumulative = 0;

    for (var i = 0; i < histogram.length; i++) {
      cumulative += histogram[i];
      if (cumulative >= target) return i;
    }

    return 255;
  }

  int _otsuThreshold(List<int> histogram, int total) {
    var sum = 0.0;
    for (var i = 0; i < 256; i++) {
      sum += i * histogram[i];
    }

    var sumB = 0.0;
    var wB = 0;
    var maxVariance = 0.0;
    var threshold = 127;

    for (var i = 0; i < 256; i++) {
      wB += histogram[i];
      if (wB == 0) continue;

      final wF = total - wB;
      if (wF == 0) break;

      sumB += i * histogram[i];

      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final variance = wB * wF * math.pow(mB - mF, 2);

      if (variance > maxVariance) {
        maxVariance = variance.toDouble();
        threshold = i;
      }
    }

    return threshold;
  }

  void _invertBlackWhite(Uint8List rgba) {
    for (var i = 0; i < rgba.length; i += 4) {
      final value = rgba[i] == 255 ? 0 : 255;
      rgba[i] = value;
      rgba[i + 1] = value;
      rgba[i + 2] = value;
    }
  }

  Future<void> _writePng(
    String path,
    Uint8List rgba,
    int width,
    int height,
  ) async {
    final image = await _imageFromRgba(rgba, width, height);
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (pngBytes == null) return;

    await File(path).writeAsBytes(pngBytes.buffer.asUint8List(), flush: true);
  }

  Future<ui.Image> _imageFromRgba(Uint8List rgba, int width, int height) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }
}

class LocalOcrService {
  final _OcrPreprocessor _preprocessor = _OcrPreprocessor();

  Future<OcrResult> recognizeText({
    required String imagePath,
    required String language,
    required int rotationTurns,
  }) async {
    if (language == 'eng') {
      return _recognizeEnglishWithMlKit(imagePath, rotationTurns);
    }

    if (language == 'ukr') {
      return _recognizeWithTesseract(
        imagePath: imagePath,
        language: 'ukr',
        rotationTurns: rotationTurns,
      );
    }

    final ukrainian = await _recognizeWithTesseract(
      imagePath: imagePath,
      language: 'ukr',
      rotationTurns: rotationTurns,
    );
    final english = await _recognizeEnglishWithMlKit(imagePath, rotationTurns);

    if (ukrainian.text.isEmpty) return english;
    if (english.text.isEmpty) return ukrainian;
    return ukrainian.score >= english.score ? ukrainian : english;
  }

  Future<OcrResult> _recognizeEnglishWithMlKit(
    String imagePath,
    int rotationTurns,
  ) async {
    final preparedImages = await _preprocessor.prepare(
      imagePath,
      rotationTurns: rotationTurns,
      includeProcessedImages: false,
    );
    final temporaryPaths = preparedImages.map((image) => image.path).toList();

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final preparedImage = preparedImages.first;
      final inputImage = InputImage.fromFilePath(preparedImage.path);
      final recognizedText = await recognizer.processImage(inputImage);
      final cleaned = _cleanOcrText(recognizedText.text, 'eng');
      final score = _scoreOcrText(cleaned, 'eng', 20 + preparedImage.bonus);

      final mlKitResult = OcrResult(
        text: cleaned,
        usedLanguage: 'eng',
        pageSegmentationMode: 'MLKit',
        imageMode: 'mlkit_latin_${preparedImage.mode}',
        score: score,
      );

      if (_isAcceptableResult(mlKitResult)) return mlKitResult;
    } finally {
      await recognizer.close();
      for (final path in temporaryPaths) {
        try {
          await File(path).delete();
        } catch (_) {

        }
      }
    }

    return _recognizeWithTesseract(
      imagePath: imagePath,
      language: 'eng',
      rotationTurns: rotationTurns,
    );
  }

  Future<OcrResult> _recognizeWithTesseract({
    required String imagePath,
    required String language,
    required int rotationTurns,
  }) async {
    final preparedImages = await _preprocessor.prepare(
      imagePath,
      rotationTurns: rotationTurns,
      includeProcessedImages: true,
    );
    final candidates = _buildCandidates(language);

    OcrResult best = const OcrResult(
      text: '',
      usedLanguage: 'unknown',
      pageSegmentationMode: '6',
      imageMode: 'none',
      score: double.negativeInfinity,
    );

    final preparedPathsToDelete = preparedImages.map((image) => image.path).toList();

    try {
      for (final preparedImage in preparedImages) {
        for (final candidate in candidates) {
          final rawText = await FlutterTesseractOcr.extractText(
            preparedImage.path,
            language: candidate.language,
            args: _buildTesseractArgs(candidate.language, candidate.psm),
          );

          final cleaned = _cleanOcrText(rawText, candidate.language);
          final score = _scoreOcrText(
            cleaned,
            candidate.language,
            preparedImage.bonus + candidate.bonus,
          );

          if (score > best.score) {
            best = OcrResult(
              text: cleaned,
              usedLanguage: candidate.language,
              pageSegmentationMode: candidate.psm,
              imageMode: preparedImage.mode,
              score: score,
            );
          }
        }
      }

      if (!_isAcceptableResult(best)) {
        return OcrResult(
          text: '',
          usedLanguage: best.usedLanguage,
          pageSegmentationMode: best.pageSegmentationMode,
          imageMode: best.imageMode,
          score: best.score,
        );
      }

      return best;
    } finally {
      for (final path in preparedPathsToDelete) {
        try {
          await File(path).delete();
        } catch (_) {

        }
      }
    }
  }

  List<_OcrCandidate> _buildCandidates(String language) {
    switch (language) {
      case 'ukr':
        return const [
          _OcrCandidate('ukr', '6', 7),
          _OcrCandidate('ukr', '4', 4),
        ];
      case 'eng':
        return const [
          _OcrCandidate('eng', '6', 6),
        ];
      case 'ukr+eng':
      default:
        return const [
          _OcrCandidate('ukr+eng', '6', 2),
        ];
    }
  }

  Map<String, String> _buildTesseractArgs(String language, String psm) {
    final args = <String, String>{
      'psm': psm,
      'oem': '1',
      'user_defined_dpi': '300',
      'preserve_interword_spaces': '0',
      'tessedit_do_invert': '0',
      'load_system_dawg': '1',
      'load_freq_dawg': '1',
    };

    final whitelist = _characterWhitelist(language);
    if (whitelist != null) {
      args['tessedit_char_whitelist'] = whitelist;
    }

    return args;
  }

  String? _characterWhitelist(String language) {
    const digits = '0123456789';
    const punctuation = ' .,;:!?()[]{}"\'-/\\%№';
    const latin = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    const cyrillic =
        'АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ'
        'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя';

    if (language == 'ukr') return cyrillic + digits + punctuation;
    if (language == 'eng') return latin + digits + punctuation;
    return cyrillic + latin + digits + punctuation;
  }

  String _cleanOcrText(String text, String language) {
    final normalized = text
        .replaceAll('\r', '\n')
        .replaceAll('\u000c', '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');

    final lines = normalized
        .split('\n')
        .map((line) => _cleanLine(line, language))
        .where((line) => line.isNotEmpty)
        .where((line) => _lineLooksLikeText(line, language))
        .toList();

    return lines.join('\n').trim();
  }

  String _cleanLine(String line, String language) {
    final buffer = StringBuffer();
    var previousWasSpace = false;

    for (final rune in line.trim().runes) {
      final allowed = _isAllowedRune(rune, language);
      if (!allowed) continue;

      final isSpace = _isWhitespace(rune);
      if (isSpace) {
        if (!previousWasSpace) buffer.write(' ');
        previousWasSpace = true;
      } else {
        buffer.writeCharCode(rune);
        previousWasSpace = false;
      }
    }

    return buffer.toString().trim();
  }

  bool _lineLooksLikeText(String line, String language) {
    final compact = line.replaceAll(' ', '');
    if (compact.length < 2) return false;
    if (RegExp(r'([^\s])\1{4,}').hasMatch(compact)) return false;

    var latin = 0;
    var cyrillic = 0;
    var digits = 0;
    var punctuation = 0;

    for (final rune in line.runes) {
      if (_isLatin(rune)) {
        latin++;
      } else if (_isCyrillic(rune)) {
        cyrillic++;
      } else if (_isDigit(rune)) {
        digits++;
      } else if (_isCommonPunctuation(rune)) {
        punctuation++;
      }
    }

    final letters = latin + cyrillic;
    final useful = letters + digits;

    if (useful < 2) return false;
    if (letters == 0 && digits < 3) return false;
    if (punctuation > math.max(2, useful * 0.45)) return false;

    if (language == 'ukr') {
      if (cyrillic < 2 && digits == 0) return false;
      if (latin > math.max(0, (cyrillic * 0.08).round())) return false;
      if (cyrillic >= 7 && !_hasUkrainianVowel(line)) return false;
    }

    if (language == 'eng') {
      if (latin < 2 && digits == 0) return false;
      if (cyrillic > 0) return false;
      if (latin >= 7 && !_hasEnglishVowel(line)) return false;
    }

    final words = line.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    var oneLetterWords = 0;
    var longWords = 0;
    var veryLongWords = 0;

    for (final word in words) {
      final lettersInWord = _letterCount(word);
      if (lettersInWord == 1) oneLetterWords++;
      if (lettersInWord >= 3) longWords++;
      if (lettersInWord >= 24) veryLongWords++;
    }

    final wordCount = math.max(1, words.length);
    if (oneLetterWords / wordCount > 0.40 && longWords == 0) return false;
    if (veryLongWords > 0 && words.length <= 2) return false;

    return true;
  }

  bool _isAcceptableResult(OcrResult result) {
    final text = result.text.trim();
    if (text.isEmpty) return false;

    final letters = text.runes
        .where((rune) => _isLatin(rune) || _isCyrillic(rune))
        .length;
    final digits = text.runes.where(_isDigit).length;
    final lineCount = text.split('\n').where((line) => line.trim().isNotEmpty).length;

    if (letters + digits < 4) return false;
    if (result.score < 22 && lineCount <= 1) return false;
    if (result.score < 16) return false;

    return true;
  }

  double _scoreOcrText(String text, String language, double bonus) {
    if (text.trim().isEmpty) return -100000;

    var score = bonus;
    var latin = 0;
    var cyrillic = 0;
    var digits = 0;
    var spaces = 0;
    var punctuation = 0;
    var unknown = 0;

    for (final rune in text.runes) {
      if (_isLatin(rune)) {
        latin++;
        score += language == 'eng' ? 2.2 : 0.4;
      } else if (_isCyrillic(rune)) {
        cyrillic++;
        score += language == 'ukr' ? 2.2 : 0.4;
      } else if (_isDigit(rune)) {
        digits++;
        score += 0.9;
      } else if (_isWhitespace(rune)) {
        spaces++;
        score += 0.06;
      } else if (_isCommonPunctuation(rune)) {
        punctuation++;
        score += 0.05;
      } else {
        unknown++;
        score -= 10.0;
      }
    }

    final letters = latin + cyrillic;
    final useful = letters + digits;
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final words = text.split(RegExp(r'\s+')).where((word) => word.trim().isNotEmpty).toList();

    score += lines.length * 2.0;
    score += words.where((word) => _letterCount(word) >= 3).length * 1.2;

    if (useful < 4) score -= 100;
    if (punctuation > useful * 0.45) score -= punctuation * 4;
    if (unknown > 0) score -= unknown * 10;
    if (spaces > useful && useful > 0) score -= 20;

    if (language == 'ukr') {
      if (latin > math.max(0, (cyrillic * 0.08).round())) score -= 150;
      if (cyrillic >= 8 && !_hasUkrainianVowel(text)) score -= 80;
      score += cyrillic * 0.3;
    }

    if (language == 'eng') {
      if (cyrillic > 0) score -= 150;
      if (latin >= 8 && !_hasEnglishVowel(text)) score -= 80;
      score += latin * 0.3;
    }

    var singleLetterWords = 0;
    for (final word in words) {
      if (_letterCount(word) == 1) singleLetterWords++;
    }
    if (words.isNotEmpty && singleLetterWords / words.length > 0.40) {
      score -= 45;
    }

    return score;
  }

  int _letterCount(String text) {
    var count = 0;
    for (final rune in text.runes) {
      if (_isLatin(rune) || _isCyrillic(rune)) count++;
    }
    return count;
  }

  bool _isAllowedRune(int rune, String language) {
    if (_isWhitespace(rune) || _isDigit(rune) || _isCommonPunctuation(rune)) {
      return true;
    }

    if (language == 'ukr') return _isCyrillic(rune);
    if (language == 'eng') return _isLatin(rune);

    return _isCyrillic(rune) || _isLatin(rune);
  }

  bool _hasUkrainianVowel(String text) {
    const vowels = 'АЕЄИІЇОУЮЯаеєиіїоуюя';
    return text.runes.any((rune) => vowels.runes.contains(rune));
  }

  bool _hasEnglishVowel(String text) {
    const vowels = 'AEIOUYaeiouy';
    return text.runes.any((rune) => vowels.runes.contains(rune));
  }

  bool _isLatin(int rune) {
    return (rune >= 0x0041 && rune <= 0x005A) ||
        (rune >= 0x0061 && rune <= 0x007A);
  }

  bool _isCyrillic(int rune) {
    return rune >= 0x0400 && rune <= 0x04FF;
  }

  bool _isDigit(int rune) {
    return rune >= 0x0030 && rune <= 0x0039;
  }

  bool _isWhitespace(int rune) {
    return rune == 0x20 || rune == 0x09 || rune == 0x0A;
  }

  bool _isCommonPunctuation(int rune) {
    const punctuation = '.,;:!?()[]{}"\'-/\\%№';
    return punctuation.runes.contains(rune);
  }
}

class TtsController {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _tts.awaitSpeakCompletion(false);
    _ready = true;
  }

  Future<void> speak(String text, AppSettings settings) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    await init();
    await _tts.stop();
    await _tts.setLanguage(settings.ttsLanguage);
    await _tts.setSpeechRate(settings.speechRate);
    await _tts.setPitch(settings.pitch);
    await _tts.setVolume(settings.volume);

    if (settings.voiceName.trim().isNotEmpty) {
      await _tts.setVoice({
        'name': settings.voiceName,
        'locale': settings.ttsLanguage,
      });
    }

    await _tts.speak(cleaned);
  }

  Future<void> speakWithPlaybackSettings(
    String text,
    PlaybackSettings playback,
  ) async {
    final settings = AppSettings(
      interfaceLanguage: AppText.uk,
      ocrLanguage: 'ukr',
      ttsLanguage: playback.ttsLanguage,
      voiceName: playback.voiceName,
      speechRate: playback.speechRate,
      pitch: playback.pitch,
      volume: playback.volume,
      autoSave: 1,
    );
    await speak(text, settings);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;
  AppSettings _settings = AppSettings.defaults;
  bool _loadingSettings = true;

  final TtsController _ttsController = TtsController();
  final LocalOcrService _ocrService = LocalOcrService();

  String get _lang => _settings.interfaceLanguage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _ttsController.init();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService.instance.getSettings();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loadingSettings = false;
    });
  }

  void _handleSettingsChanged(AppSettings settings) {
    setState(() {
      _settings = settings;
    });
  }

  @override
  void dispose() {
    _ttsController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSettings) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = <Widget>[
      ScannerScreen(
        ocrService: _ocrService,
        ttsController: _ttsController,
        settings: _settings,
        interfaceLanguage: _lang,
      ),
      HistoryScreen(
        ttsController: _ttsController,
        interfaceLanguage: _lang,
      ),
      SettingsScreen(
        ttsController: _ttsController,
        settings: _settings,
        onSettingsChanged: _handleSettingsChanged,
      ),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: const Icon(Icons.document_scanner),
            label: tr(_lang, 'scanTab'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: tr(_lang, 'savedTab'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: tr(_lang, 'settingsTab'),
          ),
        ],
      ),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  final LocalOcrService ocrService;
  final TtsController ttsController;
  final AppSettings settings;
  final String interfaceLanguage;

  const ScannerScreen({
    super.key,
    required this.ocrService,
    required this.ttsController,
    required this.settings,
    required this.interfaceLanguage,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  String _sourceType = 'none';
  String _recognizedText = '';
  String? _statusKey = 'readyStatus';
  String? _customStatus;
  bool _recognizing = false;
  int? _lastRecordId;
  int _rotationTurns = 0;

  String get _lang => widget.interfaceLanguage;

  String get _status {
    if (_customStatus != null) return _customStatus!;
    return tr(_lang, _statusKey ?? 'readyStatus');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: 3200,
      );

      if (image == null) return;

      setState(() {
        _image = image;
        _sourceType = source == ImageSource.camera ? 'camera' : 'gallery';
        _recognizedText = '';
        _lastRecordId = null;
        _rotationTurns = 0;
        _statusKey = 'imageSelected';
        _customStatus = null;
      });
    } catch (error) {
      _showMessage('${tr(_lang, 'cameraGalleryError')}: $error');
    }
  }

  Future<void> _recognize() async {
    final image = _image;
    if (image == null) {
      _showMessage(tr(_lang, 'selectImageFirst'));
      return;
    }

    setState(() {
      _recognizing = true;
      _statusKey = 'processingStatus';
      _customStatus = null;
    });

    final started = DateTime.now();

    try {
      final settings = widget.settings;
      final result = await widget.ocrService.recognizeText(
        imagePath: image.path,
        language: settings.ocrLanguage,
        rotationTurns: _rotationTurns,
      );

      final text = result.text;
      final elapsedMs = DateTime.now().difference(started).inMilliseconds;

      int? savedId;
      if (text.trim().isNotEmpty && settings.autoSave == 1) {
        savedId = await DatabaseService.instance.insertRecord(
          recognizedText: text,
          textLanguage: result.usedLanguage,
          sourceType: _sourceType,
          settings: settings,
        );
      }

      setState(() {
        _recognizedText = text;
        _lastRecordId = savedId;

        if (text.trim().isEmpty) {
          _statusKey = 'noTextFound';
          _customStatus = null;
        } else {
          _statusKey = null;
          _customStatus =
              '${tr(_lang, 'donePrefix')} ${text.length} ${tr(_lang, 'charactersRecognized')} '
              '${tr(_lang, 'inTime')} $elapsedMs ${tr(_lang, 'milliseconds')}. '
              '${tr(_lang, 'ocrUsed')}: ${_ocrLabel(result.usedLanguage)} '
              '(PSM ${result.pageSegmentationMode}, ${result.imageMode}). '
              '${savedId == null ? tr(_lang, 'notSaved') : tr(_lang, 'savedToHistory')}';
        }
      });
    } catch (error) {
      setState(() {
        _statusKey = null;
        _customStatus = '${tr(_lang, 'ocrError')}: $error';
      });
      _showMessage('${tr(_lang, 'ocrError')}: $error');
    } finally {
      if (mounted) {
        setState(() => _recognizing = false);
      }
    }
  }

  String _ocrLabel(String code) {
    switch (code) {
      case 'ukr':
        return tr(_lang, 'ocrCodeUk');
      case 'eng':
        return tr(_lang, 'ocrCodeEn');
      case 'ukr+eng':
        return tr(_lang, 'ocrCodeMixed');
      default:
        return code;
    }
  }

  void _rotateLeft() {
    if (_image == null || _recognizing) return;
    setState(() {
      _rotationTurns = (_rotationTurns + 3) % 4;
      _recognizedText = '';
      _lastRecordId = null;
      _statusKey = 'imageSelected';
      _customStatus = null;
    });
  }

  void _rotateRight() {
    if (_image == null || _recognizing) return;
    setState(() {
      _rotationTurns = (_rotationTurns + 1) % 4;
      _recognizedText = '';
      _lastRecordId = null;
      _statusKey = 'imageSelected';
      _customStatus = null;
    });
  }

  Future<void> _speak() async {
    if (_recognizedText.trim().isEmpty) {
      _showMessage(tr(_lang, 'noTextToSpeak'));
      return;
    }

    await widget.ttsController.speak(_recognizedText, widget.settings);
  }

  Future<void> _stopSpeaking() async {
    await widget.ttsController.stop();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 17)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canRead = _recognizedText.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(tr(_lang, 'appTitle'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            _InfoCard(interfaceLanguage: _lang),
            const SizedBox(height: 18),
            _LargeButton(
              icon: Icons.camera_alt,
              label: tr(_lang, 'takePhoto'),
              onPressed:
                  _recognizing ? null : () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 14),
            _LargeButton(
              icon: Icons.photo_library_outlined,
              label: tr(_lang, 'chooseImage'),
              tonal: true,
              onPressed:
                  _recognizing ? null : () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 18),
            _ImagePreview(
              image: _image,
              interfaceLanguage: _lang,
              rotationTurns: _rotationTurns,
            ),
            if (_image != null) ...[
              const SizedBox(height: 12),
              _RotationControls(
                interfaceLanguage: _lang,
                onRotateLeft: _rotateLeft,
                onRotateRight: _rotateRight,
              ),
            ],
            const SizedBox(height: 18),
            _LargeButton(
              icon: Icons.text_fields,
              label: _recognizing
                  ? tr(_lang, 'recognizing')
                  : tr(_lang, 'recognizeText'),
              onPressed: _recognizing ? null : _recognize,
              loading: _recognizing,
            ),
            const SizedBox(height: 18),
            _ResultCard(
              recognizedText: _recognizedText,
              status: _status,
              lastRecordId: _lastRecordId,
              interfaceLanguage: _lang,
            ),
            const SizedBox(height: 18),
            _LargeButton(
              icon: Icons.volume_up,
              label: tr(_lang, 'readText'),
              tonal: true,
              onPressed: canRead ? _speak : null,
            ),
            const SizedBox(height: 14),
            _LargeButton(
              icon: Icons.stop,
              label: tr(_lang, 'stop'),
              outlined: true,
              onPressed: _stopSpeaking,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String interfaceLanguage;

  const _InfoCard({required this.interfaceLanguage});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lang = interfaceLanguage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(lang, 'scanTitle'), style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(tr(lang, 'scanIntro'), style: textTheme.bodyLarge),
            const SizedBox(height: 18),
            Text(tr(lang, 'ocrTipsTitle'), style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(tr(lang, 'ocrTips'), style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}


class _RotationControls extends StatelessWidget {
  final String interfaceLanguage;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;

  const _RotationControls({
    required this.interfaceLanguage,
    required this.onRotateLeft,
    required this.onRotateRight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(interfaceLanguage, 'rotationHint'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SmallActionButton(
                  icon: Icons.rotate_left,
                  label: tr(interfaceLanguage, 'rotateLeft'),
                  onPressed: onRotateLeft,
                ),
                _SmallActionButton(
                  icon: Icons.rotate_right,
                  label: tr(interfaceLanguage, 'rotateRight'),
                  onPressed: onRotateRight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  static const double _previewHeight = 300;

  final XFile? image;
  final String interfaceLanguage;
  final int rotationTurns;

  const _ImagePreview({
    required this.image,
    required this.interfaceLanguage,
    required this.rotationTurns,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Container(
        height: 190,
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          tr(interfaceLanguage, 'imageNotSelected'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      );
    }

    final normalizedTurns = rotationTurns % 4;

    return SizedBox(
      height: _previewHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final previewWidth = constraints.maxWidth;
              final isSideways = normalizedTurns.isOdd;

              return Center(
                child: RotatedBox(
                  quarterTurns: normalizedTurns,
                  child: SizedBox(
                    width: isSideways ? _previewHeight : previewWidth,
                    height: isSideways ? previewWidth : _previewHeight,
                    child: Image.file(
                      File(image!.path),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            tr(interfaceLanguage, 'imageNotSelected'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class _ResultCard extends StatelessWidget {
  final String recognizedText;
  final String status;
  final int? lastRecordId;
  final String interfaceLanguage;

  const _ResultCard({
    required this.recognizedText,
    required this.status,
    required this.lastRecordId,
    required this.interfaceLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final lang = interfaceLanguage;
    final text = recognizedText.trim().isEmpty
        ? tr(lang, 'resultHint')
        : recognizedText.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(lang, 'resultTitle'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 190),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: SelectableText(
                text,
                style: const TextStyle(fontSize: 21, height: 1.5),
              ),
            ),
            const SizedBox(height: 14),
            Text(status, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              tr(lang, 'ocrQualityNote'),
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (lastRecordId != null) ...[
              const SizedBox(height: 8),
              Text(
                'ID: $lastRecordId',
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  final TtsController ttsController;
  final String interfaceLanguage;

  const HistoryScreen({
    super.key,
    required this.ttsController,
    required this.interfaceLanguage,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String get _lang => widget.interfaceLanguage;

  Future<List<TextRecord>> _loadRecords() {
    return DatabaseService.instance.getRecords();
  }

  Future<void> _delete(TextRecord record) async {
    if (record.id == null) return;
    await DatabaseService.instance.deleteRecord(record.id!);
    if (mounted) setState(() {});
  }

  Future<void> _toggleFavorite(TextRecord record) async {
    await DatabaseService.instance.toggleFavorite(record);
    if (mounted) setState(() {});
  }

  Future<void> _openRecord(TextRecord record) async {
    if (record.id == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordDetailsScreen(
          recordId: record.id!,
          ttsController: widget.ttsController,
          interfaceLanguage: _lang,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(_lang, 'savedTitle')),
      ),
      body: FutureBuilder<List<TextRecord>>(
        future: _loadRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return _EmptyState(message: tr(_lang, 'noSavedTexts'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final record = records[index];
              return _HistoryCard(
                record: record,
                interfaceLanguage: _lang,
                onOpen: () => _openRecord(record),
                onDelete: () => _delete(record),
                onToggleFavorite: () => _toggleFavorite(record),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TextRecord record;
  final String interfaceLanguage;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _HistoryCard({
    required this.record,
    required this.interfaceLanguage,
    required this.onOpen,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final source = _sourceLabel(record.sourceType);
    final lang = interfaceLanguage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(
              '${_formatDate(record.createdAt)}\n'
              '$source - ${record.characterCount} ${tr(lang, 'chars')} - ${_ocrLabel(record.textLanguage)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SmallActionButton(
                  icon: Icons.open_in_new,
                  label: tr(lang, 'open'),
                  onPressed: onOpen,
                ),
                _SmallActionButton(
                  icon: record.isFavorite == 1 ? Icons.star : Icons.star_border,
                  label: record.isFavorite == 1
                      ? tr(lang, 'removeFavorite')
                      : tr(lang, 'favorite'),
                  onPressed: onToggleFavorite,
                ),
                _SmallActionButton(
                  icon: Icons.delete_outline,
                  label: tr(lang, 'delete'),
                  onPressed: onDelete,
                  outlined: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _sourceLabel(String sourceType) {
    switch (sourceType) {
      case 'camera':
        return tr(interfaceLanguage, 'sourceCamera');
      case 'gallery':
        return tr(interfaceLanguage, 'sourceGallery');
      default:
        return tr(interfaceLanguage, 'sourceUnknown');
    }
  }

  String _ocrLabel(String code) {
    switch (code) {
      case 'ukr':
        return tr(interfaceLanguage, 'ocrCodeUk');
      case 'eng':
        return tr(interfaceLanguage, 'ocrCodeEn');
      case 'ukr+eng':
        return tr(interfaceLanguage, 'ocrCodeMixed');
      default:
        return code;
    }
  }
}

class RecordDetailsScreen extends StatefulWidget {
  final int recordId;
  final TtsController ttsController;
  final String interfaceLanguage;

  const RecordDetailsScreen({
    super.key,
    required this.recordId,
    required this.ttsController,
    required this.interfaceLanguage,
  });

  @override
  State<RecordDetailsScreen> createState() => _RecordDetailsScreenState();
}

class _RecordDetailsScreenState extends State<RecordDetailsScreen> {
  late Future<_RecordDetailsData?> _future;

  String get _lang => widget.interfaceLanguage;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RecordDetailsData?> _load() async {
    final record = await DatabaseService.instance.getRecordById(widget.recordId);
    if (record == null) return null;
    final playback = await DatabaseService.instance.getPlaybackSettings(widget.recordId);
    return _RecordDetailsData(record, playback);
  }

  Future<void> _speak(_RecordDetailsData data) async {
    if (data.playbackSettings != null) {
      await widget.ttsController.speakWithPlaybackSettings(
        data.record.recognizedText,
        data.playbackSettings!,
      );
    } else {
      final settings = await DatabaseService.instance.getSettings();
      await widget.ttsController.speak(data.record.recognizedText, settings);
    }
  }

  Future<void> _delete(TextRecord record) async {
    if (record.id == null) return;
    await DatabaseService.instance.deleteRecord(record.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _sourceLabel(String sourceType) {
    switch (sourceType) {
      case 'camera':
        return tr(_lang, 'sourceCamera');
      case 'gallery':
        return tr(_lang, 'sourceGallery');
      default:
        return tr(_lang, 'sourceUnknown');
    }
  }

  String _ocrLabel(String code) {
    switch (code) {
      case 'ukr':
        return tr(_lang, 'ocrCodeUk');
      case 'eng':
        return tr(_lang, 'ocrCodeEn');
      case 'ukr+eng':
        return tr(_lang, 'ocrCodeMixed');
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(_lang, 'savedTextTitle')),
      ),
      body: FutureBuilder<_RecordDetailsData?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return _EmptyState(message: tr(_lang, 'recordNotFound'));
          }

          final record = data.record;
          final source = _sourceLabel(record.sourceType);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text(
                          'OCR: ${_ocrLabel(record.textLanguage)}\n'
                          '${tr(_lang, 'source')}: $source\n'
                          '${record.characterCount} ${tr(_lang, 'chars')}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _LargeButton(
                  icon: Icons.volume_up,
                  label: tr(_lang, 'readText'),
                  onPressed: () => _speak(data),
                ),
                const SizedBox(height: 14),
                _LargeButton(
                  icon: Icons.stop,
                  label: tr(_lang, 'stop'),
                  outlined: true,
                  onPressed: widget.ttsController.stop,
                ),
                const SizedBox(height: 14),
                _LargeButton(
                  icon: Icons.delete_outline,
                  label: tr(_lang, 'delete'),
                  outlined: true,
                  onPressed: () => _delete(record),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: SelectableText(
                      record.recognizedText,
                      style: const TextStyle(fontSize: 21, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecordDetailsData {
  final TextRecord record;
  final PlaybackSettings? playbackSettings;

  const _RecordDetailsData(this.record, this.playbackSettings);
}

class SettingsScreen extends StatefulWidget {
  final TtsController ttsController;
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.ttsController,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  String get _lang => _settings.interfaceLanguage;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _settings = widget.settings;
    }
  }

  List<DropdownMenuItem<String>> _interfaceLanguageItems() {
    return [
      DropdownMenuItem(
        value: AppText.uk,
        child: Text(tr(_lang, 'ukrainianInterface')),
      ),
      DropdownMenuItem(
        value: AppText.en,
        child: Text(tr(_lang, 'englishInterface')),
      ),
    ];
  }

  List<DropdownMenuItem<String>> _ocrLanguageItems() {
    return [
      DropdownMenuItem(value: 'ukr', child: Text(tr(_lang, 'ukrainian'))),
      DropdownMenuItem(value: 'eng', child: Text(tr(_lang, 'english'))),
      DropdownMenuItem(
        value: 'ukr+eng',
        child: Text(tr(_lang, 'ukrainianEnglish')),
      ),
    ];
  }

  List<DropdownMenuItem<String>> _ttsLanguageItems() {
    return [
      DropdownMenuItem(value: 'uk-UA', child: Text(tr(_lang, 'ukrainianTts'))),
      DropdownMenuItem(value: 'en-US', child: Text(tr(_lang, 'englishTts'))),
    ];
  }

  Future<void> _save() async {
    await DatabaseService.instance.saveSettings(_settings);
    widget.onSettingsChanged(_settings);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(_lang, 'settingsSaved'),
          style: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }

  Future<void> _testVoice() async {
    await widget.ttsController.speak(
      _settings.ttsLanguage == 'uk-UA'
          ? tr(_lang, 'testVoiceUk')
          : tr(_lang, 'testVoiceEn'),
      _settings,
    );
  }

  void _updateSettings(AppSettings settings) {
    setState(() {
      _settings = settings;
    });
    widget.onSettingsChanged(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(_lang, 'settingsTitle')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SettingsCard(
              title: tr(_lang, 'interfaceSettings'),
              child: _DropdownSetting(
                label: tr(_lang, 'interfaceLanguage'),
                value: _settings.interfaceLanguage,
                items: _interfaceLanguageItems(),
                onChanged: (value) {
                  _updateSettings(
                    _settings.copyWith(interfaceLanguage: value),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              title: tr(_lang, 'ocrSettings'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(_lang, 'ocrDescription'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  _DropdownSetting(
                    label: tr(_lang, 'ocrLanguage'),
                    value: _settings.ocrLanguage,
                    items: _ocrLanguageItems(),
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(ocrLanguage: value),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              title: tr(_lang, 'ttsSettings'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DropdownSetting(
                    label: tr(_lang, 'ttsLanguage'),
                    value: _settings.ttsLanguage,
                    items: _ttsLanguageItems(),
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(ttsLanguage: value),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _SliderSetting(
                    label: tr(_lang, 'speechRate'),
                    value: _settings.speechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(speechRate: value),
                      );
                    },
                  ),
                  _SliderSetting(
                    label: tr(_lang, 'pitch'),
                    value: _settings.pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(pitch: value));
                    },
                  ),
                  _SliderSetting(
                    label: tr(_lang, 'volume'),
                    value: _settings.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(volume: value));
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      tr(_lang, 'autoSave'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    value: _settings.autoSave == 1,
                    onChanged: (value) {
                      _updateSettings(
                        _settings.copyWith(autoSave: value ? 1 : 0),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _LargeButton(
              icon: Icons.save,
              label: tr(_lang, 'saveSettings'),
              onPressed: _save,
            ),
            const SizedBox(height: 14),
            _LargeButton(
              icon: Icons.record_voice_over,
              label: tr(_lang, 'testVoice'),
              outlined: true,
              onPressed: _testVoice,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      items: items,
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(fontSize: 19, color: Color(0xFF161622)),
      onChanged: (newValue) {
        if (newValue == null) return;
        onChanged(newValue);
      },
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LargeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool tonal;
  final bool outlined;
  final bool loading;

  const _LargeButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tonal = false,
    this.outlined = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          )
        else
          Icon(icon, size: 30),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        child: buttonChild,
      );
    }

    if (tonal) {
      return FilledButton.tonal(
        onPressed: onPressed,
        child: buttonChild,
      );
    }

    return FilledButton(
      onPressed: onPressed,
      child: buttonChild,
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool outlined;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(label, softWrap: false, overflow: TextOverflow.ellipsis),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        child: child,
      );
    }

    return FilledButton.tonal(
      onPressed: onPressed,
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
