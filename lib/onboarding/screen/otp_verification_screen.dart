import 'package:bookish/onboarding/controller/otp_verification_controller.dart';
import 'package:bookish/uikit/bookish_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../uikit/bookish_color.dart';

class OtpVerificationScreen extends GetView<OtpVerificationController> {
  static String routeName = "/otp-verification";

  @override
  Widget build(BuildContext context) {
    BookishColor theme = Theme.of(context).extension<BookishColor>()!;
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text("Verification code"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    "Please enter the OTP sent on your phone",
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.r,
                        color: theme.primaryText),
                  )
                ],
              ),
              SizedBox(
                height: 4.r,
              ),
              Text(
                "${controller.phoneNumber}",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.r,
                    color: theme.primaryText),
              ),
              SizedBox(height: 32.r),
              OtpInputBox(),
              SizedBox(
                height: 32.r,
              ),
              SizedBox(
                  height: 50.r,
                  width: 140.r,
                  child: Obx(() {
                    final bool canSubmit = controller.canSubmitOtp &&
                        !controller.isLoading.value;
                    return ElevatedButton.icon(
                      onPressed: canSubmit
                          ? () =>
                              controller.verifyOtp(controller.otpCode.value)
                          : null,
                      icon: controller.otpSubmitButtonState.value ==
                              ButtonState.LOADING
                          ? _showLoader()
                          : Container(),
                      label: const Text('Submit'),
                      style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          backgroundColor: WidgetStateProperty.all<Color>(
                            canSubmit ? Colors.teal : Colors.teal.shade200,
                          )),
                    );
                  })),
              SizedBox(
                height: 24.r,
              ),
              Text(
                "Didn't receive OTP ?",
                style: GoogleFonts.roboto(
                    color: theme.secondaryText,
                    fontSize: 14.r,
                    fontWeight: FontWeight.normal),
              ),
              Obx(
                () => TextButton(
                    onPressed: controller.resendButtonState.value ==
                            ButtonState.ENABLED
                        ? controller.resendOtp
                        : null,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                          color: controller.resendButtonState.value ==
                                  ButtonState.DISABLED
                              ? Colors.grey
                              : Colors.blueAccent),
                    )),
              ),
              SizedBox(
                height: 24.r,
              ),
              if (controller.isLoading.value) ...[CircularProgressIndicator()]
            ],
          ),
        ),
      ),
    );
  }

  Widget _showLoader() {
    return Container(
      width: 24.r,
      height: 24.r,
      padding: EdgeInsets.all(2.r),
      child: const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 3,
      ),
    );
  }
}

class OtpInputBox extends GetView<OtpVerificationController> {
  @override
  Widget build(BuildContext context) {
    final BookishColor theme = Theme.of(context).extension<BookishColor>()!;
    final BookishTextStyle textStyle =
        Theme.of(context).extension<BookishTextStyle>()!;
    final defaultTheme = PinTheme(
        width: 56.r,
        height: 56.r,
        textStyle: textStyle.formNumber(theme.primaryText),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.borderColor),
        ));

    return Obx(
      () {
        return Pinput(
          length: 6,
          controller: controller.otpEditController,
          focusNode: controller.otpFocus,
          defaultPinTheme: defaultTheme.copyWith(
              textStyle: textStyle.formNumber(
                  controller.otpVerificationState.value ==
                          OtpVerificationState.FAILED
                      ? theme.errorColor
                      : controller.otpCode.value.isNotEmpty &&
                              controller.otpVerificationState.value ==
                                  OtpVerificationState.SUCCESS
                          ? theme.successColor
                          : theme.primaryText),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: controller.otpVerificationState.value ==
                          OtpVerificationState.FAILED
                      ? theme.errorColor
                      : controller.otpCode.value.isNotEmpty &&
                              controller.otpVerificationState.value ==
                                  OtpVerificationState.SUCCESS
                          ? theme.successColor
                          : theme.borderColor,
                ),
              )),
          separatorBuilder: (index) => SizedBox(width: 12.r),
          onChanged: (value) {
            controller.otpCode.value = value;
            if (value.length == 6 && controller.hasVerificationId) {
              controller.verifyOtp(value);
            }
          },
          onCompleted: (value) {
            controller.otpCode.value = value;
            if (value.length == 6 && controller.hasVerificationId) {
              controller.verifyOtp(value);
            }
          },
          focusedPinTheme: defaultTheme.copyWith(
              decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: controller.otpVerificationState.value ==
                        OtpVerificationState.FAILED
                    ? theme.errorColor
                    : theme.focusBorder),
          )),
        );
      },
    );
  }
}
