import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Approval'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid this month'**
  String get summaryLabel;

  /// No description provided for @summaryApprovedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No approved payments yet} =1{1 approved payment} other{{count} approved payments}}'**
  String summaryApprovedCount(int count);

  /// No description provided for @summaryRejectedNote.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Excludes 1 rejected payment} other{Excludes {count} rejected payments}}'**
  String summaryRejectedNote(int count);

  /// No description provided for @pendingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your approval'**
  String get pendingSectionTitle;

  /// No description provided for @pendingRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ref {reference}'**
  String pendingRequestSubtitle(String reference);

  /// No description provided for @recentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentTitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @reviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAction;

  /// No description provided for @noPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsTitle;

  /// No description provided for @noPaymentsMessage.
  ///
  /// In en, this message translates to:
  /// **'Approved and rejected payments show up here. Tap the + button to simulate an incoming request.'**
  String get noPaymentsMessage;

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @paymentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get paymentDetailsTitle;

  /// No description provided for @detailsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get detailsDate;

  /// No description provided for @detailsReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get detailsReference;

  /// No description provided for @detailsNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get detailsNote;

  /// No description provided for @detailsRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'Rejected, so no money moved.'**
  String get detailsRejectedHint;

  /// No description provided for @copyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get copyReference;

  /// No description provided for @referenceCopied.
  ///
  /// In en, this message translates to:
  /// **'Reference copied'**
  String get referenceCopied;

  /// No description provided for @paymentUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment unavailable'**
  String get paymentUnavailableTitle;

  /// No description provided for @paymentUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Details are only available for payments you have approved or rejected. This one is still waiting for a decision, or it doesn\'t exist.'**
  String get paymentUnavailableMessage;

  /// No description provided for @goToPayments.
  ///
  /// In en, this message translates to:
  /// **'Go to Payments'**
  String get goToPayments;

  /// No description provided for @pageNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This link doesn\'t lead anywhere in the app.'**
  String get pageNotFoundMessage;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @loadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load payments'**
  String get loadFailedTitle;

  /// No description provided for @loadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get loadFailedMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @paymentDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String paymentDateToday(String time);

  /// No description provided for @paymentDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String paymentDateYesterday(String time);

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String dateAndTime(String date, String time);

  /// No description provided for @approvalTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve this payment?'**
  String get approvalTitle;

  /// No description provided for @approvalTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get approvalTo;

  /// No description provided for @approvalAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get approvalAmount;

  /// No description provided for @approvalReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get approvalReference;

  /// No description provided for @approvalHiddenNote.
  ///
  /// In en, this message translates to:
  /// **'The full amount and recipient are revealed only after device authentication succeeds.'**
  String get approvalHiddenNote;

  /// No description provided for @approvalRecipientHidden.
  ///
  /// In en, this message translates to:
  /// **'Recipient hidden until you authenticate'**
  String get approvalRecipientHidden;

  /// No description provided for @approvalAmountHidden.
  ///
  /// In en, this message translates to:
  /// **'Amount hidden until you authenticate'**
  String get approvalAmountHidden;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @decideLater.
  ///
  /// In en, this message translates to:
  /// **'Decide later'**
  String get decideLater;

  /// No description provided for @approvalAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Waiting for device authentication…'**
  String get approvalAuthenticating;

  /// No description provided for @approvalApproving.
  ///
  /// In en, this message translates to:
  /// **'Approving…'**
  String get approvalApproving;

  /// No description provided for @approvalRejecting.
  ///
  /// In en, this message translates to:
  /// **'Rejecting…'**
  String get approvalRejecting;

  /// No description provided for @authReasonApprove.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to approve payment {reference}'**
  String authReasonApprove(String reference);

  /// No description provided for @authReasonReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to reject payment {reference}'**
  String authReasonReject(String reference);

  /// No description provided for @approvalErrorAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm it\'s you, so nothing was approved or rejected. Try again.'**
  String get approvalErrorAuthFailed;

  /// No description provided for @approvalErrorAuthLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Unlock your device with its passcode, then try again.'**
  String get approvalErrorAuthLockedOut;

  /// No description provided for @approvalErrorAuthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set up a screen lock (passcode, fingerprint or Face ID) on this device to approve or reject payments.'**
  String get approvalErrorAuthUnavailable;

  /// No description provided for @approvalErrorRequestUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This request is no longer available. It may have been decided elsewhere or expired.'**
  String get approvalErrorRequestUnavailable;

  /// No description provided for @approvalErrorSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm your decision. Try again; it won\'t be applied twice.'**
  String get approvalErrorSubmitFailed;

  /// No description provided for @paymentApprovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Payment {reference} approved'**
  String paymentApprovedSnack(String reference);

  /// No description provided for @paymentRejectedSnack.
  ///
  /// In en, this message translates to:
  /// **'Payment {reference} rejected'**
  String paymentRejectedSnack(String reference);

  /// No description provided for @paymentStillPendingSnack.
  ///
  /// In en, this message translates to:
  /// **'Payment {reference} is still waiting for your approval'**
  String paymentStillPendingSnack(String reference);

  /// No description provided for @viewAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewAction;

  /// No description provided for @incomingRequestFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t receive a new request. Try again.'**
  String get incomingRequestFailedSnack;

  /// No description provided for @debugFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulate an incoming payment request'**
  String get debugFabLabel;

  /// No description provided for @simulatedAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Device authentication'**
  String get simulatedAuthTitle;

  /// No description provided for @simulatedAuthNotice.
  ///
  /// In en, this message translates to:
  /// **'Simulated device authentication. Browsers can\'t use Face ID or fingerprint, so this dialog stands in for the system prompt. The Android app uses the real one.'**
  String get simulatedAuthNotice;

  /// No description provided for @simulatedAuthCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get simulatedAuthCancel;

  /// No description provided for @simulatedAuthFail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get simulatedAuthFail;

  /// No description provided for @simulatedAuthConfirm.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get simulatedAuthConfirm;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment approval flow'**
  String get demoTitle;

  /// No description provided for @demoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A working build of the take-home, running entirely in your browser.'**
  String get demoSubtitle;

  /// No description provided for @demoStepReceive.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to receive a payment request. You can drag it anywhere.'**
  String get demoStepReceive;

  /// No description provided for @demoStepDecide.
  ///
  /// In en, this message translates to:
  /// **'Approve or reject it. The browser shows a simulated device authentication prompt.'**
  String get demoStepDecide;

  /// No description provided for @demoStepObserve.
  ///
  /// In en, this message translates to:
  /// **'Home, Payments and the details screen all update at once.'**
  String get demoStepObserve;

  /// No description provided for @demoSessionNote.
  ///
  /// In en, this message translates to:
  /// **'Data lives in memory, so refreshing the page starts a fresh session.'**
  String get demoSessionNote;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
