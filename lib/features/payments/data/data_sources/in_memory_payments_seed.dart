part of 'in_memory_payments_api.dart';

const _recipientNames = [
  'Fatima Al Zahra',
  'Omar Haddad',
  'Priya Nair',
  'Daniel Okafor',
  'Mariam Saeed',
  'Yusuf Rahman',
  'Chen Wei',
  'Hana Suzuki',
  'Rashid Al Marri',
  'Elena Petrova',
  'Khalid Nasser',
  'Noor Hassan',
];

const _paymentNotes = [
  'Office rent',
  'Contractor invoice',
  'Software subscription',
  'Marketing campaign',
  'Equipment purchase',
  'Consulting fee',
  'Travel reimbursement',
  'Legal services',
  'Event catering',
  'Freelance design',
  'Cloud hosting',
];

/// The history the demo starts with.
///
/// The first three mirror the wireframe. They are spread across the part of the
/// current month that has already passed, so they stay in "this month" even
/// minutes after midnight on the 1st and Home never opens on an empty summary.
/// The ids are fixed so their details links survive a page refresh.
List<_PaymentRecord> _seedRecords(DateTime now) {
  final localNow = now.toLocal();
  final monthStart = DateTime(localNow.year, localNow.month);
  final elapsedThisMonth = localNow.difference(monthStart);

  DateTime thisMonth(double fraction) => monthStart.add(elapsedThisMonth * fraction).toUtc();
  DateTime earlier({required int monthsAgo, required int day, required int hour}) =>
      DateTime(localNow.year, localNow.month - monthsAgo, day, hour).toUtc();

  _PaymentRecord decided({
    required String id,
    required String reference,
    required String recipientName,
    required int minorUnits,
    required String note,
    required _RecordStatus status,
    required DateTime decidedAt,
  }) => _PaymentRecord(
    id: id,
    reference: reference,
    recipientName: recipientName,
    minorUnits: minorUnits,
    note: note,
    requestedAt: decidedAt,
    status: status,
    decidedAt: decidedAt,
  );

  return [
    decided(
      id: 'pay_5e1d0a42',
      reference: 'PAY-88213',
      recipientName: 'Ahmed Khalil',
      minorUnits: 120000,
      note: 'Design retainer',
      status: _RecordStatus.approved,
      decidedAt: thisMonth(0.9),
    ),
    decided(
      id: 'pay_a93c1f07',
      reference: 'PAY-51027',
      recipientName: 'Sara Mansour',
      minorUnits: 34000,
      note: 'Team lunch',
      status: _RecordStatus.approved,
      decidedAt: thisMonth(0.6),
    ),
    decided(
      id: 'pay_71be4d90',
      reference: 'PAY-47390',
      recipientName: 'Leo Dubois',
      minorUnits: 90000,
      note: 'Duplicate invoice',
      status: _RecordStatus.rejected,
      decidedAt: thisMonth(0.3),
    ),
    decided(
      id: 'pay_0c8f2b6e',
      reference: 'PAY-30958',
      recipientName: 'Fatima Al Zahra',
      minorUnits: 475000,
      note: 'Office rent',
      status: _RecordStatus.approved,
      decidedAt: earlier(monthsAgo: 1, day: 28, hour: 10),
    ),
    decided(
      id: 'pay_d24a7c15',
      reference: 'PAY-26614',
      recipientName: 'Omar Haddad',
      minorUnits: 12550,
      note: 'Courier',
      status: _RecordStatus.approved,
      decidedAt: earlier(monthsAgo: 1, day: 12, hour: 15),
    ),
    decided(
      id: 'pay_9f63e0b8',
      reference: 'PAY-19482',
      recipientName: 'Priya Nair',
      minorUnits: 230000,
      note: 'Unrecognized vendor',
      status: _RecordStatus.rejected,
      decidedAt: earlier(monthsAgo: 2, day: 20, hour: 11),
    ),
  ];
}
