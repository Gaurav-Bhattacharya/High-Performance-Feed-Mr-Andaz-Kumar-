import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:high_performance_feed/post.dart';
import 'service.dart';
final serviceProvider=StateNotifierProvider<ServiceProvider,AsyncValue<List<Post>>>((ref){
  final apiService=ApiService(baseUrl: "https://fqmevrwgnlnublaicuzo.supabase.co/rest/v1");
  return ServiceProvider(apiService);
});
class ServiceProvider extends StateNotifier<AsyncValue<List<Post>>> {
  final ApiService api;
  ServiceProvider(this.api) : super(const AsyncValue.loading());
  int _currentOffset = 0;
  Timer? _debounceTimer;
  Future<void> initialLoadFeed() async {
    state = const AsyncValue.loading();
    try {
     final List<Post> posts=await api.fetchPosts(0, 10);
      state = AsyncValue.data(posts);
      _currentOffset = 10;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadMoreFeed() async {
    if (state.value == null) return;
    try {
      final List<Post> newposts = await api.fetchPosts(_currentOffset, 10);
      state = AsyncValue.data([...state.value!, ...newposts]);
      _currentOffset += 10;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }



  Future<void> toggleLike(String postId,String userId) async {
    if(state.value==null) return;
    final List<Post> previousPosts = List.from(state.value!);
    state=AsyncValue.data(state.value!.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          like_count: post.isLiked ? post.like_count - 1 : post.like_count + 1,
        );
      }
      return post;
    }).toList());

   _debounceTimer?.cancel();
   _debounceTimer=Timer(const Duration(milliseconds: 600), () async {
     try {
       await api.likePost(postId, userId);
     } catch (e) {
       state =AsyncValue.data(previousPosts);
       print("Network error: Reverting Like state.");
     }
   });

  }

}