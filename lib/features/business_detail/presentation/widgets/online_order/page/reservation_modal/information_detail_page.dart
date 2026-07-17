import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class InformationDetailPage extends StatelessWidget {
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
  final VoidCallback? onContinue;

  const InformationDetailPage({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Vos informations de réservation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildTextField("Nom complet", "Votre nom complet", fullNameController,
              icon: Icons.person, isRequired: true),

          _buildTextField("Numéro de téléphone", "Entrez votre numéro", phoneController,
              icon: Icons.phone, keyboardType: TextInputType.phone, isRequired: true),

          Row(
            children: [
              Expanded(
                child: _buildDateOrTimePicker(
                  context,
                  "Date d'arrivée",
                  "Sélectionnez la date",
                  Icons.calendar_today,
                  date != null ? "${date!.day}/${date!.month}/${date!.year}" : "",
                  onPickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateOrTimePicker(
                  context,
                  "Heure d'arrivée",
                  "Sélectionnez l'heure",
                  Icons.access_time,
                  time != null ? time!.format(context) : "",
                  onPickTime,
                ),
              ),
            ],
          ),

          _buildTextField("Nombre de personnes", "Combien de personnes", peopleController,
              icon: Icons.people, keyboardType: TextInputType.number, isRequired: true),

          _buildTextField("Notes", "Ex: Besoin de 2 chaises bébé...", notesController,
              icon: Icons.note, maxLines: 3),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue ? onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              child: const Text(
                "Continuer",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType, int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: Colors.grey[50],
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) => onFieldChanged(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateOrTimePicker(BuildContext context, String label, String hint, IconData icon,
      String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(icon, size: 20),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              controller: TextEditingController(text: value),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
