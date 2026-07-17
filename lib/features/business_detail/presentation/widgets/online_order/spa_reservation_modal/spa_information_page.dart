import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SpaInformationPage extends StatelessWidget {
  final bool isSmallScreen;
  final double horizontalPadding;
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

  const SpaInformationPage({
    Key? key,
    required this.isSmallScreen,
    required this.horizontalPadding,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16), child: Text('Vos informations', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold))),
          _buildTextField("Nom complet", "Votre nom complet", fullNameController, isRequired: true),
          _buildTextField("Numéro de téléphone", "Entrez votre numéro", phoneController, keyboardType: TextInputType.phone, isRequired: true),
          if (isSmallScreen) ...[
            _buildDatePickerTile("Date du rendez-vous", appointmentDate, onPickDate),
            _buildTimePickerTile(context, "Heure du rendez-vous", appointmentTime, onPickTime),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildDatePickerTile("Date", appointmentDate, onPickDate)),
                const SizedBox(width: 10),
                Expanded(child: _buildTimePickerTile(context, "Heure", appointmentTime, onPickTime)),
              ],
            ),
          ],
          if (therapistNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Thérapeute (optionnel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: therapistNames.map((name) {
                final isSelected = selectedTherapist == name;
                return ChoiceChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) { onSelectTherapist(selected ? name : null); },
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black),
                );
              }).toList(),
            ),
          ],
          _buildTextField("Notes", "Ex: Allergies, préférences...", notesController, maxLines: 3),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue ? onContinue : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("Continuer", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1, bool isRequired = false}) {
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

  Widget _buildDatePickerTile(String label, DateTime? date, VoidCallback onTap) {
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
                prefixIcon: Icon(Icons.calendar_today, size: isSmallScreen ? 18 : 20),
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

  Widget _buildTimePickerTile(BuildContext context, String label, TimeOfDay? time, VoidCallback onTap) {
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
                hintText: "Sélectionnez l'heure",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.access_time, size: isSmallScreen ? 18 : 20),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 10 : 12),
              ),
              controller: TextEditingController(text: time != null ? time.format(context) : ""),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
      ],
    );
  }
}
