import 'package:baobabe_0_2/core/widgets/business_card.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_sections.dart';
import 'package:flutter/material.dart';

/// Une ligne de deux tuiles ; la dernière peut rester seule.
class BusinessSearchRow extends StatelessWidget {
  const BusinessSearchRow({super.key, required this.left, this.right});

  final Business left;
  final Business? right;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BusinessCard.tile(
            business: left,
            onTap: () => openBusiness(context, left),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: right == null
              ? const SizedBox.shrink()
              : BusinessCard.tile(
                  business: right!,
                  onTap: () => openBusiness(context, right!),
                ),
        ),
      ],
    ),
  );
}
