import 'dart:async';

import 'package:payment_approval/features/payments/data/data_sources/payments_api.dart';
import 'package:payment_approval/features/payments/data/models/payment_json.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';

/// The single source of truth for payments on this device.
///
/// Every change is published as a whole [PaymentsSnapshot], so the list, the
/// Home summary and the details screen always show the same state.
class PaymentsRepository {
  PaymentsRepository({required PaymentsApi api}) : _api = api;

  final PaymentsApi _api;
  final _changes = StreamController<PaymentsSnapshot>.broadcast();
  PaymentsSnapshot? _snapshot;

  /// Replays the latest snapshot to each new listener, then emits every change.
  /// Nothing is emitted until [load] has succeeded.
  Stream<PaymentsSnapshot> watch() => Stream.multi((controller) {
    final current = _snapshot;
    if (current != null) controller.add(current);

    final subscription = _changes.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = subscription.cancel;
  });

  /// Fetches the server state and publishes it. Throws if a request fails or
  /// any item is malformed, so a partial list is never shown as complete.
  Future<void> load() async {
    final [paymentsJson, requestsJson] = await Future.wait([
      _api.fetchPayments(),
      _api.fetchPendingRequests(),
    ]);

    _publish(
      PaymentsSnapshot(
        payments: paymentsJson.map(paymentFromJson),
        pendingRequests: requestsJson.map(paymentRequestFromJson),
      ),
    );
  }

  /// Asks the server for a new incoming request and adds it to the pending ones.
  Future<PaymentRequest> createDebugRequest() async {
    _requireSnapshot();
    final request = paymentRequestFromJson(await _api.createDebugRequest());
    _publish(_requireSnapshot().withPendingRequest(request));

    return request;
  }

  /// Submits [decision] and returns the full payment the server sends back.
  ///
  /// The request leaves the pending list and the payment joins the list in one
  /// snapshot. If the server no longer has the request, it's dropped from the
  /// pending list too, and the [RequestUnavailableException] is rethrown.
  Future<Payment> decide(PaymentRequest request, PaymentStatus decision) async {
    _requireSnapshot();
    try {
      final payment = paymentFromJson(
        await _api.submitDecision(requestId: request.id, decision: paymentStatusToJson(decision)),
      );
      if (payment.id != request.id) {
        throw FormatException('Decision response belongs to another payment', payment.id);
      }

      _publish(_requireSnapshot().withDecidedPayment(payment));

      return payment;
    } on RequestUnavailableException {
      _publish(_requireSnapshot().withoutPendingRequest(request.id));
      rethrow;
    }
  }

  Future<void> dispose() => _changes.close();

  PaymentsSnapshot _requireSnapshot() =>
      _snapshot ?? (throw StateError('Payments have not been loaded yet'));

  void _publish(PaymentsSnapshot snapshot) {
    _snapshot = snapshot;
    _changes.add(snapshot);
  }
}
