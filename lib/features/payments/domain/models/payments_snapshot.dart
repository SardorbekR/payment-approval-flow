import 'package:equatable/equatable.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';

/// Both lists in one value, so a decision moves a request into the payments in one update
class PaymentsSnapshot extends Equatable {
  PaymentsSnapshot({
    required Iterable<Payment> payments,
    required Iterable<PaymentRequest> pendingRequests,
  }) : payments = List.unmodifiable(payments.toList()..sort(_latestDecisionFirst)),
       pendingRequests = List.unmodifiable(pendingRequests.toList()..sort(_latestRequestFirst));

  /// Most recent decision first
  final List<Payment> payments;

  /// Newest first
  final List<PaymentRequest> pendingRequests;

  Payment? paymentById(String id) => payments.where((payment) => payment.id == id).firstOrNull;

  PaymentsSnapshot withPendingRequest(PaymentRequest request) => PaymentsSnapshot(
    payments: payments,
    pendingRequests: [..._requestsExcept(request.id), request],
  );

  PaymentsSnapshot withDecidedPayment(Payment payment) => PaymentsSnapshot(
    payments: [...payments.where((existing) => existing.id != payment.id), payment],
    pendingRequests: _requestsExcept(payment.id),
  );

  PaymentsSnapshot withoutPendingRequest(String requestId) =>
      PaymentsSnapshot(payments: payments, pendingRequests: _requestsExcept(requestId));

  Iterable<PaymentRequest> _requestsExcept(String requestId) =>
      pendingRequests.where((request) => request.id != requestId);

  static int _latestDecisionFirst(Payment a, Payment b) {
    final byTime = b.decidedAt.compareTo(a.decidedAt);

    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  }

  static int _latestRequestFirst(PaymentRequest a, PaymentRequest b) {
    final byTime = b.requestedAt.compareTo(a.requestedAt);

    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  }

  @override
  List<Object?> get props => [payments, pendingRequests];
}
