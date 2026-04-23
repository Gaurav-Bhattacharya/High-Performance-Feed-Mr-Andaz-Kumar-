import 'dart:convert';
import 'package:high_performance_feed/post.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
class ApiService {
   String baseUrl="https://fqmevrwgnlnublaicuzo.supabase.co/rest/v1";
   String apiKey="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxbWV2cndnbmxudWJsYWljdXpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3NzMzOTUsImV4cCI6MjA5MjM0OTM5NX0.n0wm3psAkM62Iaaf-j63M4zDEAxNRn4_bgBVE36gH4I";
   
     var postId_raw = "https://fqmevrwgnlnublaicuzo.supabase.co/storage/v1/object/public/post_media/post_1_raw.jpg";
  ApiService({required this.baseUrl});

  Future<List<Post>> fetchPosts(int offset, int limit) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?select=*&order=created_at.desc&offset=$offset&limit=$limit'),
      headers: {'apikey': apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> posts = jsonDecode(response.body);
      return posts.map((item)=>Post.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> likePost(String postId,String userId) async {
    final rpcUrl ="https://fqmevrwgnlnublaicuzo.supabase.co/rest/v1/rpc/toggle_like";
    final response = await http.post(
      Uri.parse(rpcUrl),
      headers: {
        'apikey': apiKey,
        'Prefer': 'return=minimal',
       'Content-Type': 'application/json',
       "Authorization": "Bearer $apiKey"},
      body: jsonEncode({'p_post_id': postId,
      'p_user_id': userId
      }),
    ).timeout(Duration(seconds: 5));

    if (response.statusCode != 200 && response.statusCode != 204) {
      print("RPC Status Code: ${response.statusCode}");
      print("RPC Error Body: ${response.body}");
      throw Exception('Failed to like post');
    }
  }

Future<void> downloadRawImage(String url, String postId) async {
  try {
    var status = await Permission.storage.request();
    if (!status.isGranted) return;

    final Directory? tempDir = await getExternalStorageDirectory();
    final String savePath = "${tempDir!.path}/post_$postId_raw.jpg";
    final File file = File(savePath);
    final request = http.Request('GET', Uri.parse(url));
    final http.StreamedResponse response = await http.Client().send(request);

    final int? totalBytes = response.contentLength;
    int receivedBytes = 0;

    final List<int> bytes = [];
    

    await response.stream.listen((List<int> chunk) {
      bytes.addAll(chunk);
      receivedBytes += chunk.length;

      if (totalBytes != null) {
        double progress = (receivedBytes / totalBytes) * 100;
        print("Download Progress: ${progress.toStringAsFixed(0)}%");
      }
    }).asFuture();
    await file.writeAsBytes(bytes);

    print("File saved successfully to: $savePath");
    
  } catch (e) {
    print("Error during http download: $e");
  }
}


}
