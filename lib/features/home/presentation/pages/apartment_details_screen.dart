import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final ApartmentModel apartment;

  const ApartmentDetailsScreen({
    super.key,
    required this.apartment,
  });

  @override
  State<ApartmentDetailsScreen> createState() =>
      _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _bookApartment() {
    if (_startDateController.text.isEmpty ||
        _endDateController.text.isEmpty) {
      _showDialog("Error", "Please select start and end dates");
      return;
    }

    // ⚠️ الحجز غير مفعّل حاليًا في الباك
    _showDialog(
      "Info",
      "Booking feature is not available yet",
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apartment = widget.apartment;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Apartment Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              apartment.address,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("City: ${apartment.city}"),
            Text("Province: ${apartment.province}"),
            const SizedBox(height: 8),
            Text(
              "Price: ${apartment.pricePerNight} per night",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Bedrooms: ${apartment.bedrooms}"),
            Text("Bathrooms: ${apartment.bathroom}"),
            Text("Max Persons: ${apartment.maxperson}"),
            const SizedBox(height: 8),
            Text("Wi-Fi: ${apartment.hasWifi ? 'Yes' : 'No'}"),
            Text("Parking: ${apartment.hasParking ? 'Yes' : 'No'}"),
            const SizedBox(height: 24),

            // تواريخ الحجز
            const Text("Start Date"),
            TextField(
              controller: _startDateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Select start date",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(_startDateController),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text("End Date"),
            TextField(
              controller: _endDateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Select end date",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(_endDateController),
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _bookApartment,
              child: const Text("Book Apartment"),
            ),
          ],
        ),
      ),
    );
  }
}
