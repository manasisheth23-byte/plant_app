// This file automatically chooses the correct implementation
// depending on the platform you are building for.

// 👉 On Web: uses boldbi_dashboard_web.dart (real BoldBI)
// 👉 On Windows/Android/iOS: uses boldbi_dashboard_stub.dart (fallback message)

export 'boldbi_dashboard_web.dart' // use this when building for Web
if (dart.library.io) 'boldbi_web.dart';