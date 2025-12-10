import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/core/utils/app_colors.dart';
import 'package:project1/core/utils/app_responsives.dart';
import 'package:project1/features/home/cubit/apartment_cubit.dart';
import 'package:project1/features/home/cubit/apartment_state.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddApartmentScreen extends StatefulWidget {
  const AddApartmentScreen({super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _price = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _bedrooms = TextEditingController();
  final TextEditingController _bathrooms = TextEditingController();
  final TextEditingController _maxPersons = TextEditingController();

  late String token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }

  String? _selectedProvince;
  bool _hasWifi = false;
  bool _hasParking = false;

  // ---------- SUBMIT ----------
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final apartment = ApartmentModel(
      province: _selectedProvince!,
      city: _city.text.trim(),
      address: _address.text.trim(),
      pricePerNight: double.parse(_price.text),
      bedrooms: int.parse(_bedrooms.text),
      bathroom: int.parse(_bathrooms.text),
      maxperson: int.parse(_maxPersons.text),
      hasWifi: _hasWifi,
      hasParking: _hasParking,
    );

    context.read<ApartmentCubit>().addApartment(apartment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Apartment"), centerTitle: true),
      body: BlocListener<ApartmentCubit, ApartmentState>(
        listener: (context, state) {
          if (state is ApartmentFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is ApartmentBooked) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },

        child: SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildDropdown(),
                _buildTextField(_city, "City"),
                _buildTextField(_address, "Address"),
                _buildTextField(_price, "Price per Night", number: true),
                _buildTextField(_bedrooms, "Bedrooms", number: true),
                _buildTextField(_bathrooms, "Bathrooms", number: true),
                _buildTextField(_maxPersons, "Max Persons", number: true),
                const SizedBox(height: 12),
                _buildChoiceChip(
                  title: "Wi-Fi",
                  value: _hasWifi,
                  onChanged: (v) => setState(() => _hasWifi = v),
                ),

                _buildChoiceChip(
                  title: "Parking",
                  value: _hasParking,
                  onChanged: (v) => setState(() => _hasParking = v),
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "Submit Apartment",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- HELPERS ----------

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedProvince,
        decoration: InputDecoration(
          labelText: "Province",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: const [
          'Cairo',
          'Alexandria',
          'Giza',
        ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) => setState(() => _selectedProvince = v),
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }
Widget _buildChoiceChip({
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        ChoiceChip(
          label: Text(
            value ? "Yes" : "No",
            style: const TextStyle(fontSize: 14),
          ),
          selected: value,
          selectedColor: AppColors.primary.withOpacity(0.15),
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (selected) {
            onChanged(!value); // قلب القيمة فقط حسب لوجيكك الأصلي
          },
          labelStyle: TextStyle(
            color: value ? AppColors.primary : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

}
