// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'main.g.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
@riverpod
String helloWorld(HelloWorldRef ref) {
  return 'Hello world';
}

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
    ),
  );
}

enum TextMessageType {
  recieved,
  sent,
}

class TextMessage extends HookConsumerWidget {
  const TextMessage({
    required this.message,
    required this.type,
    super.key,
  });

  final String message;
  final TextMessageType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: type == TextMessageType.recieved ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            topRight: Radius.circular(type == TextMessageType.recieved ? 20 : 0),
            topLeft: Radius.circular(type == TextMessageType.recieved ? 0 : 20),
          ),
          border: Border.all(color: Colors.grey),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class MessageData {
  final String message;
  final bool other;
  const MessageData({
    required this.message,
    required this.other,
  });
}

// Extend HookConsumerWidget instead of HookWidget, which is exposed by Riverpod
class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use hooks inside HookConsumerWidget
    final scrollController = useScrollController();
    final messageText = useState("");
    final textEditingController = useTextEditingController();
    final messages = useState(<MessageData>[
      const MessageData(message: "Hello, how are you today?", other: true),
    ]);

    useEffect(() {
      textEditingController.addListener(() {
        messageText.value = textEditingController.text;
      });
      return textEditingController.dispose;
    }, [
      textEditingController
    ]);

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shadowColor: Colors.grey,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Chatting app')),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ListView(
                              controller: scrollController,
                              // clipBehavior: Clip.,
                              padding: const EdgeInsets.all(24),
                              children: [
                                for (final message in messages.value)
                                  TextMessage(
                                    message: message.message,
                                    type: message.other ? TextMessageType.recieved : TextMessageType.sent,
                                  ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white,
                                    ],
                                    stops: const [
                                      0.0,
                                      0.95,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10).copyWith(top: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                height: 70,
                                width: double.infinity,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: EmojiText(text: messageText.value),
                                  // child: RichText(
                                  //   text: TextSpan(
                                  //     text: "hello",
                                  //   ),
                                  // ),
                                  // child: Text("hesdfs"),
                                  // child: Text(
                                  //   messageText.value,
                                  //   style: Theme.of(context).textTheme.bodyMedium.copyWith(
                                  //         fontFamily: "Roboto",
                                  //       ),
                                  // ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        shadowColor: Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                          side: const BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      onPressed: () {
                                        messages.value = [
                                          ...messages.value,
                                          MessageData(message: messageText.value, other: false),
                                        ];
                                        textEditingController.clear();
                                        scrollController.animateTo(
                                          scrollController.position.maxScrollExtent + 70,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.fastOutSlowIn,
                                        );
                                      },
                                      child: const Icon(Icons.send),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // Keyboard is transparent
                  color: Colors.black,
                  child: EmojiKeyboard(
                    textController: textEditingController,
                    // Default height is 300
                    // textController: textEditingController,
                    // height: 350,
                    // // Default is black
                    // textColor: Colors.white,
                    // // Default 14
                    // fontSize: 20,
                    // // [A-Z, 0-9]
                    // type: VirtualKeyboardType.Alphanumeric,
                    // Callback for key press event
                    // : () {
                    //
                    // },
                  ),
                )
              ],
            ),
            // IgnorePointer(
            //   child: Opacity(
            //     opacity: 0.0,
            //     child: Image(
            //       image: FileImage(File('/home/flafy/Downloads/androidkeyboardtest.png')),
            //       fit: BoxFit.cover,
            //       height: double.infinity,
            //       width: double.infinity,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class EmojiKeyboard extends HookConsumerWidget {
  const EmojiKeyboard({
    this.textController,
    super.key,
  });

  final TextEditingController? textController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numRow = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "0",
    ];
    final qwertyRows = [
      [
        "q",
        "w",
        "e",
        "r",
        "t",
        "y",
        "u",
        "i",
        "o",
        "p",
      ],
      [
        "a",
        "s",
        "d",
        "f",
        "g",
        "h",
        "j",
        "k",
        "l",
      ],
      [
        "SHIFT",
        "z",
        "x",
        "c",
        "v",
        "b",
        "n",
        "m",
        "BS",
      ],
    ];
    void onKeyPressed(String key) {
      if (textController != null) {
        switch (key) {
          case "BS":
            if (textController!.text.isNotEmpty) {
              textController!.text = textController!.text.substring(0, textController!.text.length - 1);
            }
            break;
          case "SPACE":
            textController!.text += " ";
            break;
          case "SHIFT":
            break;
          default:
            textController!.text += key;
        }
      }
    }

    // final points = useValueNotifier(<Offset>[]);
    final drawPath = useState<Path>(Path());
    final drew = useState(false);
    final submitTimer = useRef<Timer?>(null);
    final keyboardOpacityAC = useAnimationController(duration: const Duration(milliseconds: 200));

    Future<void> onSubmitDrawing() async {
      print("??????");
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final paint = Paint()
        ..color = Color.fromARGB(255, 68, 68, 68)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 15
        ..style = PaintingStyle.stroke;
      const targetSize = Size(400, 400);

      drawPath.value = drawPath.value.shift(drawPath.value.getBounds().topLeft * -1);

      final drawingSize = drawPath.value.getBounds().size;
      final scale = min(targetSize.width / drawingSize.width, targetSize.height / drawingSize.height);
      // final translate = Offset(
      //   (targetSize.width - drawingSize.width * scale) / 2,
      //   (targetSize.height - drawingSize.height * scale) / 2,
      // );
      final secondScale = 0.9;
      // Center the image. DIFF from the first translate
      final secondTranslate = Offset(
        (targetSize.width - drawingSize.width * scale * secondScale) / 2,
        (targetSize.height - drawingSize.height * scale * secondScale) / 2,
      );

      canvas.drawPath(
        drawPath.value.transform(
          Matrix4Transform().scale(scale).scale(secondScale).translateOffset(secondTranslate).matrix4.storage,
        ),
        paint,
      );
      final picture = pictureRecorder.endRecording();

      drawPath.value.reset();
      drew.value = false;
      drawPath.notifyListeners();

      final img = await picture.toImage(targetSize.width.toInt(), targetSize.height.toInt());
      final bytes = await img.toByteData(format: ImageByteFormat.png);
      final buffer = bytes!.buffer.asUint8List();
      final res = await http.post(
        Uri.parse("http://flafy.dev:3001/upload"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "emojiBase64": "data:image/png;base64,${base64Encode(buffer)}",
          "modelType": "transfer-fine",
        }),
      );
      final resJson = jsonDecode(res.body);
      final emoji = int.tryParse(resJson?["index"]) ?? 0;
      final emojiTable = {
        0: "😁",
        1: "☁️ ",
        2: "😵‍💫",
        3: "😳",
        4: "😬",
        5: "😃",
        6: "😆",
        7: "❤️",
        8: "😡",
        9: "🤨",
        10: "🤨",
        11: "😋",
        12: "😍",
        13: "😈",
        14: "😎",
        15: "🥲",
        16: "😏",
        17: "😂",
      };
      if (textController != null) {
        textController!.text += emojiTable[emoji]!;
      }
    }

    final prevPoint = useRef<Offset?>(null);
    final startPoint = useRef<Offset?>(null);

    useEffect(() {
      if (drew.value) {
        keyboardOpacityAC.forward();
      } else {
        keyboardOpacityAC.reverse();
      }
      return null;
    }, [
      keyboardOpacityAC,
      drew.value,
    ]);

    return LayoutBuilder(builder: (context, constraints) {
      return Listener(
        onPointerDown: (e) {
          drawPath.value.moveTo(e.localPosition.dx, e.localPosition.dy);
          drawPath.value.lineTo(e.localPosition.dx, e.localPosition.dy);
          drawPath.notifyListeners();
          submitTimer.value?.cancel();
          submitTimer.value = null;
          prevPoint.value = Offset(e.localPosition.dx, e.localPosition.dy);
          startPoint.value = Offset(e.localPosition.dx, e.localPosition.dy);
          submitTimer.value = Timer(const Duration(milliseconds: 200), () {
            if (!drew.value) {
              drawPath.value.reset();
              drawPath.value.moveTo(e.localPosition.dx, e.localPosition.dy);
            }
          });
        },
        onPointerMove: (e) {
          if (!drew.value && (e.localPosition.distanceSquared - startPoint.value!.distanceSquared).abs() < 10000) return;
          submitTimer.value?.cancel();
          submitTimer.value = null;
          drew.value = true;
          drawPath.value.quadraticBezierTo(
            ((prevPoint.value?.dx ?? e.localPosition.dx) + e.localPosition.dx) / 2,
            ((prevPoint.value?.dy ?? e.localPosition.dy) + e.localPosition.dy) / 2,
            e.localPosition.dx,
            e.localPosition.dy,
          );
          drawPath.notifyListeners();
          prevPoint.value = Offset(e.localPosition.dx, e.localPosition.dy);
        },
        onPointerUp: (e) {
          if (drew.value) {
            submitTimer.value = Timer(const Duration(seconds: 1), onSubmitDrawing);
          }
        },
        child: Container(
          height: 325,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          color: Colors.black,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: keyboardOpacityAC,
                builder: (context, child) {
                  return Opacity(
                    opacity: (1 - keyboardOpacityAC.value) * 0.8 + 0.2,
                    child: IgnorePointer(
                      ignoring: drew.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final row in numRow)
                          EmojiKeyboardKey(
                            symbol: row,
                            width: 36,
                            height: 40,
                            onPressed: () => onKeyPressed(row),
                            margin: const EdgeInsets.all(4),
                          ),
                      ],
                    ),
                    for (final row in qwertyRows)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final symbol in row)
                            EmojiKeyboardKey(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              symbol: symbol,
                              width: symbol.length > 1 ? 60 : 36,
                              height: 50,
                              onPressed: () => onKeyPressed(symbol),
                            ),
                        ],
                      ),
                    EmojiKeyboardKey(
                      symbol: "SPACE",
                      onPressed: () => onKeyPressed("SPACE"),
                      width: 400,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    ),
                  ],
                ),
              ),
              if (drew.value)
                CustomPaint(
                  painter: _PathPainter(
                    path: drawPath.value,
                    strokeSize: 10,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class EmojiKeyboardKey extends HookConsumerWidget {
  const EmojiKeyboardKey({
    super.key,
    required this.symbol,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.margin,
  });

  final String symbol;
  final void Function() onPressed;
  final double width;
  final double height;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbolWidget = switch (symbol) {
      "BS" => const Icon(Icons.backspace, size: 25, color: Colors.white),
      "SPACE" => const Icon(Icons.space_bar, size: 30, color: Colors.white),
      "SHIFT" => const Icon(Icons.arrow_upward, size: 25, color: Colors.white),
      _ => Text(
          symbol,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 22,
              ),
        ),
    };
    return Flexible(
      child: Container(
        // width: width,
        constraints: BoxConstraints(
          // minWidth: 10,
          maxWidth: width,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 45, 45, 45),
          borderRadius: BorderRadius.circular(5),
        ),
        margin: margin,
        height: height,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: onPressed,
            child: Center(
              child: symbolWidget,
            ),
          ),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.path,
    required this.color,
    required this.strokeSize,
  });

  final Paint _paint = Paint();
  final Path path;
  final Color color;
  final double strokeSize;

  @override
  void paint(Canvas canvas, Size size) {
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeSize
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class EmojiText extends StatelessWidget {
  const EmojiText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildText(this.text),
    );
  }

  TextSpan _buildText(String text) {
    final children = <TextSpan>[];
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...
      final isEmoji = current > 255;
      final shouldBreak = isEmoji ? (x) => x <= 255 : (x) => x > 255;

      final chunk = <int>[];
      while (!shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }

      children.add(
        TextSpan(
          text: String.fromCharCodes(chunk),
          style: TextStyle(
            fontFamily: isEmoji ? 'WhatsappEmojis' : 'Roboto',
            color: Colors.black,
          ),
        ),
      );
    }

    // return TextSpan(text: "aaaaaaaaaa");
    return TextSpan(children: children);
  }
}
