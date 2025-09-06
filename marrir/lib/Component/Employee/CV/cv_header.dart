import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/layout/employee_header.dart';

class CvHeader extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;
  final double? completionPercent; // 0..1 (optional override)
  final VoidCallback onMenuTap; // Add menu callback

  const CvHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onMenuTap,
    this.completionPercent,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2433);
    const Color subtitleColor = Color(0xFF8A94A6);
    const Color cardBg = Colors.white;
    const Color shadowColor = Color(0x11000000);
    const Color completedDot = Color.fromRGBO(138, 194, 210, 1);
    const Color activeDot = Color(0xFF7E3EA1);
    final Color upcomingDot = const Color(0xFFBFC7D4).withOpacity(0.5);
    const Color activeText = activeDot;
    const Color upcomingText = Color(0xFF98A2B3);
    const Color completedText = Color(0xFF667085);

    final List<String> stepTitles = [
      "Passport",
      "ID Info",
      "Personal",
      "Address",
      "Summary",
      "Education",
      "Photo",
      "Experience",
      "References",
      "Additional",
    ];

    final int clampedTotal = totalSteps.clamp(1, stepTitles.length);
    final int clampedCurrent = currentStep.clamp(1, clampedTotal);

    int startIndex = clampedCurrent - 3;
    if (startIndex < 0) startIndex = 0;
    if (startIndex > clampedTotal - 5) startIndex = clampedTotal - 5;
    if (clampedTotal <= 5) startIndex = 0;
    final int endIndexExclusive = (startIndex + 5).clamp(0, clampedTotal);
    final visibleSteps = stepTitles.sublist(startIndex, endIndexExclusive);

    final double percent =
        completionPercent ?? (clampedCurrent / clampedTotal).clamp(0.0, 1.0);
    final String percentLabel = "${(percent * 100).round()}% Complete";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Top Row with menu + welcome + notification ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              // --- Menu button fixed ---
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onMenuTap, // this now works via Builder
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: UnevenHamburgerIcon(
                        color: Color(0xFF111111),
                        lineThickness: 2,
                        gap: 5,
                        topLength: 14,
                        middleLength: 22,
                        bottomLength: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
              // --- Notification button also tappable ---
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.notifications_none,
                      size: 22,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- CV title and subtitle ---
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Curriculum Vitae",
            style: TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: titleColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Educational Background & Experience",
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // --- Steps Card ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                children: [
                  // Steps Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(visibleSteps.length, (index) {
                      final int stepNumber = startIndex + index + 1;
                      final bool isActive = stepNumber == clampedCurrent;
                      final bool isCompleted = stepNumber < clampedCurrent;

                      final Color dotBg = isCompleted
                          ? completedDot
                          : isActive
                              ? activeDot
                              : upcomingDot;
                      final Color dotTextColor = (isActive || isCompleted)
                          ? Colors.white
                          : const Color(0xFF5B6472);

                      return Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Circle Step
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: dotBg,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "$stepNumber",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: dotTextColor,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            // Step Label
                            Text(
                              visibleSteps[index],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isCompleted
                                    ? completedText
                                    : isActive
                                        ? activeText
                                        : upcomingText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  // --- Continuous Underline (Progress Bar) ---
                  Stack(
                    children: [
                      // Background line (gray)
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: upcomingDot,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Foreground line (completed + active)
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: clampedCurrent / clampedTotal,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          decoration: BoxDecoration(
                            color: activeDot,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Percent Label
                  Text(
                    percentLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A94A6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
