import 'package:flutter/material.dart';

class EmployeeHeader extends StatelessWidget {
  final VoidCallback onMenuTap;

  const EmployeeHeader({super.key, required this.onMenuTap});

  static const _bgWhite = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF8E8E93);
  static const _hint = Color(0xFF9BA0A6);
  static const _searchBg = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onMenuTap, // call the drawer toggle
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: UnevenHamburgerIcon(
                        color: _ink,
                        lineThickness: 2,
                        gap: 5,
                        topLength: 14,
                        middleLength: 22,
                        bottomLength: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: _muted,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Hanan',
                        style: TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: const [
                  ChatWithTranslateBadge(iconSize: 22, color: _ink),
                  SizedBox(width: 14),
                  Icon(Icons.notifications_none, size: 22, color: _ink),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _searchBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: const TextField(
                    cursorColor: _ink,
                    style: TextStyle(fontSize: 15, color: _ink),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(Icons.search, color: _hint, size: 20),
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: _hint,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const TwoLineFilterIcon(
                color: _ink,
                width: 26,
                lineThickness: 2.0,
                gap: 8,
                knobRadius: 3.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- Existing custom widgets remain unchanged ----------
class UnevenHamburgerIcon extends StatelessWidget {
  final Color color;
  final double lineThickness;
  final double gap;
  final double topLength;
  final double middleLength;
  final double bottomLength;
  final bool roundedEnds;

  const UnevenHamburgerIcon({
    super.key,
    required this.color,
    this.lineThickness = 2,
    this.gap = 5,
    this.topLength = 14,
    this.middleLength = 22,
    this.bottomLength = 16,
    this.roundedEnds = true,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = lineThickness * 3 + gap * 2;

    Widget bar(double width) => Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: lineThickness,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(roundedEnds ? lineThickness : 0),
        ),
      ),
    );

    return SizedBox(
      width: middleLength,
      height: totalHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(topLength),
          SizedBox(height: gap),
          bar(middleLength),
          SizedBox(height: gap),
          bar(bottomLength),
        ],
      ),
    );
  }
}

// ChatWithTranslateBadge & TwoLineFilterIcon remain the same as your original code
class ChatWithTranslateBadge extends StatelessWidget {
  final double iconSize;
  final Color color;

  const ChatWithTranslateBadge({
    super.key,
    required this.iconSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Icon(Icons.chat_bubble_outline, size: iconSize, color: color),
        Positioned(
          right: -2,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 1),
                  Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TwoLineFilterIcon extends StatelessWidget {
  final Color color;
  final double width;
  final double lineThickness;
  final double gap;
  final double knobRadius;

  const TwoLineFilterIcon({
    super.key,
    required this.color,
    this.width = 26,
    this.lineThickness = 2.0,
    this.gap = 8.0,
    this.knobRadius = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final height = lineThickness * 2 + gap;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TwoLineFilterPainter(
          color: color,
          t: lineThickness,
          gap: gap,
          knobR: knobRadius,
        ),
      ),
    );
  }
}

class _TwoLineFilterPainter extends CustomPainter {
  final Color color;
  final double t;
  final double gap;
  final double knobR;

  _TwoLineFilterPainter({
    required this.color,
    required this.t,
    required this.gap,
    required this.knobR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = color
      ..strokeWidth = t
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final yTop = t / 2;
    final yBot = yTop + t + gap;

    canvas.drawLine(Offset(0, yTop), Offset(size.width, yTop), paintLine);
    canvas.drawLine(Offset(0, yBot), Offset(size.width, yBot), paintLine);

    canvas.drawCircle(Offset(size.width - knobR - 1, yTop), knobR, paintFill);
    canvas.drawCircle(Offset(knobR + 1, yBot), knobR, paintFill);
  }

  @override
  bool shouldRepaint(covariant _TwoLineFilterPainter oldDelegate) {
    return color != oldDelegate.color ||
        t != oldDelegate.t ||
        gap != oldDelegate.gap ||
        knobR != oldDelegate.knobR;
  }
}
