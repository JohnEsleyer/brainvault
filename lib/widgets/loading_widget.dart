import 'package:brainvault/widgets/blinking_fade_widget.dart';
import 'package:flutter/material.dart';

import '../colors.dart';



class LoadingIndicatorWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool isReadView; 
  final bool isStudy;

  const LoadingIndicatorWidget({
    required this.child,
    required this.isLoading,
    this.isReadView = false,
    this.isStudy = false,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? BlinkingFadeWidget(
          child: MediaQuery.of(context).size.width < 650 ? 
          // Portrait view
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: palette[2],
            ),
            width: double.maxFinite,
            height: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    color: const Color.fromARGB(97, 59, 59, 59),
                  ),
                ),
                for (int i=0;i<2;i++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: const Color.fromARGB(97, 59, 59, 59),
                  ),
                ),
              ],
            ),
          ) : 
          // Landscape view
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: palette[2],
            ),
            width: isStudy ? double.maxFinite :  300,
            height: isReadView ? MediaQuery.of(context).size.height * 0.89 : 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    color: const Color.fromARGB(97, 59, 59, 59),
                  ),
                ),
                for (int i=0;i<2;i++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 10,
     
                    color: const Color.fromARGB(97, 59, 59, 59),
                  ),
                ),
              ],
            ),
          ),
        )
        : child;
  }
}
