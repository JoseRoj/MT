import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void customToast(String message, BuildContext context, String type) {
  type == "isError"
      ? showToast(message,
          context: context,
          animation: StyledToastAnimation.slideFromTopFade,
          position: StyledToastPosition.bottom,
          animDuration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
          backgroundColor: Color.fromARGB(255, 243, 54, 54),
          textStyle: TextStyle(color: const Color.fromARGB(255, 40, 40, 40)))
      : showToast(message,
          context: context,
          animation: StyledToastAnimation.slideFromTopFade,
          position: StyledToastPosition.bottom,
          animDuration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
          backgroundColor: Color.fromARGB(255, 112, 222, 136),
          textStyle: TextStyle(color: const Color.fromARGB(255, 40, 40, 40)));
}
