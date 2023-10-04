import 'package:flutter/material.dart';
import 'package:video_player/video_carousel.dart';
import 'package:video_player/youtube_player_widget.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Video Player Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final String title;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            YouTubeWebView(
              videoId: "IyFZznAk69U",
              height: 800.0,
              width: 600,
              onVideoStatusChanged: (status) {
                if (status == 'PLAYING') {
                  // Display Snackbar for Playing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('The video is playing.'),
                    ),
                  );
                } else if (status == 'PAUSED') {
                  // Display Snackbar for Paused
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('The video is paused.'),
                    ),
                  );
                } else if (status == 'ENDED') {
                  // Display Snackbar for Ended
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('The video has ended.'),
                    ),
                  );
                } else if (status == 'ERROR') {
                  // Display Snackbar for Error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('An error has occurred.'),
                    ),
                  );
                }
              },
            ),
             const SizedBox(height: 20,),
            const SizedBox(
              height: 610, // You can adjust this height
              child: VideoCarousel(videoIds: ['qXMclHmVNKU','OyBdngSh9os','3zDx4mJMFw8','DQDdPt1UUSw'],), // Your VideoCarousel widget
            ),
            const SizedBox(height: 300,),

          ],
        ),
      ),
    );
  }
}
