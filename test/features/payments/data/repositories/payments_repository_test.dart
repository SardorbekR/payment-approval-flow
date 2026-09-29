import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/features/payments/data/data_sources/payments_api.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';

import '../../payments_seed.dart';

class MockPaymentsApi extends Mock implements PaymentsApi {}

void main() {
  late MockPaymentsApi api;
  late PaymentsRepository repository;

  void stubDecision(Map<String, Object?> response) {
    when(
      () => api.submitDecision(
        requestId: any(named: 'requestId'),
        decision: any(named: 'decision'),
      ),
    ).thenAnswer((_) async => response);
  }

  /// Collects every snapshot the repository publishes from now on.
  Future<List<PaymentsSnapshot>> recordSnapshots() async {
    final snapshots = <PaymentsSnapshot>[];
    final subscription = repository.watch().listen(snapshots.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    return snapshots;
  }

  setUp(() {
    api = MockPaymentsApi();
    repository = PaymentsRepository(api: api);

    when(() => api.fetchPayments()).thenAnswer((_) async => [tPaymentJson()]);
    when(() => api.fetchPendingRequests()).thenAnswer((_) async => [tRequestJson()]);
  });

  tearDown(() => repository.dispose());

  group('load', () {
    test('publishes the payments and pending requests from the server', () async {
      await repository.load();

      final snapshot = await repository.watch().first;
      expect(snapshot.payments.single.id, 'pay_5e1d0a42');
      expect(snapshot.pendingRequests.single.id, 'pay_7f3a9c01');
    });

    test('publishes nothing when any item is malformed', () async {
      when(() => api.fetchPayments()).thenAnswer(
        (_) async => [
          tPaymentJson(),
          {...tPaymentJson(id: 'pay_broken'), 'amount': null},
        ],
      );
      final snapshots = await recordSnapshots();

      await expectLater(repository.load(), throwsFormatException);
      await pumpEventQueue();

      expect(snapshots, isEmpty);
    });
  });

  group('watch', () {
    test('emits nothing before the first load', () async {
      final snapshots = await recordSnapshots();

      expect(snapshots, isEmpty);
    });

    test('replays the latest snapshot to a listener that subscribes late', () async {
      when(() => api.createDebugRequest()).thenAnswer((_) async => tRequestJson(id: 'pay_late'));
      await repository.load();
      await repository.createDebugRequest();

      final snapshot = await repository.watch().first;

      expect(snapshot.pendingRequests.map((request) => request.id), contains('pay_late'));
    });
  });

  group('createDebugRequest', () {
    test('adds the new request to the pending ones', () async {
      when(() => api.createDebugRequest()).thenAnswer((_) async => tRequestJson(id: 'pay_new'));
      await repository.load();
      final snapshots = await recordSnapshots();

      final request = await repository.createDebugRequest();
      await pumpEventQueue();

      expect(request.id, 'pay_new');
      expect(snapshots.last.pendingRequests, hasLength(2));
    });

    test('fails before the first load without asking the server', () async {
      await expectLater(repository.createDebugRequest(), throwsStateError);

      verifyNever(() => api.createDebugRequest());
    });
  });

  group('decide', () {
    test('sends the decision in the format the API expects', () async {
      stubDecision(tPaymentJson(id: 'pay_7f3a9c01', status: 'rejected'));
      await repository.load();

      await repository.decide(tRequest(id: 'pay_7f3a9c01'), PaymentStatus.rejected);

      verify(() => api.submitDecision(requestId: 'pay_7f3a9c01', decision: 'rejected')).called(1);
    });

    test('moves the request into the payments in a single update', () async {
      stubDecision(tPaymentJson(id: 'pay_7f3a9c01', decidedAt: '2026-09-29T08:20:00.000Z'));
      await repository.load();
      final snapshots = await recordSnapshots();

      final payment = await repository.decide(
        tRequest(id: 'pay_7f3a9c01'),
        PaymentStatus.approved,
      );
      await pumpEventQueue();

      expect(snapshots, hasLength(2));
      expect(snapshots.last.pendingRequests, isEmpty);
      expect(snapshots.last.payments.first, payment);
    });

    test('drops a request the server no longer has and rethrows', () async {
      when(
        () => api.submitDecision(
          requestId: any(named: 'requestId'),
          decision: any(named: 'decision'),
        ),
      ).thenThrow(const RequestUnavailableException('pay_7f3a9c01'));
      await repository.load();
      final snapshots = await recordSnapshots();

      await expectLater(
        repository.decide(tRequest(id: 'pay_7f3a9c01'), PaymentStatus.approved),
        throwsA(isA<RequestUnavailableException>()),
      );
      await pumpEventQueue();

      expect(snapshots.last.pendingRequests, isEmpty);
      expect(snapshots.last.payments.map((payment) => payment.id), isNot(contains('pay_7f3a9c01')));
    });

    test('rejects a response that belongs to another payment', () async {
      stubDecision(tPaymentJson(id: 'pay_someone_else'));
      await repository.load();
      final snapshots = await recordSnapshots();

      await expectLater(
        repository.decide(tRequest(id: 'pay_7f3a9c01'), PaymentStatus.approved),
        throwsFormatException,
      );
      await pumpEventQueue();

      expect(snapshots, hasLength(1));
      expect(snapshots.single.pendingRequests.single.id, 'pay_7f3a9c01');
    });
  });
}
