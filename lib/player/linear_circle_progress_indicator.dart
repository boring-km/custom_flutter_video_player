import 'package:flutter/material.dart';

class LinearCircleProgressIndicator extends ProgressIndicator {
  const LinearCircleProgressIndicator({
    Key? key,
    double? value,
    Color? backgroundColor,
    required Color color,
    required this.pointerColor,
    this.minHeight,
    String? semanticsLabel,
    String? semanticsValue,

  }) : assert(minHeight == null || minHeight > 0),
        super(
        key: key,
        value: value,
        backgroundColor: backgroundColor,
        color: color,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      );

  final Color pointerColor;
  final double? minHeight;

  Widget _buildSemanticsWrapper({
    required BuildContext context,
    required Widget child,
  }) {
    String? expandedSemanticsValue = semanticsValue;
    if (value != null) {
      expandedSemanticsValue ??= '${(value! * 100).round()}%';
    }
    return Semantics(
      label: semanticsLabel,
      value: expandedSemanticsValue,
      child: child,
    );
  }

  @override
  State<LinearCircleProgressIndicator> createState() => _LinearCircleProgressIndicatorState();
}

const int _kIndeterminateLinearDuration = 1800;

class _LinearProgressIndicatorPainter extends CustomPainter {
  const _LinearProgressIndicatorPainter({
    required this.backgroundColor,
    required this.valueColor,
    required this.pointerColor,
    required this.value,
    required this.animationValue,
    required this.textDirection,
  });

  final Color backgroundColor;
  final Color valueColor;
  final Color pointerColor;
  final double? value;
  final double animationValue;
  final TextDirection textDirection;

  // static const Curve lineHead = Interval(
  //     0.0,
  //     end);

  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Offset(0.0, 10.0) & Size(size.width, size.height/2), paint);

    paint.color = valueColor;

    void drawBar(double x, double width) {
      if (width <= 0.0) {
        return;
      }

      final double left;
      switch (textDirection) {
        case TextDirection.rtl:
          left = size.width - width - x;
          break;
        case TextDirection.ltr:
          left = x;
          break;
      }
      canvas.drawRect(Offset(left, 10.0) & Size(width, size.height/2), paint);
    }

    void drawPoint(double x, double radius) {
      if (radius <= 0.0) {
        return;
      }
      final double left = x - radius;
      final Paint pointerPaint = Paint()
        ..color = pointerColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
          RRect.fromLTRBXY(left, 5.0, left + radius * 2, radius * 2 + 5.0, radius, radius), pointerPaint);
    }

    if (value != null) {
      drawBar(0.0, size.width * value!.clamp(0.0, 1.0));
      drawPoint(size.width * value!.clamp(0.0, 1.0), 10);
    } else {
      final double x1 = size.width * line1Tail.transform(animationValue);
      final double width1 = size.width * line1Head.transform(animationValue) - x1;

      final double x2 = size.width * line2Tail.transform(animationValue);
      final double width2 = size.width * line2Head.transform(animationValue) - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
      drawPoint(0.0, 10);
    }
  }

  @override
  bool shouldRepaint(_LinearProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor
        || oldPainter.valueColor != valueColor
        || oldPainter.value != value
        || oldPainter.animationValue != animationValue
        || oldPainter.textDirection != textDirection;
  }
}

class _LinearCircleProgressIndicatorState extends State<LinearCircleProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
      vsync: this,
    );
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LinearCircleProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context, double animationValue, TextDirection textDirection) {
    final ProgressIndicatorThemeData indicatorTheme = ProgressIndicatorTheme.of(context);
    final Color trackColor =
        widget.backgroundColor ??
            indicatorTheme.linearTrackColor ??
            Theme.of(context).colorScheme.background;
    final double minHeight = widget.minHeight ?? indicatorTheme.linearMinHeight ?? 4.0;

    return widget._buildSemanticsWrapper(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          minHeight: minHeight,
        ),
        child: CustomPaint(
          painter: _LinearProgressIndicatorPainter(
            backgroundColor: trackColor,
            valueColor: widget.color!,
            pointerColor: widget.pointerColor,
            value: widget.value, // may be null
            animationValue: animationValue,
            textDirection: textDirection,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (widget.value != null) {
      return _buildIndicator(context, _controller.value, textDirection);
    }

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget? child) {
        return _buildIndicator(context, _controller.value, textDirection);
      },
    );
  }
}
