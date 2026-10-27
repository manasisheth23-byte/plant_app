class ScanResult {
  final bool isSuccess;
  final String message;
  final String? title;

  ScanResult({
    required this.isSuccess,
    required this.message,
    this.title,
  });
}