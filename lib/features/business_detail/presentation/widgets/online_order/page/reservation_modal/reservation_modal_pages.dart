import 'package:flutter/material.dart';

import 'select_table_page.dart';
import 'information_detail_page.dart';
import 'order_summary_page.dart';

class ReservationModalPages extends StatelessWidget {
  final PageController pageController;

  // Select table page
  final List<String> floors;
  final String selectedFloor;
  final ValueChanged<String> onFloorSelected;
  final String? selectedTable;
  final ValueChanged<String> onTableSelected;
  final VoidCallback? onSelectTableNext;

  // Information page
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController peopleController;
  final TextEditingController notesController;
  final DateTime? date;
  final TimeOfDay? time;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onFieldChanged;
  final bool canContinue;
  final VoidCallback onContinue;

  // Summary page
  final String businessName;
  final double subtotal;
  final double tax;
  final double grandTotal;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onEditInfo;

  const ReservationModalPages({
    Key? key,
    required this.pageController,
    required this.floors,
    required this.selectedFloor,
    required this.onFloorSelected,
    required this.selectedTable,
    required this.onTableSelected,
    required this.onSelectTableNext,
    required this.fullNameController,
    required this.phoneController,
    required this.peopleController,
    required this.notesController,
    required this.date,
    required this.time,
    required this.onPickDate,
    required this.onPickTime,
    required this.onFieldChanged,
    required this.canContinue,
    required this.onContinue,
    required this.businessName,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
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
        SelectTablePage(
          floors: floors,
          selectedFloor: selectedFloor,
          onFloorSelected: onFloorSelected,
          selectedTable: selectedTable,
          onTableSelected: onTableSelected,
          onNext: onSelectTableNext,
        ),
        InformationDetailPage(
          fullNameController: fullNameController,
          phoneController: phoneController,
          peopleController: peopleController,
          notesController: notesController,
          date: date,
          time: time,
          onPickDate: onPickDate,
          onPickTime: onPickTime,
          onFieldChanged: onFieldChanged,
          canContinue: canContinue,
          onContinue: onContinue,
        ),
        OrderSummaryPage(
          businessName: businessName,
          fullName: fullNameController.text,
          phone: phoneController.text,
          date: date,
          time: time,
          peopleText: peopleController.text,
          selectedTable: selectedTable,
          selectedFloor: selectedFloor,
          notes: notesController.text,
          subtotal: subtotal,
          tax: tax,
          grandTotal: grandTotal,
          isLoading: isLoading,
          onConfirm: onConfirm,
          onEditInfo: onEditInfo,
        ),
      ],
    );
  }
}
