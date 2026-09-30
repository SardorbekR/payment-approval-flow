/// The backend contract, as JSON. A real app would implement it over HTTP
abstract interface class PaymentsDataSource {
  Future<List<Map<String, Object?>>> fetchPayments();

  Future<List<Map<String, Object?>>> fetchPendingRequests();

  Future<Map<String, Object?>> createDebugRequest();

  /// Repeating a recorded decision returns the same payment, so a retry is safe
  Future<Map<String, Object?>> submitDecision({
    required String requestId,
    required String decision,
  });
}

/// Unknown, or decided the other way (a 404 or 409 on a real server)
class RequestUnavailableException implements Exception {
  const RequestUnavailableException(this.requestId);

  final String requestId;

  @override
  String toString() => 'RequestUnavailableException: $requestId';
}
