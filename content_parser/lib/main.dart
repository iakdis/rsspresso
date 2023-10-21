import 'package:content_parser/extractors/lead-image-url/extractor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:html2md/html2md.dart' as html2md;

import 'extractors/content/extractor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // getFullContent();
  }

  Future<String?> getFullContent() async {
    const url = '';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final html = response.body;

      final extracted = GenericContentExtractor().extractAsString(
        html,
        title: 'title',
        url: url,
      );

      final markdown = html2md.convert(extracted);

      final extractedImage = GenericLeadImageUrlExtractor().extract(
        html,
        url: url,
      );

      return markdown;
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: FutureBuilder(
          future: getFullContent(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Markdown(
                data: snapshot.data!,
                selectable: true,
              );
            } else {
              return const SelectableText(
                'Content',
              );
            }
          },
        ),
      ),
    );
  }
}
