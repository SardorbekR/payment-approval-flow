import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';

import '../../payments_seed.dart';

class MockPaymentsRepository extends Mock implements PaymentsRepository {}

void main() {
  late MockPaymentsRepository repository;
  late int maxActiveListeners;

  final initialSnapshot = PaymentsSnapshot(payments: [tPayment()], pendingRequests: const []);
  final updatedSnapshot = initialSnapshot.withPendingRequest(tRequest());

  setUp(() {
    repository = MockPaymentsRepository();
  });

  group('PaymentsStarted', () {
    blocTest<PaymentsBloc, PaymentsState>(
      'loads the payments and follows every later change',
      setUp: () {
        when(() => repository.load()).thenAnswer((_) async {});
        when(
          () => repository.watch(),
        ).thenAnswer((_) => Stream.fromIterable([initialSnapshot, updatedSnapshot]));
      },
      build: () => PaymentsBloc(repository: repository),
      act: (bloc) => bloc.add(const PaymentsStarted()),
      expect: () => [PaymentsLoaded(initialSnapshot), PaymentsLoaded(updatedSnapshot)],
    );

    blocTest<PaymentsBloc, PaymentsState>(
      'reports a failure without subscribing when loading fails',
      setUp: () {
        when(() => repository.load()).thenThrow(const FormatException('bad amount'));
      },
      build: () => PaymentsBloc(repository: repository),
      act: (bloc) => bloc.add(const PaymentsStarted()),
      expect: () => [const PaymentsLoadFailure()],
      errors: () => [isA<FormatException>()],
      verify: (_) => verifyNever(() => repository.watch()),
    );

    blocTest<PaymentsBloc, PaymentsState>(
      'ends in a failure, not an endless spinner, for any error while loading',
      setUp: () {
        when(() => repository.load()).thenThrow(StateError('unexpected'));
      },
      build: () => PaymentsBloc(repository: repository),
      act: (bloc) => bloc.add(const PaymentsStarted()),
      expect: () => [const PaymentsLoadFailure()],
      errors: () => [isA<StateError>()],
    );

    blocTest<PaymentsBloc, PaymentsState>(
      'recovers when started again after a failure',
      setUp: () {
        var attempts = 0;
        when(() => repository.load()).thenAnswer((_) async {
          if (attempts++ == 0) throw Exception('offline');
        });
        when(() => repository.watch()).thenAnswer((_) => Stream.value(initialSnapshot));
      },
      build: () => PaymentsBloc(repository: repository),
      act: (bloc) async {
        bloc.add(const PaymentsStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PaymentsStarted());
      },
      expect: () => [
        const PaymentsLoadFailure(),
        const PaymentsLoading(),
        PaymentsLoaded(initialSnapshot),
      ],
      errors: () => [isA<Exception>()],
    );

    blocTest<PaymentsBloc, PaymentsState>(
      'never follows two subscriptions at once when started again',
      setUp: () {
        var activeListeners = 0;
        maxActiveListeners = 0;
        when(() => repository.load()).thenAnswer((_) async {});
        when(() => repository.watch()).thenAnswer(
          (_) => Stream<PaymentsSnapshot>.multi((controller) {
            maxActiveListeners = max(maxActiveListeners, ++activeListeners);
            controller.onCancel = () => activeListeners--;
          }),
        );
      },
      build: () => PaymentsBloc(repository: repository),
      act: (bloc) async {
        bloc.add(const PaymentsStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PaymentsStarted());
        await Future<void>.delayed(Duration.zero);
      },
      verify: (_) {
        verify(() => repository.watch()).called(2);
        expect(maxActiveListeners, 1);
      },
    );
  });
}
