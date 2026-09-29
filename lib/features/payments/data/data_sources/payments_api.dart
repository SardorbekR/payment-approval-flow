/// The payments backend contract, expressed as the JSON it exchanges.
///
/// The app ships with `InMemoryPaymentsApi`. A production client would implement
/// the same contract over HTTP, and nothing above the data layer would change.
abstract interface class PaymentsApi {
  /// Decided payments with full details.
  Future<List<Map<String, Object?>>> fetchPayments();

  /// Requests waiting for a decision. The recipient is masked and the amount is withheld.
  Future<List<Map<String, Object?>>> fetchPendingRequests();

  /// Makes the server issue a new request to this device, as a push would.
  /// Only the debug button calls it.
  Future<Map<String, Object?>> createDebugRequest();

  /// Records [decision] ("approved" or "rejected") and returns the full decided payment.
  ///
  /// Throws a [RequestUnavailableException] if the request doesn't exist or was
  /// already decided.
  Future<Map<String, Object?>> submitDecision({
    required String requestId,
    required String decision,
  });
}

/// The request is unknown or no longer pending (a 404 or 409 from a real server).
class RequestUnavailableException implements Exception {
  const RequestUnavailableException(this.requestId);

  final String requestId;

  @override
  String toString() => 'RequestUnavailableException: $requestId';
}
