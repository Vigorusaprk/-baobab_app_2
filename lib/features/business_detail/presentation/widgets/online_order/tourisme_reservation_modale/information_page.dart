import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  final bool isSmallScreen;
  final double horizontalPadding;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final DateTime? activityDate;
  final VoidCallback onPickDate;
  final int numberOfParticipants;
  final ValueChanged<int> onParticipantsChanged;
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
    required this.activityDate,
    required this.onPickDate,
    required this.numberOfParticipants,
    required this.onParticipantsChanged,
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
          Padding(padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16), child: Text('Vos informations', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold))),
          _buildTextField("Nom complet", "Votre nom complet", fullNameController, isSmallScreen: isSmallScreen, isRequired: true),
          _buildTextField("Numéro de téléphone", "Entrez votre numéro", phoneController, isSmallScreen: isSmallScreen, keyboardType: TextInputType.phone, isRequired: true),
          _buildDatePickerTile("Date de l'activité", Icons.calendar_today, activityDate, onPickDate, isSmallScreen),
          _buildCounterField("Nombre de participants", numberOfParticipants, onParticipantsChanged, min: 1, max: 20, isSmallScreen: isSmallScreen),
          _buildTextField("Notes", "Ex: Allergies, préférences...", notesController, isSmallScreen: isSmallScreen, maxLines: 3),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue ? onNext : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isSmallScreen = false, TextInputType? keyboardType, int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)), if (isRequired) Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16))]),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 10 : 12),
            filled: true,
            fillColor: Colors.grey[50],
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2.5), borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => onFieldChanged(),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildDatePickerTile(String label, IconData icon, DateTime? date, VoidCallback onTap, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)), Text(' *', style: TextStyle(color: Colors.red, fontSize: isSmallScreen ? 14 : 16))]),
        SizedBox(height: isSmallScreen ? 6 : 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Sélectionnez la date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(icon, size: isSmallScreen ? 18 : 20),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 10 : 12),
              ),
              controller: TextEditingController(text: date != null ? "${date.day}/${date.month}/${date.year}" : ""),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }

  Widget _buildCounterField(String label, int value, void Function(int) onChanged, {required int min, required int max, bool isSmallScreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: value > min ? () => onChanged(value - 1) : null, color: value > min ? AppColors.primary : Colors.grey, iconSize: isSmallScreen ? 16 : 20),
              Expanded(child: Text('$value', textAlign: TextAlign.center, style: TextStyle(fontSize: isSmallScreen ? 14 : 16))),
              IconButton(icon: const Icon(Icons.add), onPressed: value < max ? () => onChanged(value + 1) : null, color: value < max ? AppColors.primary : Colors.grey, iconSize: isSmallScreen ? 16 : 20),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }
}
