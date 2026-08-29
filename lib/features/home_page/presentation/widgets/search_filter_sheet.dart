import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

// ... imports inchangés ...

class SearchFilterSheet extends StatefulWidget {
  final SearchFilterEntity currentFilters;
  final ValueChanged<SearchFilterEntity> onFiltersChanged;

  const SearchFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late SearchFilterEntity _filters;
  final Map<BusinessType, bool> _categorySelection = {};

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    for (var category in BusinessType.values) {
      _categorySelection[category] = category == widget.currentFilters.category;
    }
  }

  String _getCategoryDisplayName(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return 'Restaurants';
      case BusinessType.fastFood:
        return 'Fast Food';
      case BusinessType.shopping:
        return 'Shopping';
      case BusinessType.mall:
        return 'Centres Commerciaux';
      case BusinessType.hotel:
        return 'Hôtels';
      case BusinessType.carRental:
        return 'Location Voiture';
      case BusinessType.travelAgency:
        return 'Agences de voyages';
      case BusinessType.spa:
        return 'Spa';
      case BusinessType.cinema:
        return 'Cinema';
      default:
        return 'Autre';
    }
  }

  IconData _getCategoryIcon(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return Icons.restaurant;
      case BusinessType.fastFood:
        return Icons.fastfood;
      case BusinessType.shopping:
        return Icons.shopping_bag;
      case BusinessType.mall:
        return Icons.store_mall_directory;
      case BusinessType.hotel:
        return Icons.hotel;
      case BusinessType.carRental:
        return Icons.directions_car;
      case BusinessType.travelAgency:
        return Icons.card_travel;
      case BusinessType.spa:
        return Icons.spa;
      case BusinessType.cinema:
        return Icons.movie;
      default:
        return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Filtres de recherche',
                  style: Theme.of(context).textTheme.bodyLarge!,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters = const SearchFilterEntity();
                      for (var category in BusinessType.values) {
                        _categorySelection[category] = false;
                      }
                    });
                  },
                  child: Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Zone scrollable avec hauteur maximale
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.55),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Catégories
                  _buildSectionTitle('Catégories'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BusinessType.values.map((category) {
                      final isSelected = _categorySelection[category] ?? false;
                      return FilterChip(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        label: Text(_getCategoryDisplayName(category)),
                        avatar: Icon(
                          _getCategoryIcon(category),
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        selected: isSelected,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        onSelected: (selected) {
                          setState(() {
                            for (var cat in BusinessType.values) {
                              _categorySelection[cat] =
                                  cat == category && selected;
                            }
                            _filters = _filters.copyWith(
                              category: selected ? category : null,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Section Note minimale
                  _buildSectionTitle('Note minimale'),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      thumbColor: Theme.of(context).colorScheme.primary,
                      overlayColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      valueIndicatorColor: Theme.of(
                        context,
                      ).colorScheme.primary,
                    ),
                    child: Column(
                      children: [
                        Slider(
                          value: _filters.minRating ?? 0.0,
                          min: 0.0,
                          max: 5.0,
                          divisions: 10,
                          label: (_filters.minRating ?? 0.0).toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _filters = _filters.copyWith(
                                minRating: value > 0 ? value : null,
                              );
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0.0',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Note: ${(_filters.minRating ?? 0.0).toStringAsFixed(1)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              '5.0',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Localisation
                  _buildSectionTitle('Localisation'),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ex: Kinshasa, Lubumbashi...',
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(
                          location: value.isEmpty ? null : value,
                        );
                      });
                    },
                    controller: TextEditingController(
                      text: _filters.location ?? '',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section de Tri
                  _buildSectionTitle('Trier par'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: SortBy.values.map((sortBy) {
                      final isSelected = _filters.sortBy == sortBy;
                      return ChoiceChip(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        label: Text(sortBy.displayName),
                        selected: isSelected,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _filters = _filters.copyWith(sortBy: sortBy);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Boutons d'action fixes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Theme.of(context).colorScheme.surface),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFiltersChanged(_filters);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Appliquer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
