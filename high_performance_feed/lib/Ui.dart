import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:high_performance_feed/Postcard.dart';
import 'package:high_performance_feed/serviceProvider.dart';

class Ui extends ConsumerWidget{
  const Ui({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref)
   {
    Future.microtask(() {
    final notifier = ref.read(serviceProvider.notifier);

    if (ref.read(serviceProvider).value == null) {
       notifier.initialLoadFeed();
    }
  });

    final ProviderState=ref.watch(serviceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Performance Feed'),
        centerTitle: true,
      ),
      body: ProviderState.when(
        data: (posts) {
          if(posts.isEmpty){
            return const Center(child: Text('No posts to display'));
          }
          return RefreshIndicator(onRefresh: ()async{
            await ref.read(serviceProvider.notifier).initialLoadFeed();
          }, child: ListView.builder(itemBuilder:   (context, index) {
            if(index==posts.length-1){
              ref.read(serviceProvider.notifier).loadMoreFeed();
            }
            return PostCard(post: posts[index]);
          },itemCount: posts.length,),);
        },
        loading: () => Center(child: const CircularProgressIndicator()),
        error: (e, st) => Text("Error: $e"),
      ),
    );
  } 
}