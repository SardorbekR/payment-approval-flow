import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:payment_approval/features/payments/data/data_sources/payments_api.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';

import '../../../payments/payments_seed.dart';

class MockPaymentsRepository extends Mock implements PaymentsRepository {}

class MockDeviceAuthenticator extends Mock implements DeviceAuthenticator {}

void main() {
  late MockPaymentsRepository repository;
  late MockDeviceAuthenticator authenticator;
  late Completer<DeviceAuthResult> heldPrompt;

  final request = tRequest(id: 'pay_req', reference: 'PAY-40117');
  final approved = tPayment(id: 'pay_req', reference: 'PAY-40117');
  final rejected = tPayment(id: 'pay_req', reference: 'PAY-40117', status: PaymentStatus.rejected);

  const approve = ApprovalSubmitted(PaymentStatus.approved, authReason: 'Approve PAY-40117');
  const reject = ApprovalSubmitted(PaymentStatus.rejected, authReason: 'Reject PAY-40117');

  setUpAll(() {
    registerFallbackValue(tRequest());
    registerFallbackValue(PaymentStatus.approved);
  });

  setUp(() {
    repository = MockPaymentsRepository();
    authenticator = MockDeviceAuthenticator();
  });

  ApprovalBloc buildBloc() =>
      ApprovalBloc(request: request, repository: repository, authenticator: authenticator);

  void authenticateWith(DeviceAuthResult result) {
    when(
      () => authenticator.authenticate(reason: any(named: 'reason')),
    ).thenAnswer((_) async => result);
  }

  group('ApprovalSubmitted', () {
    blocTest<ApprovalBloc, ApprovalState>(
      'approves once the device confirms the owner',
      setUp: () {
        authenticateWith(DeviceAuthResult.success);
        when(() => repository.decide(request, PaymentStatus.approved))
            .thenAnswer((_) async => approved);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(approve),
      expect: () => [
        const ApprovalAuthenticating(PaymentStatus.approved),
        const ApprovalSubmitting(PaymentStatus.approved),
        ApprovalSucceeded(approved),
      ],
      verify: (_) =>
          verify(() => authenticator.authenticate(reason: 'Approve PAY-40117')).called(1),
    );

    blocTest<ApprovalBloc, ApprovalState>(
      'rejects once the device confirms the owner',
      setUp: () {
        authenticateWith(DeviceAuthResult.success);
        when(() => repository.decide(request, PaymentStatus.rejected))
            .thenAnswer((_) async => rejected);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(reject),
      expect: () => [
        const ApprovalAuthenticating(PaymentStatus.rejected),
        const ApprovalSubmitting(PaymentStatus.rejected),
        ApprovalSucceeded(rejected),
      ],
    );

    blocTest<ApprovalBloc, ApprovalState>(
      'goes back to idle without deciding when the prompt is cancelled',
      setUp: () => authenticateWith(DeviceAuthResult.cancelled),
      build: buildBloc,
      act: (bloc) => bloc.add(approve),
      expect: () => [const ApprovalAuthenticating(PaymentStatus.approved), const ApprovalIdle()],
      verify: (_) => verifyNever(() => repository.decide(any(), any())),
    );

    const authFailures = {
      DeviceAuthResult.failed: ApprovalError.authFailed,
      DeviceAuthResult.lockedOut: ApprovalError.authLockedOut,
      DeviceAuthResult.unavailable: ApprovalError.authUnavailable,
    };

    for (final MapEntry(key: result, value: error) in authFailures.entries) {
      blocTest<ApprovalBloc, ApprovalState>(
        'fails closed without deciding when authentication is ${result.name}',
        setUp: () => authenticateWith(result),
        build: buildBloc,
        act: (bloc) => bloc.add(reject),
        expect: () => [
          const ApprovalAuthenticating(PaymentStatus.rejected),
          ApprovalFailed(PaymentStatus.rejected, error),
        ],
        verify: (_) => verifyNever(() => repository.decide(any(), any())),
      );
    }

    blocTest<ApprovalBloc, ApprovalState>(
      'reports a request the server no longer has',
      setUp: () {
        authenticateWith(DeviceAuthResult.success);
        when(
          () => repository.decide(request, PaymentStatus.approved),
        ).thenThrow(const RequestUnavailableException('pay_req'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(approve),
      expect: () => [
        const ApprovalAuthenticating(PaymentStatus.approved),
        const ApprovalSubmitting(PaymentStatus.approved),
        const ApprovalFailed(PaymentStatus.approved, ApprovalError.requestUnavailable),
      ],
    );

    blocTest<ApprovalBloc, ApprovalState>(
      'authenticates again when retrying after a failed submission',
      setUp: () {
        authenticateWith(DeviceAuthResult.success);
        var attempts = 0;
        when(() => repository.decide(request, PaymentStatus.approved)).thenAnswer((_) async {
          if (attempts++ == 0) throw Exception('connection lost');
          return approved;
        });
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(approve);
        await Future<void>.delayed(Duration.zero);
        bloc.add(approve);
      },
      expect: () => [
        const ApprovalAuthenticating(PaymentStatus.approved),
        const ApprovalSubmitting(PaymentStatus.approved),
        const ApprovalFailed(PaymentStatus.approved, ApprovalError.submitFailed),
        const ApprovalAuthenticating(PaymentStatus.approved),
        const ApprovalSubmitting(PaymentStatus.approved),
        ApprovalSucceeded(approved),
      ],
      errors: () => [isA<Exception>()],
      verify: (_) =>
          verify(() => authenticator.authenticate(reason: any(named: 'reason'))).called(2),
    );

    blocTest<ApprovalBloc, ApprovalState>(
      'ignores taps that arrive while a decision is in progress',
      setUp: () {
        heldPrompt = Completer<DeviceAuthResult>();
        when(
          () => authenticator.authenticate(reason: any(named: 'reason')),
        ).thenAnswer((_) => heldPrompt.future);
        when(() => repository.decide(request, any())).thenAnswer((_) async => approved);
      },
      build: buildBloc,
      act: (bloc) async {
        bloc
          ..add(approve)
          ..add(reject)
          ..add(approve);
        await Future<void>.delayed(Duration.zero);
        heldPrompt.complete(DeviceAuthResult.success);
      },
      expect: () => [
        const ApprovalAuthenticating(PaymentStatus.approved),
        const ApprovalSubmitting(PaymentStatus.approved),
        ApprovalSucceeded(approved),
      ],
      verify: (_) {
        verify(() => authenticator.authenticate(reason: any(named: 'reason'))).called(1);
        verify(() => repository.decide(request, PaymentStatus.approved)).called(1);
        verifyNever(() => repository.decide(request, PaymentStatus.rejected));
      },
    );
  });
}
