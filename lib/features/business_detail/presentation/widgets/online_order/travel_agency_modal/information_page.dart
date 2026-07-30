import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  final bool isSmallScreen;
  final double horizontalPadding;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final DateTime? departureDate;
  final VoidCallback onPickDate;
  final int numberOfPassengers;
  final ValueChanged<int> onPassengersChanged;
  final bool canContinue;
  final VoidCallback? onNext;
  final VoidCallback onFieldChanged;

  const InformationPage({
    Key? key,
    required this.isSmallScreen,
    required this.horizontalPadding,
    required this.fullNameController,
    required this.phoneController,
    required this.notesController,
    required this.departureDate,
    required this.onPickDate,
    required this.numberOfPassengers,
    required this.onPassengersChanged,
    required this.canContinue,
    required this.onNext,
    required this.onFieldChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            child: Text(
              'Vos informations',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildTextField(
            "Nom complet",
            "Votre nom complet",
            fullNameController,
            isSmallScreen: isSmallScreen,
            isRequired: true,
          ),
          _buildTextField(
            "Numéro de téléphone",
            "Entrez votre numéro",
            phoneController,
            isSmallScreen: isSmallScreen,
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
          _buildDatePickerTile(
            "Date de départ",
            departureDate,
            onPickDate,
            isSmallScreen,
          ),
          _buildCounterField(
            "Nombre de passagers",
            numberOfPassengers,
            onPassengersChanged,
            min: 1,
            max: 9,
            isSmallScreen: isSmallScreen,
          ),
          _buildTextField(
            "Notes",
            "Demandes spécifiques...",
            notesController,
            isSmallScreen: isSmallScreen,
            maxLines: 3,
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Continuer",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isSmallScreen = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12,
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => onFieldChanged(),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildDatePickerTile(
    String label,
    DateTime? date,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: AppColors.error,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Sélectionnez la date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  Icons.calendar_today,
                  size: isSmallScreen ? 18 : 20,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              controller: TextEditingController(
                text: date != null
                    ? "${date.day}/${date.month}/${date.year}"
                    : "",
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildCounterField(
    String label,
    int value,
    void Function(int) onChanged, {
    required int min,
    required int max,
    bool isSmallScreen = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                color: value > min
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                color: value < max
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }
}
