import 'package:flutter/material.dart';

import 'select_treatment_page.dart';
import 'spa_information_page.dart';
import 'spa_summary_page.dart';

class SpaModalPages extends StatelessWidget {
  final PageController pageController;
  final bool isSmallScreen;
  final double horizontalPadding;

  // Select treatment page
  final List<dynamic> treatments;
  final List<String> selectedTreatments;
  final double totalAmount;
  final ValueChanged<String> onToggleTreatment;
  final VoidCallback? onSelectTreatmentNext;

  // Information page
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final DateTime? appointmentDate;
  final TimeOfDay? appointmentTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final List<String> therapistNames;
  final String? selectedTherapist;
  final ValueChanged<String?> onSelectTherapist;
  final VoidCallback onFieldChanged;
  final bool canContinue;
  final VoidCallback onContinue;

  // Summary page
  final String businessName;
  final List<Map<String, dynamic>> selectedTreatmentsWithPrices;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onEditInfo;

  const SpaModalPages({
    Key? key,
    required this.pageController,
    required this.isSmallScreen,
    required this.horizontalPadding,
    required this.treatments,
    required this.selectedTreatments,
    required this.totalAmount,
    required this.onToggleTreatment,
    required this.onSelectTreatmentNext,
    required this.fullNameController,
    required this.phoneController,
    required this.notesController,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.onPickDate,
    required this.onPickTime,
    required this.therapistNames,
    required this.selectedTherapist,
    required this.onSelectTherapist,
    required this.onFieldChanged,
    required this.canContinue,
    required this.onContinue,
    required this.businessName,
    required this.selectedTreatmentsWithPrices,
    required this.isLoading,
    required this.onConfirm,
    required this.onEditInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SelectTreatmentPage(
          isSmallScreen: isSmallScreen,
          horizontalPadding: horizontalPadding,
          treatments: treatments,
          selectedTreatments: selectedTreatments,
          totalAmount: totalAmount,
          onToggleTreatment: onToggleTreatment,
          onNext: onSelectTreatmentNext,
        ),
        SpaInformationPage(
          isSmallScreen: isSmallScreen,
          horizontalPadding: horizontalPadding,
          fullNameController: fullNameController,
          phoneController: phoneController,
          notesController: notesController,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
          onPickDate: onPickDate,
          onPickTime: onPickTime,
          therapistNames: therapistNames,
          selectedTherapist: selectedTherapist,
          onSelectTherapist: onSelectTherapist,
          onFieldChanged: onFieldChanged,
          canContinue: canContinue,
          onContinue: onContinue,
        ),
        SpaSummaryPage(
          isSmallScreen: isSmallScreen,
          horizontalPadding: horizontalPadding,
          businessName: businessName,
          fullName: fullNameController.text,
          phone: phoneController.text,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
          selectedTherapist: selectedTherapist,
          notes: notesController.text,
          selectedTreatmentsWithPrices: selectedTreatmentsWithPrices,
          totalAmount: totalAmount,
          isLoading: isLoading,
          onConfirm: onConfirm,
          onEditInfo: onEditInfo,
        ),
      ],
    );
  }
}
