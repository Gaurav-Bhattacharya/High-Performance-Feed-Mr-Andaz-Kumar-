import 'package:flutter/material.dart';
import 'package:high_performance_feed/post.dart';
import 'package:high_performance_feed/serviceProvider.dart';
import 'package:riverpod/src/framework.dart';
import 'package:riverpod/src/providers/legacy/state_notifier_provider.dart';
class DetailScreen extends StatelessWidget {
  final Post post;
  const DetailScreen({super.key, required this.post});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Details"),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: post.id,
                child: Image.network(
                  post.media_thumb_url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Image.network(
                post.media_mobile_url, 
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            label: const Text("Download "),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Download started..."))
              );
              serviceProvider.downloadRawImage(post.media_raw_url, post.id);
            },
          ),
        ],
      ),
    );
  }

}

extension on StateNotifierProvider<ServiceProvider, AsyncValue<List<Post>>> {
  void downloadRawImage(String media_raw_url, String id) {}
}