
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(FootballLiveApp());
}

class FootballLiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: MatchListPage(),
    );
  }
}

class MatchListPage extends StatelessWidget {
  final List<Map<String, String>> matches = [
    {
      'team1': 'ريال مدريد',
      'team2': 'برشلونة',
      'time': '21:00',
      'streamUrl': 'https://example.com/live1.m3u8',
    },
    {
      'team1': 'مانشستر سيتي',
      'team2': 'آرسنال',
      'time': '23:00',
      'streamUrl': 'https://example.com/live2.m3u8',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('جدول المباريات')),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            child: ListTile(
              title: Text('${match['team1']} × ${match['team2']}'),
              subtitle: Text('الساعة: ${match['time']}'),
              trailing: Icon(Icons.play_circle_fill, color: Colors.green),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(url: match['streamUrl']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _controller.play();
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل البث')),
        );
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildPlayer() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (!_controller.value.isInitialized) {
      return Center(child: Text('لا يمكن تشغيل الفيديو'));
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مشاهدة المباراة')),
      body: Center(child: buildPlayer()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
      ),
    );
  }
}
