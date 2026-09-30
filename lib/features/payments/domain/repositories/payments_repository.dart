import 'package:payment_approval/features/payments/data/data_sources/payments_data_source.dart';
import 'package:payment_approval/features/payments/data/models/payment_json.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';
import 'package:rxdart/rxdart.dart';

/// Single source of truth for payments
class PaymentsRepository {
  PaymentsRepository({required PaymentsDataSource dataSource}) : _dataSource = dataSource;

  final PaymentsDataSource _dataSource;
  final _snapshots = BehaviorSubject<PaymentsSnapshot>();

  /// The latest snapshot first, then every change
  Stream<PaymentsSnapshot> watch() => _snapshots.stream;

  /// Throws on any malformed item, so a partial list is never shown
  Future<void> load() async {
    final [paymentsJson, requestsJson] = await Future.wait([
      _dataSource.fetchPayments(),
      _dataSource.fetchPendingRequests(),
    ]);

    _publish(
      PaymentsSnapshot(
        payments: paymentsJson.map(paymentFromJson),
        pendingRequests: requestsJson.map(paymentRequestFromJson),
      ),
    );
  }

  Future<PaymentRequest> createDebugRequest() async {
    _requireSnapshot();
    final request = paymentRequestFromJson(await _dataSource.createDebugRequest());
    _publish(_requireSnapshot().withPendingRequest(request));

    return request;
  }

  /// On failure it reloads first, since the server may have recorded the decision anyway
  Future<Payment> decide(PaymentRequest request, PaymentStatus decision) async {
    _requireSnapshot();
    try {
      final payment = paymentFromJson(
        await _dataSource.submitDecision(
          requestId: request.id,
          decision: paymentStatusToJson(decision),
        ),
      );
      if (payment.id != request.id) {
        throw FormatException('Decision response belongs to another payment', payment.id);
      }

      _publish(_requireSnapshot().withDecidedPayment(payment));

      return payment;
    } on RequestUnavailableException {
      await _catchUpWithServer(orDrop: request.id);
      rethrow;
    } on Exception {
      await _catchUpWithServer();
      rethrow;
    }
  }

  bool isPending(String requestId) =>
      _latest?.pendingRequests.any((request) => request.id == requestId) ?? false;

  Future<void> dispose() => _snapshots.close();

  /// If the reload fails too, at least drop [orDrop], which the server no longer has
  Future<void> _catchUpWithServer({String? orDrop}) async {
    try {
      await load();
    } on Exception {
      if (orDrop != null) _publish(_requireSnapshot().withoutPendingRequest(orDrop));
    }
  }

  PaymentsSnapshot? get _latest => _snapshots.valueOrNull;

  PaymentsSnapshot _requireSnapshot() =>
      _latest ?? (throw StateError('Payments have not been loaded yet'));

  void _publish(PaymentsSnapshot snapshot) => _snapshots.add(snapshot);
}
