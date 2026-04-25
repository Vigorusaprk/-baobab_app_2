import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/online_order/page/boutique_detial.dart';
import 'package:flutter/material.dart';

class MallStoresPage extends StatefulWidget {
  final List<Business> stores;
  final String mallName;

  const MallStoresPage({super.key, required this.stores, required this.mallName});

  @override
  State<MallStoresPage> createState() => _MallStoresPageState();
}

class _MallStoresPageState extends State<MallStoresPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Toutes';
  List<Business> _filteredStores = [];

  final List<String> _filterOptions = ['Toutes', 'Restaurants', 'Shopping', 'Fast Food', 'Autres'];

  @override
  void initState() {
    super.initState();
    _filteredStores = widget.stores;
    _searchController.addListener(_filterStores);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStores);
    _searchController.dispose();
    super.dispose();
  }

  void _filterStores() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredStores = widget.stores.where((store) {
        final matchesQuery = query.isEmpty ||
            store.name.toLowerCase().contains(query) ||
            (store.description?.toLowerCase().contains(query) ?? false);
        final matchesFilter = _selectedFilter == 'Toutes' ||
            (_selectedFilter == 'Restaurants' && (store.type == BusinessType.restaurant || store.type == BusinessType.fastFood)) ||
            (_selectedFilter == 'Shopping' && store.type == BusinessType.shopping) ||
            (_selectedFilter == 'Fast Food' && store.type == BusinessType.fastFood) ||
            (_selectedFilter == 'Autres' && store.type != BusinessType.restaurant && store.type != BusinessType.fastFood && store.type != BusinessType.shopping);
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Boutiques - ${widget.mallName}', style: TextStyle(color: AppColors.scaffoldBackground),),
        backgroundColor: AppColors.primary,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une boutique...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          // Filtres horizontaux
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                        _filterStores();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Résultats
          Expanded(
            child: _filteredStores.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune boutique trouvée',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredStores.length,
              itemBuilder: (context, index) {
                final store = _filteredStores[index];
                final uiStore = UIBusiness(store);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: uiStore.categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(uiStore.categoryIcon, color: uiStore.categoryColor),
                    ),
                    title: Text(store.name),
                    subtitle: Text(store.address),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoutiqueDetail(businessModel: store),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
