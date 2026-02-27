// lib/features/business/presentation/widgets/category_icons.dart
import 'package:baobabe_0_2/features/home_page/data/models/ui_category.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        String selectedCategory = 'Tout';

        if (categoryState is CategoriesLoaded) {
          selectedCategory = categoryState.selectedCategory;
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: UICategory.allCategories.length,
            itemBuilder: (context, index) {
              final uiCategory = UICategory.allCategories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategory(
                  context,
                  uiCategory,
                  selectedCategory,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategory(BuildContext context, UICategory uiCategory, String selectedCategory) {
    bool isActive = selectedCategory == uiCategory.category.displayName;

    return GestureDetector(
      onTap: () {
        context.read<CategoryBloc>().add(SelectCategory(uiCategory.category.displayName));
        context.read<BusinessBloc>().add(LoadBusinessesByCategory(uiCategory.category.displayName));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 85,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFFF5F7F9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive ? [
            BoxShadow(
              color: uiCategory.color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ] : [],
          border: Border.all(
            color: isActive ? uiCategory.color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActive ? uiCategory.color : uiCategory.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                uiCategory.icon,
                color: isActive ? Colors.white : uiCategory.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                uiCategory.category.displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}