import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FarmManager'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @livestock.
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get livestock;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @no_cows_found.
  ///
  /// In en, this message translates to:
  /// **'No cows found'**
  String get no_cows_found;

  /// No description provided for @cow_name.
  ///
  /// In en, this message translates to:
  /// **'Cow Name'**
  String get cow_name;

  /// No description provided for @delete_cow.
  ///
  /// In en, this message translates to:
  /// **'Delete Cow'**
  String get delete_cow;

  /// No description provided for @delete_cow_conf.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this cow'**
  String get delete_cow_conf;

  /// No description provided for @cow_deleted.
  ///
  /// In en, this message translates to:
  /// **'Cow deleted'**
  String get cow_deleted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get sign_out;

  /// No description provided for @email_sent.
  ///
  /// In en, this message translates to:
  /// **'Email has been sent'**
  String get email_sent;

  /// No description provided for @email_sent_text1.
  ///
  /// In en, this message translates to:
  /// **'An email with instructions to reset your password has been sent to '**
  String get email_sent_text1;

  /// No description provided for @email_sent_text2.
  ///
  /// In en, this message translates to:
  /// **'. Please check your inbox and follow the link to create a new password.'**
  String get email_sent_text2;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get back_to_login;

  /// No description provided for @email_not_correct.
  ///
  /// In en, this message translates to:
  /// **'Email not correct'**
  String get email_not_correct;

  /// No description provided for @click_to_edit.
  ///
  /// In en, this message translates to:
  /// **'Click to edit'**
  String get click_to_edit;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password'**
  String get forgot_password;

  /// No description provided for @reset_passwd_text1.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address associated with your account and we\'ll send an email with instructions to reset your password.'**
  String get reset_passwd_text1;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enter_email;

  /// No description provided for @send_email.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get send_email;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @please_login.
  ///
  /// In en, this message translates to:
  /// **'Please log in to your account'**
  String get please_login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enter_password;

  /// No description provided for @incorrect_cred.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Email or Password'**
  String get incorrect_cred;

  /// No description provided for @forgot_password_question.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgot_password_question;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account'**
  String get dont_have_account;

  /// No description provided for @signup_create.
  ///
  /// In en, this message translates to:
  /// **'Sign up to create an account'**
  String get signup_create;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enter_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your Name'**
  String get enter_name;

  /// No description provided for @email_in_use.
  ///
  /// In en, this message translates to:
  /// **'This Email is already in use'**
  String get email_in_use;

  /// No description provided for @retype_password.
  ///
  /// In en, this message translates to:
  /// **'Retype Password'**
  String get retype_password;

  /// No description provided for @retype_password2.
  ///
  /// In en, this message translates to:
  /// **'Retype your Password'**
  String get retype_password2;

  /// No description provided for @diff_passwords.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get diff_passwords;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// No description provided for @have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account'**
  String get have_account;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
