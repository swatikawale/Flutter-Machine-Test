import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Note {
  final String content;
  final double timestamp;

  Note({
    required this.content,
    required this.timestamp,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
        content: json['content'], timestamp: double.parse(json['timestamp']));
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timestamp': timestamp.toString(),
    };
  }
}

class NotesPage extends StatefulWidget {
  final dynamic timestamp;
  const NotesPage({Key? key, required this.timestamp}) : super(key: key);
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with WidgetsBindingObserver {
  late List<Note> _notes = [];
  final String _notesFileName = 'notes.json';
  bool _validate = false;
  double? currentTime;

  final TextEditingController _contentController = TextEditingController();
  String currentText = '';

  @override
  void initState() {
    widget.timestamp.play();
    setState(() {
      print("${widget.timestamp.value.position.inSeconds.toDouble()}");
    });
    super.initState();
    _contentController.addListener(() {});
    WidgetsBinding.instance.addObserver(this);
    _loadNotes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Container(
              padding: const EdgeInsets.all(10),
              child: Dismissible(
                key: Key(_notes[index].toString()),
                background: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete),
                ),
                onDismissed: (direction) {
                  setState(() async {
                    final directory = await getApplicationDocumentsDirectory();
                    final file = File('${directory.path}/$_notesFileName');
                    deleteNoteFromJsonFile(file.path, _notes[index]);
                  });
                },
                child: ListTile(
                  title: Container(
                      padding: EdgeInsets.all(5.0),
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 0.5),
                              ),
                              child: Text(
                                note.timestamp.toString(),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Note ${index + 1}",
                          ),
                        ],
                      )),
                  subtitle: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(note.content)),
                ),
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            print(
                'Note added at ${widget.timestamp.value..position.inSeconds.toDouble()}s');
          });
          _showInputDialog(context);
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }

  Future<void> _loadNotes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_notesFileName');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        setState(() {
          _notes = jsonList.map((e) => Note.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }

  Future<void> _saveNotes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_notesFileName');
      final jsonString = json.encode(_notes.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  void deleteNoteFromJsonFile(String filePath, Note noteToDelete) {
    // Read the JSON file
    File file = File(filePath);
    if (!file.existsSync()) {
      debugPrint('File $filePath does not exist.');
      return;
    }

    List<Note> notes = [];
    String fileContent = file.readAsStringSync();

    // Parse the JSON data into a list of Note objects
    List<dynamic> jsonData = json.decode(fileContent);
    notes = jsonData.map((item) => Note.fromJson(item)).toList();

    // Remove the desired note
    notes.removeWhere((note) =>
        note.content == noteToDelete.content &&
        note.timestamp == noteToDelete.timestamp);

    // Convert the updated list of Note objects back to JSON format
    List<Map<String, dynamic>> updatedJson =
        notes.map((note) => note.toJson()).toList();
    String updatedJsonString = json.encode(updatedJson);

    // Write the updated JSON data back to the file
    file.writeAsStringSync(updatedJsonString);

    debugPrint('Note removed from $filePath.');
  }

  void editJsonData(String filePath) {
    // Read the JSON file
    File file = File(filePath);
    if (!file.existsSync()) {
      debugPrint('File $filePath does not exist.');
      return;
    }

    // Read the JSON data from the file
    String jsonDataString = file.readAsStringSync();

    // Parse the JSON data into a Dart object (assuming it's a Map)
    Map<String, dynamic> jsonData = json.decode(jsonDataString);

    // Modify the JSON data
    jsonData['content'] = _contentController.text; // Example modification
    jsonData['timestamp'] = DateTime.timestamp();
    // Convert the modified Dart object back to JSON format
    String updatedJsonDataString = json.encode(jsonData);

    // Write the updated JSON data back to the file
    file.writeAsStringSync(updatedJsonDataString);

    debugPrint('JSON data edited and saved to $filePath.');
  }

  Future<String?> _showInputDialog(BuildContext context) async {
    String listName = '';
    return await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Note',
          ),
          content: TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'Add your note',
              errorText: _validate ? "Value Can't Be Empty " : null,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                currentText = _contentController.text;

                setState(() {
                  _contentController.text.isEmpty
                      ? _validate = true
                      : _validate = false;
                  _contentController.text.isNotEmpty ? _addNote() : null;
                  _contentController.clear();
                  _validate == true
                      ? null
                      : Navigator.of(context).pop(listName);
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addNote() {
    setState(() {
      _notes.add(Note(
        content: _contentController.text,
        timestamp: widget.timestamp.value.position.inSeconds.toDouble(),
      ));
    });
    _saveNotes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
