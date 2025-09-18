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

class CVMain extends StatefulWidget {
  final String token; // 👈 Add token

  const CVMain({super.key, required this.token}); // 👈 require token

  @override
  State<CVMain> createState() => _CVMainState();
}

class _CVMainState extends State<CVMain> {
  int currentStep = 1;
  final int totalSteps = 10;
  int _selectedMenuIndex = -1; // -1 = CV steps, >=0 = menu page

  late List<Widget> steps;

  @override
  void initState() {
    super.initState();
    steps = [
      StepPassport(
        onSuccess: () {
          // Handle successful upload
          print("Passport uploaded successfully!");
        },
        onNextStep: () {
          // Navigate to next step
          setState(() {
            currentStep += 1;
          });
        },
      ),
      StepID(
        onSuccess: () {
          print("Infromation Added successfully!");
        },
        onNextStep: () {
          // Navigate to next step
          setState(() {
            currentStep += 1;
          });
        },
      ),
      PersonalInformationStep(
        onSuccess: () {
          print("Infromation Added successfully!");
        },
        onNextStep: () {
          // Navigate to next step
          setState(() {
            currentStep += 1;
          });
        },
      ),
      AddressInformationStep(
        onSuccess: () {
          print("Infromation Added successfully!");
        },
        onNextStep: () {
          // Navigate to next step
          setState(() {
            currentStep += 1;
          });
        },
      ),
      SummaryStep(
        onSuccess: () {
          print("Infromation Added successfully!");
        },
        onNextStep: () {
          // Navigate to next step
          setState(() {
            currentStep += 1;
          });
        },
      ),
      EducationalDataForm(
        onSuccess: () {
          print("Infromation Added successfully!");
        },
        onNextStep: () {
          // Navigate to next step
          setState(() {
            currentStep += 1;
          });
        },
      ),
      const PhotoAndLanguageForm(),
      const PreviousExperienceForm(),
      const ReferencesForm(),
      const AdditionalContactForm(),
    ];
  }

  void nextStep() {
    if (currentStep < totalSteps) setState(() => currentStep++);
  }

  void prevStep() {
    if (currentStep > 1) setState(() => currentStep--);
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
        token: widget.token, // 👈 Pass token here
        selectedIndex: _selectedMenuIndex,
        closeDrawer: () => Navigator.of(context).pop(),
        onMenuSelected: (index) {
          setState(() => _selectedMenuIndex = index);
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: _selectedMenuIndex == -1
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Builder(
                      builder: (context) => CvHeader(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onMenuTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
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
                    ),
                  ],
                ),
              )
            : _getSelectedScreen(),
      ),
    );
  }
}
