// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Payment Approval';

  @override
  String get navHome => 'Home';

  @override
  String get navPayments => 'Payments';

  @override
  String get homeTitle => 'Home';

  @override
  String get summaryLabel => 'Paid this month';

  @override
  String summaryApprovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count approved payments',
      one: '1 approved payment',
      zero: 'No approved payments yet',
    );
    return '$_temp0';
  }

  @override
  String summaryRejectedNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excludes $count rejected payments',
      one: 'Excludes 1 rejected payment',
    );
    return '$_temp0';
  }

  @override
  String get pendingSectionTitle => 'Waiting for your approval';

  @override
  String pendingRequestSubtitle(String reference) {
    return 'Ref $reference';
  }

  @override
  String get recentTitle => 'Recent';

  @override
  String get seeAll => 'See all';

  @override
  String get reviewAction => 'Review';

  @override
  String get noPaymentsTitle => 'No payments yet';

  @override
  String get noPaymentsMessage =>
      'Approved and rejected payments show up here. Tap the + button to simulate an incoming request.';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get paymentDetailsTitle => 'Payment details';

  @override
  String get detailsDate => 'Date';

  @override
  String get detailsReference => 'Reference';

  @override
  String get detailsNote => 'Note';

  @override
  String get detailsRejectedHint => 'Rejected, so no money moved.';

  @override
  String get copyReference => 'Copy reference';

  @override
  String get referenceCopied => 'Reference copied';

  @override
  String get paymentUnavailableTitle => 'Payment unavailable';

  @override
  String get paymentUnavailableMessage =>
      'Details are only available for payments you have approved or rejected. This one is still waiting for a decision, or it doesn\'t exist.';

  @override
  String get goToPayments => 'Go to Payments';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundMessage => 'This link doesn\'t lead anywhere in the app.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get loadFailedTitle => 'Couldn\'t load payments';

  @override
  String get loadFailedMessage => 'Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String paymentDateToday(String time) {
    return 'Today, $time';
  }

  @override
  String paymentDateYesterday(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get approvalTitle => 'Approve this payment?';

  @override
  String get approvalTo => 'To';

  @override
  String get approvalAmount => 'Amount';

  @override
  String get approvalReference => 'Reference';

  @override
  String get approvalHiddenNote =>
      'The full amount and recipient are revealed only after device authentication succeeds.';

  @override
  String get approvalRecipientHidden => 'Recipient hidden until you authenticate';

  @override
  String get approvalAmountHidden => 'Amount hidden until you authenticate';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get close => 'Close';

  @override
  String get decideLater => 'Decide later';

  @override
  String get approvalAuthenticating => 'Waiting for device authentication…';

  @override
  String get approvalApproving => 'Approving…';

  @override
  String get approvalRejecting => 'Rejecting…';

  @override
  String authReasonApprove(String reference) {
    return 'Confirm it\'s you to approve payment $reference';
  }

  @override
  String authReasonReject(String reference) {
    return 'Confirm it\'s you to reject payment $reference';
  }

  @override
  String get approvalErrorAuthFailed =>
      'We couldn\'t confirm it\'s you, so nothing was approved or rejected. Try again.';

  @override
  String get approvalErrorAuthLockedOut =>
      'Too many attempts. Unlock your device with its passcode, then try again.';

  @override
  String get approvalErrorAuthUnavailable =>
      'Set up a screen lock (passcode, fingerprint or Face ID) on this device to approve or reject payments.';

  @override
  String get approvalErrorRequestUnavailable =>
      'This request is no longer available. It may have been decided elsewhere or expired.';

  @override
  String get approvalErrorSubmitFailed =>
      'We couldn\'t confirm your decision. Try again; it won\'t be applied twice.';

  @override
  String paymentApprovedSnack(String reference) {
    return 'Payment $reference approved';
  }

  @override
  String paymentRejectedSnack(String reference) {
    return 'Payment $reference rejected';
  }

  @override
  String paymentStillPendingSnack(String reference) {
    return 'Payment $reference is still waiting for your approval';
  }

  @override
  String get viewAction => 'View';

  @override
  String get incomingRequestFailedSnack => 'Couldn\'t receive a new request. Try again.';

  @override
  String get debugFabLabel => 'Simulate an incoming payment request';

  @override
  String get simulatedAuthTitle => 'Confirm it\'s you';

  @override
  String get simulatedAuthNotice =>
      'Simulated device authentication. Browsers can\'t use Face ID or fingerprint, so this dialog stands in for the system prompt. The Android app uses the real one.';

  @override
  String get simulatedAuthCancel => 'Cancel';

  @override
  String get simulatedAuthFail => 'Fail';

  @override
  String get simulatedAuthConfirm => 'Authenticate';

  @override
  String get demoTitle => 'Payment approval flow';

  @override
  String get demoSubtitle => 'A working build of the take-home, running entirely in your browser.';

  @override
  String get demoStepReceive =>
      'Tap the + button to receive a payment request. You can drag it anywhere.';

  @override
  String get demoStepDecide =>
      'Approve or reject it. The browser shows a simulated device authentication prompt.';

  @override
  String get demoStepObserve => 'Home, Payments and the details screen all update at once.';

  @override
  String get demoSessionNote =>
      'Data lives in memory, so refreshing the page starts a fresh session.';
}
