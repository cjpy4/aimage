import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';


// Path to your image

// Getting the base64 string
getBase64(filePath) async {
//final documents = await getApplicationDocumentsDirectory();
//final externalDocumentsDirectory = await getExternalStorageDirectory();
//final externalStorageDirectories = await getExternalStorageDirectories();
//final appCacheDirectory = await getApplicationCacheDirectory();
// final appLibraryDirectory = await getLibraryDirectory();
//print(documents);
//print(externalDocumentsDirectory);
//print(externalStorageDirectories);
//print(appCacheDirectory);
// print(appLibraryDirectory);
//var imagePath = path.join(filePath, 'IMG_3203 (1).jpg');
final fileBytes = await File(filePath).readAsBytes();
return base64Encode(fileBytes);
}

Future<http.Response> processImg(img) async {
  return http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer '
    },
    body: jsonEncode({
     'model': 'gpt-4-vision-preview',
      'messages': [
    {
      'role': 'user',
      'content': [
        {
          'type': 'text',
          'text': 'Please Transcribe the text in this image, word for word.'
        },
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$img'
          }
        }
      ]
    }
  ],
  'max_tokens': 300
    }
  ));
} 



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with 'flutter run'. You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke 'hot reload' (save your changes or press the 'hot
        // reload' button in a Flutter-supported IDE, or press 'r' if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File ? _pickedImage;
  String ? extractedText;
final ImagePicker picker = ImagePicker();

Future<void> _onImageButtonPressed() async {
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  print(image!.path);
  setState(() {
    _pickedImage = File(image!.path);
  });
}
Future<void> _onUploadButtonPressed() async {
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  setState(() {
    _pickedImage = File(image!.path);
  });
  print(image!.path);
  var bytes= await getBase64(image!.path);
  processImg(bytes).then((value) {
    print(value.body);
    setState(() {
      extractedText = jsonDecode(value.body)['choices'][0]['message']['content'];
    });
  });
}

Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content: Image.file(_pickedImage!),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
             
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
             Container(
             margin: const EdgeInsets.all(20),
             padding: const EdgeInsets.all(15),
             decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(20),
             ),
             child: _pickedImage != null ? Image.file(_pickedImage!) : const Text('No Image Selected'),
             ),
             Container(
             margin: const EdgeInsets.all(20),
             padding: const EdgeInsets.all(15),
             decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(20),
             ),
             child: extractedText == null ? Text('no image yet') : Text(extractedText!),
             ),
              ElevatedButton(onPressed: () => _dialogBuilder(context), child: const Text('Upload Image')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onImageButtonPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
