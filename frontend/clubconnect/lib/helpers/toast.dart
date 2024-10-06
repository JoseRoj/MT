import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void customToast(String message, BuildContext context, String type) {
  type == "isError"
      ? showToast(
          message,
          context: context,
          animation: StyledToastAnimation.slideFromTopFade,
          position: StyledToastPosition.bottom,
          duration: Duration(seconds: 4),
          animDuration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
          backgroundColor: Color.fromARGB(255, 230, 82, 82),
          textStyle: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        )
      : showToast(message,
          context: context,
          animation: StyledToastAnimation.slideFromTopFade,
          position: StyledToastPosition.bottom,
          duration: Duration(seconds: 4),
          animDuration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
          backgroundColor: Color.fromARGB(255, 112, 222, 136),
          textStyle: TextStyle(color: const Color.fromARGB(255, 40, 40, 40)));
}
