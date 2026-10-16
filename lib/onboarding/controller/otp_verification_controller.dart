import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:network_service/data/reader.dart';
import 'package:network_service/util/user_store.dart';

import '../../home/screens/home_screen.dart';
import '../../util/utility.dart';
import '../data/onboarding_repository.dart';

enum ButtonState { ENABLED, DISABLED, LOADING }

enum OtpVerificationState { IN_PROGRESS, SUCCESS, FAILED }

class OtpVerificationController extends GetxController {
  final String? phoneNumber;
  IOnboardingRepository onboardingRepository;

  OtpVerificationController(
      {this.phoneNumber, required this.onboardingRepository});

  final TextEditingController otpEditController = TextEditingController();
  final FocusNode otpFocus = FocusNode();

  RxBool _isLoading = false.obs;
  RxBool get isLoading => _isLoading;

  RxString otpCode = "".obs;
  Timer? _otpTimer;

  Rxn<OtpVerificationState> otpVerificationState = Rxn();

  final RxString _verificationId = ''.obs;

  ValueNotifier<int>? timerSecValListener;

  int get timerSeconds => 30;

  Rx<ButtonState> resendButtonState = Rx(ButtonState.DISABLED);
  Rx<ButtonState> otpSubmitButtonState = Rx(ButtonState.DISABLED);

  bool get hasVerificationId => _verificationId.value.isNotEmpty;

  bool get canSubmitOtp =>
      hasVerificationId &&
      otpCode.value.length == 6 &&
      otpSubmitButtonState.value != ButtonState.LOADING;

  @override
  onInit() async {
    _verifyPhoneNumber();
    _startOTPTimer();
    super.onInit();
  }

  Future<void> _verifyPhoneNumber() async {
    _verificationId.value = '';
    otpSubmitButtonState.value = ButtonState.DISABLED;
    final String normalizedPhone =
        '+91${(phoneNumber ?? '').replaceAll(RegExp(r'\s+'), '')}';
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: normalizedPhone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('FirebaseAuth: $e');
        _verificationId.value = '';
        otpSubmitButtonState.value = ButtonState.DISABLED;
        final BuildContext? context = Get.context;
        if (context != null) {
          Utility.showSnackBar(
            context,
            e.message?.isNotEmpty == true
                ? e.message!
                : 'Could not send OTP. Check App Check / network and try Resend.',
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('FirebaseAuth: Code sent..$resendToken');
        _verificationId.value = verificationId;
        _refreshSubmitButtonState();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('FirebaseAuth: VerificationId...$verificationId');
        if (verificationId.isNotEmpty) {
          _verificationId.value = verificationId;
          _refreshSubmitButtonState();
        }
      },
    );
  }

  void _refreshSubmitButtonState() {
    if (otpSubmitButtonState.value == ButtonState.LOADING) {
      return;
    }
    otpSubmitButtonState.value =
        canSubmitOtp ? ButtonState.ENABLED : ButtonState.DISABLED;
  }

  void _startOTPTimer() {
    resetError();
    timerSecValListener = ValueNotifier(timerSeconds);
    if (_otpTimer?.isActive ?? false) _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == timerSeconds + 1) {
        resendButtonState.value = ButtonState.ENABLED;
        timer.cancel();
      } else {
        timerSecValListener?.value--;
      }
    });
  }

  void verifyOtp(String code) async {
    otpCode.value = code;
    _refreshSubmitButtonState();
    if (code.isEmpty || code.length != 6) {
      return;
    }
    if (otpSubmitButtonState.value == ButtonState.LOADING) {
      return;
    }
    if (!hasVerificationId) {
      return;
    }
    otpSubmitButtonState.value = ButtonState.LOADING;
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId.value,
        smsCode: otpCode.value,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      otpVerificationState.value = OtpVerificationState.IN_PROGRESS;
      _onLoggedInSuccess();
    } on FirebaseException catch (e) {
      debugPrint(e.message);
      otpVerificationState.value = OtpVerificationState.FAILED;
      otpSubmitButtonState.value = ButtonState.ENABLED;
      final BuildContext? context = Get.context;
      if (context != null) {
        Utility.showSnackBar(
          context,
          e.message?.isNotEmpty == true
              ? e.message!
              : 'Something went wrong, please try later.',
        );
      }
    } catch (e) {
      debugPrint('$e');
      otpVerificationState.value = OtpVerificationState.FAILED;
      otpSubmitButtonState.value = ButtonState.ENABLED;
      final BuildContext? context = Get.context;
      if (context != null) {
        Utility.showSnackBar(
          context,
          'Could not verify OTP. Wait for SMS session, then try again.',
        );
      }
    }
  }

  void _onLoggedInSuccess() async {
    otpVerificationState.value = OtpVerificationState.SUCCESS;
    UserStore.setUserLoggedIn(true);
    final payload = await _getUserPayload();
    onboardingRepository.loginUser(payload).then((response) {
      _isLoading.value = false;
      _saveUserDetails(response.data);
      Get.offAll(HomeScreen());
    }).onError((e, s) {
      _isLoading.value = false;
      debugPrint("$e : $s");
    });
  }

  void _saveUserDetails(UserData? userData) {
    if (userData == null) return;
    UserStore.saveUser(userData.user!);
    UserStore.setUserId(userData.user?.userId ?? "");
    if (userData.token != null && userData.token?.isNotEmpty == true) {
      UserStore.setAuthToken(userData.token ?? "");
    }
  }

  Future<Map<String, dynamic>> _getUserPayload() async {
    String userId = await UserStore.getUserId();
    return <String, dynamic>{
      if (userId.isNotEmpty) 'userId': userId,
      'privacy': 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'connections': 0,
      'phoneNumber': phoneNumber,
    };
  }

  void resendOtp() {
    _isLoading.value = true;
    resendButtonState.value = ButtonState.DISABLED;
    _verifyPhoneNumber();
    _startOTPTimer();
  }

  void resetError() {
    otpVerificationState.value = OtpVerificationState.IN_PROGRESS;
    otpEditController.clear();
  }

  @override
  void onClose() {
    otpEditController.clear();
    otpEditController.dispose();
    otpFocus.dispose();
    _otpTimer?.cancel();
    super.onClose();
  }
}
