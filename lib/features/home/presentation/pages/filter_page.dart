import 'package:flutter/material.dart';

import 'filter_results_page.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  bool? hasWifi;
  bool? hasParking;
  int? bedrooms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filter Apartments")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Province (text input)
            TextField(
              controller: provinceController,
              decoration: const InputDecoration(
                labelText: "Province",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // City (text input)
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Bedrooms
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Bedrooms",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => bedrooms = int.tryParse(v),
            ),

            const SizedBox(height: 16),

            // Min Price
            TextField(
              controller: minPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Min Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Max Price
            TextField(
              controller: maxPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Max Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // WiFi filter
            SwitchListTile(
              title: const Text("Has WiFi"),
              value: hasWifi ?? false,
              onChanged: (v) => setState(() => hasWifi = v),
            ),

            // Parking filter
            SwitchListTile(
              title: const Text("Has Parking"),
              value: hasParking ?? false,
              onChanged: (v) => setState(() => hasParking = v),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FilterResultsPage(
                        province: provinceController.text.isEmpty
                            ? null
                            : provinceController.text,
                        city: cityController.text.isEmpty
                            ? null
                            : cityController.text,
                        minPrice: minPriceController.text.isEmpty
                            ? null
                            : double.tryParse(minPriceController.text),
                        maxPrice: maxPriceController.text.isEmpty
                            ? null
                            : double.tryParse(maxPriceController.text),
                        bedrooms: bedrooms,
                        hasWifi: hasWifi,
                        hasParking: hasParking,
                      ),
                    ),
                  );
                },
                child: const Text("Apply Filters"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

