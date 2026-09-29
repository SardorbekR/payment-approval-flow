/// Payments backend contract, as the JSON it exchanges
///
/// The app uses `InMemoryPaymentsDataSource`. A real client would implement it over HTTP with no
/// changes above the data layer
abstract interface class PaymentsDataSource {
  /// Decided payments with full details
  Future<List<Map<String, Object?>>> fetchPayments();

  /// Requests waiting for a decision, with a masked recipient and no amount
  Future<List<Map<String, Object?>>> fetchPendingRequests();

  /// Makes the server send this device a new request, like a push would. Only the debug button uses
  /// it
  Future<Map<String, Object?>> createDebugRequest();

  /// Records [decision] ("approved" or "rejected") and returns the full payment
  ///
  /// Repeating a recorded decision returns the same payment, so a retry is safe. Throws
  /// [RequestUnavailableException] if the request is unknown or was decided the other way
  Future<Map<String, Object?>> submitDecision({
    required String requestId,
    required String decision,
  });
}

/// The request is unknown or was decided the other way (a 404 or 409 from a real server)
class RequestUnavailableException implements Exception {
  const RequestUnavailableException(this.requestId);

  final String requestId;

  @override
  String toString() => 'RequestUnavailableException: $requestId';
}
