// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flutter App`
  String get title {
    return Intl.message(
      'Flutter App',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Language:`
  String get language {
    return Intl.message(
      'Language:',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to logistic trade`
  String get welcomeMessage {
    return Intl.message(
      'Welcome to Geem Logistic !',
      name: 'welcomeMessage',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get fullName {
    return Intl.message(
      'User Name',
      name: 'fullName',
      desc: '',
      args: [],
    );
  }

  /// `Your Email`
  String get Email {
    return Intl.message(
      'Your Email',
      name: 'Email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get Password {
    return Intl.message(
      'Password',
      name: 'Password',
      desc: '',
      args: [],
    );
  }

  /// `Create youe account`
  String get register {
    return Intl.message(
      'Create youe account',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have an Account ?`
  String get NoAccount {
    return Intl.message(
      'Don’t have an Account ?',
      name: 'NoAccount',
      desc: '',
      args: [],
    );
  }

  /// `Already have an Account ?`
  String get HaveAccount {
    return Intl.message(
      'Already have an Account ?',
      name: 'HaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Join to our family now !!`
  String get signupMsg {
    return Intl.message(
      'Join to our family now !!',
      name: 'signupMsg',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password ?`
  String get ForgotPassword {
    return Intl.message(
      'Forgot Password ?',
      name: 'ForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Verification Code`
  String get VerificationCode {
    return Intl.message(
      'Verification Code',
      name: 'VerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter the verification code sent to your email`
  String get EnterCode {
    return Intl.message(
      'Enter the verification code sent to your email',
      name: 'EnterCode',
      desc: '',
      args: [],
    );
  }

  /// `Entered Code:`
  String get EnteredCode {
    return Intl.message(
      'Entered Code:',
      name: 'EnteredCode',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get Verify {
    return Intl.message(
      'Verify',
      name: 'Verify',
      desc: '',
      args: [],
    );
  }

  /// `Send Code`
  String get SendCode {
    return Intl.message(
      'Send Code',
      name: 'SendCode',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get ResetPassword {
    return Intl.message(
      'Reset Password',
      name: 'ResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get Approved {
    return Intl.message(
      'Approved',
      name: 'Approved',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get Next {
    return Intl.message(
      'Next',
      name: 'Next',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get NewPasswordMsg {
    return Intl.message(
      'New Password',
      name: 'NewPasswordMsg',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your new password and confirm password`
  String get ResetMsg {
    return Intl.message(
      'Please enter your new password and confirm password',
      name: 'ResetMsg',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password `
  String get ConfirmPassword {
    return Intl.message(
      'Confirm Password ',
      name: 'ConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Update Password `
  String get UpdatePassword {
    return Intl.message(
      'Update Password ',
      name: 'UpdatePassword',
      desc: '',
      args: [],
    );
  }

  /// `Back to`
  String get BackMsg {
    return Intl.message(
      'Back to',
      name: 'BackMsg',
      desc: '',
      args: [],
    );
  }

  /// `screen`
  String get Screen {
    return Intl.message(
      'screen',
      name: 'Screen',
      desc: '',
      args: [],
    );
  }

  /// `Wrong`
  String get Wrong {
    return Intl.message(
      'Wrong',
      name: 'Wrong',
      desc: '',
      args: [],
    );
  }

  /// `The password and password confirmation do not match.`
  String get Mismatched {
    return Intl.message(
      'The password and password confirmation do not match.',
      name: 'Mismatched',
      desc: '',
      args: [],
    );
  }

  /// `Okay`
  String get OkayMsg {
    return Intl.message(
      'Okay',
      name: 'OkayMsg',
      desc: '',
      args: [],
    );
  }

  /// `Logistic Trade`
  String get AppName {
    return Intl.message(
      'Logistic Trade',
      name: 'AppName',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get Serach {
    return Intl.message(
      'Search...',
      name: 'Serach',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get Home {
    return Intl.message(
      'Home',
      name: 'Home',
      desc: '',
      args: [],
    );
  }

  /// `Add item`
  String get AddItem {
    return Intl.message(
      'Add item',
      name: 'AddItem',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get Notifications {
    return Intl.message(
      'Notifications',
      name: 'Notifications',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get Menu {
    return Intl.message(
      'Menu',
      name: 'Menu',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your full name`
  String get FullNameEmptyError {
    return Intl.message(
      'Please enter your full name',
      name: 'FullNameEmptyError',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email address`
  String get EmailEmptyError {
    return Intl.message(
      'Please enter your email address',
      name: 'EmailEmptyError',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a password`
  String get passwordEmpty {
    return Intl.message(
      'Please enter a password',
      name: 'passwordEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get ValidEmail {
    return Intl.message(
      'Please enter a valid email address',
      name: 'ValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters`
  String get ValidPassword {
    return Intl.message(
      'Password must be at least 8 characters',
      name: 'ValidPassword',
      desc: '',
      args: [],
    );
  }

  /// `Username should contain only characters`
  String get ValidUserName {
    return Intl.message(
      'Username should contain only characters',
      name: 'ValidUserName',
      desc: '',
      args: [],
    );
  }

  /// `SomeThing Went Wrong`
  String get ErrorMsg {
    return Intl.message(
      'SomeThing Went Wrong',
      name: 'ErrorMsg',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get Loading {
    return Intl.message(
      'Loading...',
      name: 'Loading',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get Camera {
    return Intl.message(
      'Camera',
      name: 'Camera',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get UploadImage {
    return Intl.message(
      'Upload Image',
      name: 'UploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Error logging in. Please check your login information.`
  String get ErrorMag {
    return Intl.message(
      'Error logging in. Please check your login information.',
      name: 'ErrorMag',
      desc: '',
      args: [],
    );
  }

  /// `Send a message...`
  String get SendMessage {
    return Intl.message(
      'Send a message...',
      name: 'SendMessage',
      desc: '',
      args: [],
    );
  }

  String get ChoosePaymentMethod {
    return Intl.message(
      'Choose Payment Method',
      name: 'ChoosePaymentMethod',
      desc: '',
      args: [],
    );
  }

  String get Profile {
    return Intl.message(
      'Profile',
      name: 'Profile',
      desc: '',
      args: [],
    );
  }
  String get Orders {
    return Intl.message(
      'Orders',
      name: 'Orders',
      desc: '',
      args: []
    );
  }
   String get month {
    return Intl.message(
      'month',
      name: 'month',
      desc: '',
      args: []
    );
  }
  String get Revenue {
    return Intl.message(
      'Revenue',
      name: 'Revenue',
      desc: '',
      args: []
    );
  }

  String get Chat {
    return Intl.message(
      'Chat',
      name: 'Chat',
      desc: '',
      args: []
    );
  }

  String get Tasks {
    return Intl.message(
      'Tasks',
      name:"Tasks",
      desc: '',
      args: []
    );
  }

  String get ManageEmployee {
    return Intl.message(
      'Manage Employee',
      name: 'ManageEmployee',
      desc: '',
      args: []
    );
  }

   String get LogOut {
    return Intl.message(
      'Log Out',
      name: 'LogOut',
      desc: '',
      args: []
    );
  }
  String get Dashboard {
    return Intl.message(
      'Dashboard',
      name: 'Dashboard',
      desc: '',
      args: []
    );
  }
   String get YourWarehouses {
    return Intl.message(
      'Warehouses',
      name: 'YourWarehouses',
      desc: '',
      args: []
    );
  }
  String get Inventory {
    return Intl.message(
      'Inventory',
      name: 'Inventory',
      desc: '',
      args: []
    );
  }
  String get SalesTrendAnalysis {
    return Intl.message(
      'Sales Trend Analysis',
      name: 'SalesTrendAnalysis',
      desc: '',
      args: []
    );
  }

  String get Employee {
    return Intl.message(
      'Employee',
      name: 'Employee',
      desc: '',
      args: []
    );
  }

  String get Products {
    return Intl.message(
      'Products',
      name: 'Products',
      desc: '',
      args: []
    );
  }
  String get Jan {
    return Intl.message(
      'Jan',
      name: 'Jan',
      desc: '',
      args: []
    );
  }
   String get Feb {
    return Intl.message(
      'Feb',
      name: 'Feb',
      desc: '',
      args: []
    );
  }
   String get Mar {
    return Intl.message(
      'Mar',
      name: 'Mar',
      desc: '',
      args: []
    );
  }
   String get Apr {
    return Intl.message(
      'Apr',
      name: 'Apr',
      desc: '',
      args: []
    );
  }
   String get May {
    return Intl.message(
      'May',
      name: 'May',
      desc: '',
      args: []
    );
  }
   String get Jun {
    return Intl.message(
      'Jun',
      name: 'Jun',
      desc: '',
      args: []
    );
  }
   String get Jul {
    return Intl.message(
      'Jul',
      name: 'Jul',
      desc: '',
      args: []
    );
  }
   String get Aug {
    return Intl.message(
      'Aug',
      name: 'Aug',
      desc: '',
      args: []
    );
  }
   String get Sep {
    return Intl.message(
      'Sep',
      name: 'Sep',
      desc: '',
      args: []
    );
  }
   String get Oct {
    return Intl.message(
      'Oct',
      name: 'Oct',
      desc: '',
      args: []
    );
  }
   String get Nov {
    return Intl.message(
      'Nov',
      name: 'Nov',
      desc: '',
      args: []
    );
  }
   String get Dec {
    return Intl.message(
      'Dec',
      name: 'Dec',
      desc: '',
      args: []
    );
  }
  String get UserName {
    return Intl.message(
      'User Name',
      name: 'UserName',
      desc: '',
      args: []
    );
  }
   String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: []
    );
  }
  String get Location {
    return Intl.message(
      'Location',
      name: 'Location',
      desc: '',
      args: []
    );
  }
  String get Update {
    return Intl.message(
      'Update',
      name: 'Update',
      desc: '',
      args: []
    );
  }

    String get other {
    return Intl.message(
      'other',
      name: 'other',
      desc: '',
      args: []
    );
  }
  String get Nablus {
    return Intl.message(
      'Nablus',
      name: 'Nablus',
      desc: '',
      args: []
    );
  }
  String get Jerusalem {
    return Intl.message(
      'Jerusalem',
      name: 'Jerusalem',
      desc: '',
      args: []
    );
  }

   String get Tulkarm {
    return Intl.message(
      'Tulkarm',
      name: 'Tulkarm',
      desc: '',
      args: []
    );
  }
   String get Qalqilya {
    return Intl.message(
      'Qalqilya',
      name: 'Qalqilya',
      desc: '',
      args: []
    );
  }
 
   String get Bethlehem {
    return Intl.message(
      'Bethlehem',
      name: 'Bethlehem',
      desc: '',
      args: []
    );
  }
   String get BeitSahour {
    return Intl.message(
      'Beit Sahour',
      name: 'Beit Sahour',
      desc: '',
      args: []
    );
  }
   String get Jericho {
    return Intl.message(
      'Jericho',
      name: 'Jericho',
      desc: '',
      args: []
    );
  }

   String get Salfit {
    return Intl.message(
      'Salfit',
      name: 'Salfit',
      desc: '',
      args: []
    );
  }
   
   String get Jenin {
    return Intl.message(
      'Jenin',
      name: 'Jenin',
      desc: '',
      args: []
    );
  }

   String get Ramallah {
    return Intl.message(
      'Ramallah',
      name: 'Ramallah',
      desc: '',
      args: []
    );
  }
   String get Al_Bireh {
    return Intl.message(
      'Al_Bireh',
      name: 'Al_Bireh',
      desc: '',
      args: []
    );
  }

   String get Hebron {
    return Intl.message(
      'Hebron',
      name: 'Hebron',
      desc: '',
      args: []
    );
  }
    String get Tubas {
    return Intl.message(
      'Tubas',
      name: 'Tubas',
      desc: '',
      args: []
    );
  }
  

}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
