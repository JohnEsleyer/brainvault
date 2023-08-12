import 'package:brainvault/widgets/blinking_fade_widget.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingIndicatorWidget({
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? BlinkingFadeWidget(
          child: CircularProgressIndicator(color: Colors.white),
        )
        : child;
  }
}
