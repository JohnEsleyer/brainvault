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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
            
                decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: palette[2],
                                        ),
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height * 0.20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        color: Color.fromARGB(255, 41, 41, 41),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width * 0.5,
                        color: Color.fromARGB(255, 41, 41, 41),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width * 0.80,
                        color: Color.fromARGB(255, 41, 41, 41),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : child;
  }
}
