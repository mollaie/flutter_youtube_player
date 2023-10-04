import 'package:flutter/material.dart';
import 'package:video_player/youtube_player_widget.dart';

class VideoCarousel extends StatelessWidget {
  final List<String> videoIds;

  const VideoCarousel({super.key, required this.videoIds});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: videoIds.length,
      itemBuilder: (context, index) {
        return Card(
          borderOnForeground: true,clipBehavior: Clip.hardEdge,
          child: YouTubeWebView(
            videoId: videoIds[index],
            height: 250,
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
        );
      },
    );
  }
}
