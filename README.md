1.  GPU & Rendering Protection 
    To handle the "heavy BoxShadow" requirement without dropping frames, I implemented:

a)  RepaintBoundary: Wrapped each PostCard to isolate the complex shadow rendering. This            prevents the entire list from re-painting when only one element changes, keeping the UI at      steady 60 FPS during fast scrolls.

b)  Custom Shadow Optimization: Balanced blur radius and spread to meet aesthetic requirements      while maintaining GPU efficiency.

2. RAM & Memory Management 
   To prevent Out-Of-Memory (OOM) crashes with high-resolution images:
   Image Caching: Utilized memCacheWidth and memCacheHeight to downsample images at the engine     level. This ensures that a 4K image only occupies enough RAM to fill its display container      (e.g., 400px wide).
   Tiered Loading: Implemented a three-tier loading strategy (Thumbnail → Mobile → Raw) to         protect cellular data and minimize initial heap memory usage.

3. Advanced State & Interaction 
a) Optimistic UI: Used Riverpod StateNotifier to provide instant user feedback for "Likes." The    UI updates immediately before the backend call is even initiated.
   The Spam Clicker (Debouncing): Implemented a 600ms debounce timer. If a user taps the like      button rapidly 15 times, the UI remains responsive, but only one final RPC call is sent to      Supabase.

b) Offline Revert: Built a robust try-catch mechanism. If the network call fails (e.g., Wi-Fi      is   off), the state automatically "snaps back" to the previous count and color, accompanied    by a    user-friendly SnackBar notification.

4.Tech Stack:-
  Framework: Flutter
  State Management: Riverpod
  Backend: Supabase (PostgreSQL + RPC)
  Networking: HTTP with Streamed Response for large downloads
