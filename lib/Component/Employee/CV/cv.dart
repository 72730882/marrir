import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/CV/Steps/additional_info.dart';
import 'package:marrir/Component/Employee/CV/Steps/address.dart';
import 'package:marrir/Component/Employee/CV/Steps/education.dart';
import 'package:marrir/Component/Employee/CV/Steps/experience.dart';
import 'package:marrir/Component/Employee/CV/Steps/id_info.dart';
import 'package:marrir/Component/Employee/CV/Steps/passport.dart';
import 'package:marrir/Component/Employee/CV/Steps/personal_info.dart';
import 'package:marrir/Component/Employee/CV/Steps/photo.dart';
import 'package:marrir/Component/Employee/CV/Steps/references.dart';
import 'package:marrir/Component/Employee/CV/Steps/summary.dart';
// Import dashboard-like pages
import 'package:marrir/Component/Employee/EmployeeDashboard/dashboard.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/help.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/payment.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/promotion.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/rating.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/reserve.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/status.dart';
import 'package:marrir/Component/Employee/layout/header_drawer.dart';

import 'cv_header.dart';
import 'cv_footer.dart';

// Dashboard-like pages

class CVMain extends StatefulWidget {
  const CVMain({super.key});

  @override
  State<CVMain> createState() => _CVMainState();
}

class _CVMainState extends State<CVMain> {
  int currentStep = 1;
  final int totalSteps = 10;

  int _selectedMenuIndex = -1; // -1 = CV steps, >=0 = menu page

  final List<Widget> steps = [
    const StepPassport(),
    const StepID(),
    const PersonalInformationStep(),
    const AddressInformationStep(),
    const SummaryStep(),
    const EducationalDataForm(),
    const PhotoAndLanguageForm(),
    const PreviousExperienceForm(),
    const ReferencesForm(),
    const AdditionalContactForm(),
  ];

  void nextStep() {
    if (currentStep < totalSteps) {
      setState(() {
        currentStep++;
      });
    }
  }

  void prevStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
    }
  }

  Widget _getSelectedScreen() {
    switch (_selectedMenuIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const StatusUpdateScreen();
      case 2:
        return const RatingScreen();
      case 3:
        return const ReservesScreen();
      case 4:
        return const PromotionScreen();
      case 5:
        return const PaymentsScreen();
      case 6:
        return const HelpCenterScreen();
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: steps[currentStep - 1],
              ),
            ),
            CVFooter(
              onPrevious: prevStep,
              onNext: nextStep,
              isFirstStep: currentStep == 1,
              isLastStep: currentStep == totalSteps,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: EmployeeHeaderDrawer(
        selectedIndex: _selectedMenuIndex,
        closeDrawer: () {
          Navigator.of(context).pop();
        },
        onMenuSelected: (index) {
          setState(() {
            _selectedMenuIndex = index; // navigate to menu page
          });
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Only show header if in CV steps mode
            if (_selectedMenuIndex == -1)
              Builder(
                builder: (context) {
                  return CvHeader(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    onMenuTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            const Divider(height: 1),
            // Expanded body to fill remaining space
            Expanded(
              child: _selectedMenuIndex == -1
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          steps[currentStep - 1],
                          const SizedBox(height: 20),
                          CVFooter(
                            onPrevious: prevStep,
                            onNext: nextStep,
                            isFirstStep: currentStep == 1,
                            isLastStep: currentStep == totalSteps,
                          ),
                        ],
                      ),
                    )
                  : _getSelectedScreen(), // render menu page directly
            ),
          ],
        ),
      ),
    );
  }
}
