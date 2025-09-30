import 'package:flutter/material.dart';
import 'dart:math';

// ----------------------------------------------------
// 1. CLASES DE UTILIDAD Y CONSTANTES
// ----------------------------------------------------

// Definición de la paleta de colores para una interfaz limpia
class AppColor {
  static const Color primaryColor = Color(0xFF2C3E50); // Azul oscuro/Pizarra
  static const Color accentColor = Color(0xFFE74C3C); // Rojo para errores
  static const Color correctColor = Color(0xFF2ECC71); // Verde para aciertos
  static const Color lightColor = Color(0xFFECF0F1); // Blanco roto
  static const Color disabledColor = Color(0xFF95A5A6); // Gris para botones usados
}

// Utilidades del juego (palabras y rutas de imágenes)
class GameUtils {
  // Lista predefinida de palabras en mayúsculas
  static final List<String> wordList = [
    "FLUTTER", "WIDGET", "MOBILE", "DART", "COLUMNA", "ESTADO", "APLICACION", "PROGRAMACION", "INTERFAZ", "SOFTWARE"
  ];

  // Función para obtener la ruta de la imagen del ahorcado según el número de fallos
  // NOTA: Asegúrate de tener estas imágenes configuradas en tu 'pubspec.yaml'
  // y nombradas de 0.png a 6.png dentro de 'assets/hangman/'
  static String getHangmanImage(int count) {
    // Si el usuario no ha configurado las imágenes, usamos un placeholder.
    // En un proyecto real, se debe configurar: assets: - assets/hangman/
    return 'assets/hangman/$count.png';
  }

  // Genera un número aleatorio para seleccionar una palabra
  static String selectRandomWord() {
    final random = Random();
    return wordList[random.nextInt(wordList.length)];
  }
}

// ----------------------------------------------------
// 2. MAIN Y WIDGET PRINCIPAL
// ----------------------------------------------------

void main() {
  runApp(const HangmanApp());
}

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Ahorcado',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor),
        useMaterial3: true,
      ),
      home: const HangmanGamePage(),
    );
  }
}

// ----------------------------------------------------
// 3. PÁGINA DE JUEGO (STATEFUL WIDGET)
// ----------------------------------------------------

class HangmanGamePage extends StatefulWidget {
  const HangmanGamePage({super.key});

  @override
  State<HangmanGamePage> createState() => _HangmanGamePageState();
}

class _HangmanGamePageState extends State<HangmanGamePage> {
  // --- VARIABLES DE ESTADO ---
  String _currentWord = "";
  final List<String> _guessedLetters = [];
  final int _maxMisses = 6;
  int _currentMisses = 0;
  int get _currentHits {
  return _guessedLetters.where((letter) => _currentWord.contains(letter)).length;
}
  bool _gameFinished = false;
int _totalAttempts = 0;


  // Alfabeto completo para construir el teclado
  final List<String> _alphabet = List.generate(26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  @override
  void initState() {
    super.initState();
    _selectNewWord();
  }

  // --- LÓGICA DEL JUEGO ---

  void _selectNewWord() {
    setState(() {
      _currentWord = GameUtils.selectRandomWord();
      _guessedLetters.clear();
      _currentMisses = 0;
      _gameFinished = false;
      _totalAttempts++;
    });
  }

  void _checkLetter(String letter) {
    // Si el juego ha terminado o la letra ya fue adivinada, ignorar
    if (_gameFinished || _guessedLetters.contains(letter)) {
      return;
    }

    setState(() {
      _guessedLetters.add(letter);

      // 1. Revisar si la letra es un fallo
      if (!_currentWord.contains(letter)) {
        _currentMisses++;
      }

      // 2. Revisar si el juego ha terminado (ganar o perder)
      if (_currentMisses >= _maxMisses) {
        _gameFinished = true;
        _showGameResult(false); // Perdió
      } else if (_isWordGuessed()) {
        _gameFinished = true;
        _showGameResult(true); // Ganó
      }
    });
  }

  bool _isWordGuessed() {
    // Verifica si cada letra de la palabra está en la lista de letras adivinadas
    return _currentWord.split('').every((char) => _guessedLetters.contains(char));
  }

  // --- WIDGETS DE INTERFAZ (UI) ---

  // Muestra la imagen del ahorcado (parte superior de la columna)
  Widget _buildHangmanImage() {
    // Utilizamos Image.asset para cargar la imagen local
    return Image.asset(
      GameUtils.getHangmanImage(_currentMisses),
      height: 250,
      fit: BoxFit.contain,
      // Manejo de error si la imagen no se carga (ej. no está en pubspec.yaml)
      errorBuilder: (context, error, stackTrace) => Container(
          height: 250, width: 250,
          decoration: BoxDecoration(
              color: AppColor.lightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.lightColor.withOpacity(0.5))
          ),
          child: const Center(child: Text("FALTA IMAGEN\n(assets/hangman/)",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.lightColor, fontSize: 14)))),
    );
  }

  // Muestra la palabra oculta/adivinada (usando Row)
  Widget _buildWordDisplay() {
    return Row(
      // Organiza los elementos horizontalmente (Requisito: Row)
      mainAxisAlignment: MainAxisAlignment.center,
      children: _currentWord.split('').map((letter) {
        bool isGuessed = _guessedLetters.contains(letter);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            // Mostrar la letra si fue adivinada, sino mostrar '_'
            isGuessed || _gameFinished ? letter : '_',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: isGuessed ? AppColor.lightColor : AppColor.disabledColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Crea el teclado (usando Column y Rows anidadas)
  Widget _buildKeyboard() {
    // Dividimos el alfabeto en 3 filas para un mejor diseño en móviles
    final List<List<String>> rows = [
      _alphabet.sublist(0, 9),
      _alphabet.sublist(9, 18),
      _alphabet.sublist(18, 26),
    ];

    return Column(
      // Organiza las filas verticalmente (Requisito: Column)
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            // Organiza los botones horizontalmente (Requisito: Row)
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((letter) => _buildLetterButton(letter)).toList(),
          ),
        );
      }).toList(),
    );
  }

  // Crea un botón de letra individual
  Widget _buildLetterButton(String letter) {
    final bool alreadyGuessed = _guessedLetters.contains(letter);

    // Determinar el color del botón
    Color buttonColor = AppColor.lightColor;
    Color textColor = AppColor.primaryColor;

    if (alreadyGuessed) {
      if (_currentWord.contains(letter)) {
        buttonColor = AppColor.correctColor;
      } else {
        buttonColor = AppColor.accentColor;
      }
      textColor = AppColor.lightColor;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: ElevatedButton(
        // Deshabilitar el botón si la letra ya fue usada o el juego terminó
        onPressed: alreadyGuessed || _gameFinished ? null : () => _checkLetter(letter),
        style: ElevatedButton.styleFrom(
          backgroundColor: alreadyGuessed ? buttonColor : AppColor.lightColor,
          foregroundColor: textColor,
          disabledBackgroundColor: alreadyGuessed ? buttonColor.withOpacity(0.6) : AppColor.disabledColor.withOpacity(0.3),
          disabledForegroundColor: textColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(10),
          minimumSize: const Size(35, 35),
          elevation: 5,
        ),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Muestra el diálogo de resultado
  void _showGameResult(bool isWinner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isWinner ? '¡Felicidades, Ganaste!' : '¡Juego Terminado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isWinner
                    ? '¡Adivinaste la palabra correctamente!'
                    : 'Perdiste. La palabra era: "$_currentWord"',
                style: TextStyle(
                  color: isWinner ? AppColor.correctColor : AppColor.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text('Total de Fallos: $_currentMisses de $_maxMisses |   Total de Aciertos: $_currentHits',),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Jugar de Nuevo'),
              onPressed: () {
                Navigator.of(context).pop();
                _selectNewWord(); // Reiniciar el juego
              },
            ),
          ],
        );
      },
    );
  }

  // --- ESTRUCTURA PRINCIPAL DE LA PÁGINA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        title: const Text(
            "El Ahorcado",
            style: TextStyle(color: AppColor.lightColor, fontWeight: FontWeight.bold)
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
      ),
      body: Column(
        // Organiza el contenido verticalmente (Requisito: Column)
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Imagen del Ahorcado (Muñeco)
          Center(
            // La lógica de la imagen está en _buildHangmanImage
            child: _buildHangmanImage(),
          ),

          // 2. Información de fallos y Aciertos
          Text(
            'Fallos: $_currentMisses / $_maxMisses,  |   Aciertos: $_currentHits',
            style: const TextStyle(
              fontSize: 18,
              color: AppColor.lightColor,
              fontWeight: FontWeight.w300,
            ),
          ),

          Text(
            'Intentos: $_totalAttempts',
             style: const TextStyle(
             fontSize: 18,
             color: AppColor.lightColor,
             fontWeight: FontWeight.w300,
  ),
), 



          const Divider(color: AppColor.lightColor, indent: 30, endIndent: 30),

          // 3. Palabra a adivinar (usando Row)
          _buildWordDisplay(),

          const Divider(color: AppColor.lightColor, indent: 30, endIndent: 30),

          // 4. Teclado de letras (usando Column y Rows)
          _buildKeyboard(),

          // Espacio final para asegurar que el teclado no esté pegado al borde
          const SizedBox(height: 10),

          // 5. Informacion de intentos
          Text(
           'Intentos: $_totalAttempts',
            style: const TextStyle(
            fontSize: 18,
            color: AppColor.lightColor,
            fontWeight: FontWeight.w300,
  ),
),
        ],
      ),
    );
  }
}
