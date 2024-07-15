import 'dart:io';
import 'package:demo/Button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PagerPage(),
    );
  }
}

class PagerPage extends StatefulWidget {
  const PagerPage({Key? key}) : super(key: key);

  @override
  State<PagerPage> createState() => _PagerPageState();
}

class _PagerPageState extends State<PagerPage> {
  List<File> _imageFiles = [];
  List<File> _audioFiles = [];
  List<File> _pdfFiles = [];
  List<File> _videoFiles = [];
  int _validCount = 0;
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _pickFiles() async {
    if (_validCount >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 6 Files Are Only Permited')));
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'mp3',
        'wav',
        'pdf',
        'mp4',
        'mkv'
      ],
    );

    if (result != null) {
      List<File> pickedFiles = result.paths.map((path) => File(path!)).toList();
      File demoFile;
      for (int i = 0; i < pickedFiles.length; i++) {
        demoFile = pickedFiles[i];
        if (demoFile.path.toLowerCase().endsWith('mp4') ||
            demoFile.path.toLowerCase().endsWith('mkv')) {
          int fileSizeInBytes = await demoFile.length();
          if ((fileSizeInBytes / (1024 * 1024)) > 25) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File size can\'t exceeds 25MB')));
            return;
          }
        }
      }

      setState(() {
        _validCount++;
        _imageFiles.addAll(pickedFiles.where((file) =>
            file.path.toLowerCase().endsWith('.jpg') ||
            file.path.toLowerCase().endsWith('.jpeg') ||
            file.path.toLowerCase().endsWith('.png')));

        _audioFiles.addAll(pickedFiles.where((file) =>
            file.path.toLowerCase().endsWith('.mp3') ||
            file.path.toLowerCase().endsWith('.wav')));

        _pdfFiles.addAll(pickedFiles
            .where((file) => file.path.toLowerCase().endsWith('.pdf')));

        _videoFiles.addAll(pickedFiles.where((file) =>
            file.path.toLowerCase().endsWith('.mp4') ||
            file.path.toLowerCase().endsWith('.mkv')));
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 110, 186, 249),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 75, 134),
        title: Text(
          'File Picker',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton(
          //     onPressed: _pickFiles,
          //     child: const Text(
          //       'Pick Files',
          //       style: TextStyle(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Buttom(
              textTitle: 'Pick Files',
              onTap: _pickFiles,
            ),
          ),
          TextButton.icon(
              onPressed: () {
                setState(() {
                  _imageFiles.clear();
                  _videoFiles.clear();
                  _audioFiles.clear();
                  _pdfFiles.clear();
                  _validCount = 0;
                });
              },
              icon: Icon(Icons.delete_outline, color: Colors.red),
              label: Text(
                'Clear All',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                itemCount: _imageFiles.length +
                    _audioFiles.length +
                    _pdfFiles.length +
                    _videoFiles.length,
                itemBuilder: (context, index) {
                  if (index < _imageFiles.length) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext ctx) {
                                return ImageViewPage(image: _imageFiles[index]);
                              }));
                            },
                            child: Image.file(
                              _imageFiles[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _imageFiles.removeAt(index);
                                _validCount--;
                              });
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (index < _imageFiles.length + _audioFiles.length) {
                    final audioIndex = index - _imageFiles.length;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AudioPlayerPage(
                                      file: _audioFiles[audioIndex]),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.audiotrack, size: 50),
                                    Text('Audio File ${audioIndex + 1}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _audioFiles.removeAt(audioIndex);
                                _validCount--;
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    );
                  } else if (index <
                      _imageFiles.length +
                          _audioFiles.length +
                          _pdfFiles.length) {
                    final pdfIndex =
                        index - _imageFiles.length - _audioFiles.length;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PDFViewerPage(file: _pdfFiles[pdfIndex]),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.picture_as_pdf,
                                        size: 50, color: Colors.red),
                                    Text('PDF File ${pdfIndex + 1}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _pdfFiles.removeAt(pdfIndex);
                                  _validCount--;
                                });
                              },
                              icon: const Icon(Icons.delete,
                                  color: Colors.black)),
                        )
                      ],
                    );
                  } else {
                    final videoIndex = index -
                        _imageFiles.length -
                        _audioFiles.length -
                        _pdfFiles.length;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerPage(
                                    filePath: _videoFiles[videoIndex].path,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.grey[400],
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.videocam, size: 50),
                                    Text('Video File ${videoIndex + 1}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _videoFiles.removeAt(videoIndex);
                                _validCount--;
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.black),
                          ),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final File file;

  const PDFViewerPage({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}

class AudioPlayerPage extends StatefulWidget {
  final File file;

  const AudioPlayerPage({Key? key, required this.file}) : super(key: key);

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setSourceDeviceFile(widget.file.path);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  Image.asset('assets/Images/vecteezy_music-note_1200839.png'),
            ),
            const SizedBox(
              height: 50,
            ),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                final newPosition = Duration(seconds: value.toInt());
                await _audioPlayer.seek(newPosition);
                await _audioPlayer.resume();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(position)),
                  Text(formatTime(duration - position)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 64,
                  onPressed: () async {
                    if (isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.resume();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class ImageViewPage extends StatelessWidget {
  File image;
  ImageViewPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Image View',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              image,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255)),
                ))
          ],
        ),
      )),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String filePath;

  VideoPlayerPage({required this.filePath});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {
          duration = _controller.value.duration;
        });
      });

    _controller.addListener(() {
      setState(() {
        position = _controller.value.position;
        isPlaying = _controller.value.isPlaying;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            const SizedBox(height: 20),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                final newPosition = Duration(seconds: value.toInt());
                await _controller.seekTo(newPosition);
                if (!isPlaying) {
                  await _controller.play();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTimeVideo(position)),
                  Text(formatTimeVideo(duration - position)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 64,
                  onPressed: () async {
                    if (isPlaying) {
                      await _controller.pause();
                    } else {
                      await _controller.play();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatTimeVideo(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
