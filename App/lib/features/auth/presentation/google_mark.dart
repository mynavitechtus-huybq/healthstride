import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/google.svg',
      width: size,
      height: size,
      semanticsLabel: 'Google',
    );
  }
}
