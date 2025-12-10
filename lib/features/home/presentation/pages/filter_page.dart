

import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedCity;
  String? selectedGovernorate;
  double? minPrice;
  double? maxPrice;
  bool? hasBalcony;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filter Apartments")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Governorate
            DropdownButtonFormField<String>(
              initialValue: selectedGovernorate,
              hint: const Text("Governorate"),
              items: ["Riyadh", "Makkah", "Eastern Province"]
                  .map((gov) => DropdownMenuItem(
                        value: gov,
                        child: Text(gov),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selectedGovernorate = v),
            ),

            const SizedBox(height: 16),

            // City
            DropdownButtonFormField<String>(
              initialValue: selectedCity,
              hint: const Text("City"),
              items: ["Riyadh", "Jeddah", "Dammam"]
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selectedCity = v),
            ),

            const SizedBox(height: 16),

            // Min price
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Min Price"),
              onChanged: (v) => minPrice = double.tryParse(v),
            ),

            const SizedBox(height: 16),

            // Max price
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Max Price"),
              onChanged: (v) => maxPrice = double.tryParse(v),
            ),

            const SizedBox(height: 16),

            // Balcony filter
            SwitchListTile(
              title: const Text("Has balcony"),
              value: hasBalcony ?? false,
              onChanged: (v) => setState(() => hasBalcony = v),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "city": selectedCity,
                  "governorate": selectedGovernorate,
                  "minPrice": minPrice,
                  "maxPrice": maxPrice,
                  "hasBalcony": hasBalcony,
                });
              },
              child: const Text("Apply Filters"),
            ),
          ],
        ),
      ),
    );
  }
}
