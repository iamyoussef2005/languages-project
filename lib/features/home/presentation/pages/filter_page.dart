import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filter_results_page.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController cityController = TextEditingController();

  final List<String> provinces = [
    'Damascus',
    'Aleppo',
    'Lattakia',
    'Homs',
    'Hama',
  ];

  String? selectedProvince;

  RangeValues priceRange = const RangeValues(50, 500);
  double minPrice = 50;
  double maxPrice = 500;

  bool? hasWifi;
  bool? hasParking;
  int? bedrooms;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Filter Apartments',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Location'),

            // Province dropdown
            _card(
              DropdownButtonFormField<String>(
                initialValue: selectedProvince,
                items: provinces
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p, style: GoogleFonts.poppins()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedProvince = v),
                decoration: _inputDecoration('Province'),
              ),
            ),

            const SizedBox(height: 16),

            // City
            _card(
              TextField(
                controller: cityController,
                style: GoogleFonts.poppins(),
                decoration: _inputDecoration('City'),
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Price Range'),

            // Price slider
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${priceRange.start.toInt()}  -  ${priceRange.end.toInt()}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RangeSlider(
                    values: priceRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    labels: RangeLabels(
                      priceRange.start.toInt().toString(),
                      priceRange.end.toInt().toString(),
                    ),
                    onChanged: (v) {
                      setState(() {
                        priceRange = v;
                        minPrice = v.start;
                        maxPrice = v.end;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Features'),

            // Wifi chips
            _chipGroup(
              title: 'WiFi',
              value: hasWifi,
              onSelected: (v) => setState(() => hasWifi = v),
            ),

            const SizedBox(height: 12),

            // Parking chips
            _chipGroup(
              title: 'Parking',
              value: hasParking,
              onSelected: (v) => setState(() => hasParking = v),
            ),

            const SizedBox(height: 32),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, // Fixed here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FilterResultsPage(
                        province: selectedProvince,
                        city: cityController.text.isEmpty
                            ? null
                            : cityController.text,
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                        bedrooms: bedrooms,
                        hasWifi: hasWifi,
                        hasParking: hasParking,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary, // Text color based on primary
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Helpers =====

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onBackground, // Text color
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Surface color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05), // Shadow color
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: colorScheme.onSurfaceVariant, // Label color based on theme
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary), // Border color
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
    );
  }

  Widget _chipGroup({
    required String title,
    required bool? value,
    required ValueChanged<bool?> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text('Any', style: GoogleFonts.poppins()),
                selected: value == null,
                onSelected: (_) => onSelected(null),
                selectedColor: colorScheme.primary.withOpacity(0.1), // Selected color
                backgroundColor: colorScheme.surface, // Background color
              ),
              ChoiceChip(
                label: Text('Yes', style: GoogleFonts.poppins()),
                selected: value == true,
                onSelected: (_) => onSelected(true),
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
              ),
              ChoiceChip(
                label: Text('No', style: GoogleFonts.poppins()),
                selected: value == false,
                onSelected: (_) => onSelected(false),
                selectedColor: colorScheme.secondary,
                backgroundColor: colorScheme.surface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
