import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:high_performance_feed/Detail.dart';
import 'package:high_performance_feed/post.dart';
import 'package:high_performance_feed/serviceProvider.dart';
class PostCard extends StatelessWidget {
 final Post post;

  const PostCard({super.key,required this.post});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child:Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(133, 0, 0, 0),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(post:post)));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: post.id,
                  child: Image.network(post.media_thumb_url, height: 200, width: double.infinity, fit: BoxFit.cover,
                  cacheWidth: 800,
                  )),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(post.id.substring(0,4), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
              trailing: Consumer(builder:   (context, ref, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : Colors.grey),
                      onPressed: () {
                        ref.read(serviceProvider.notifier).toggleLike(post.id, 'user123');
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(post.like_count.toString()),
                  ],
                );
              }),
            ),
          ],
        ),
      )
    );
  }
}