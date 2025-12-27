import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _firstPhoto;
  File? _secondPhoto;

  final TextEditingController _price = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _bedrooms = TextEditingController();
  final TextEditingController _bathrooms = TextEditingController();
  final TextEditingController _maxPersons = TextEditingController();

  late String token;
  String? _selectedProvince;

  bool _hasWifi = false;
  bool _hasParking = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }

  // ---------- IMAGE PICKER ----------
  Future<void> _pickImage(bool isFirst) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        if (isFirst) {
          _firstPhoto = File(picked.path);
        } else {
          _secondPhoto = File(picked.path);
        }
      });
    }
  }

  // ---------- SUBMIT ----------
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_firstPhoto == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("First photo is required")));
      return;
    }

    final apartment = ApartmentModel(
      id: 0,
      province: _selectedProvince!,
      city: _city.text.trim(),
      address: _address.text.trim(),
      pricePerNight: double.parse(_price.text),
      bedrooms: int.parse(_bedrooms.text),
      bathroom: int.parse(_bathrooms.text),
      maxperson: int.parse(_maxPersons.text),
      hasWifi: _hasWifi,
      hasParking: _hasParking,
      firstPhotoFile: _firstPhoto!,
      secondPhotoFile: _secondPhoto,
    );

    context.read<ApartmentCubit>().addApartment(apartment);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Apartment",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: BlocListener<ApartmentCubit, ApartmentState>(
        listener: (context, state) {
          if (state is ApartmentFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is ApartmentBooked) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProvinceDropdown(colorScheme),
                _buildTextField(_city, "City"),
                _buildTextField(_address, "Address"),
                _buildTextField(_price, "Price per Night", number: true),
                _buildTextField(_bedrooms, "Bedrooms", number: true),
                _buildTextField(_bathrooms, "Bathrooms", number: true),
                _buildTextField(_maxPersons, "Max Persons", number: true),

                const SizedBox(height: 12),

                /// ---------- CHIPS ----------
                Wrap(
                  spacing: 12,
                  children: [
                    _buildChoiceChip(
                      title: "Wi-Fi",
                      value: _hasWifi,
                      onChanged: (v) => setState(() => _hasWifi = v),
                      colorScheme: colorScheme,
                    ),
                    _buildChoiceChip(
                      title: "Parking",
                      value: _hasParking,
                      onChanged: (v) => setState(() => _hasParking = v),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Apartment Photos",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildPhotoPicker(
                      label: "First Photo (Required)",
                      file: _firstPhoto,
                      onTap: () => _pickImage(true),
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 12),
                    _buildPhotoPicker(
                      label: "Second Photo (Optional)",
                      file: _secondPhoto,
                      onTap: () => _pickImage(false),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// ---------- SUBMIT BUTTON ----------
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      "Submit Apartment",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
        style: GoogleFonts.poppins(fontSize: 14),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedProvince,
        style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: "Province",
          labelStyle: GoogleFonts.poppins(),
        ),
        items: const ['Damascus', 'Aleppo', 'Lattakia', 'Homs', 'Hama']
            .map(
              (province) => DropdownMenuItem<String>(
                value: province,
                child: Text(
                  province,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedProvince = value),
        validator: (value) => value == null ? "Please select a province" : null,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return ChoiceChip(
      label: Text(
        title,
        style: GoogleFonts.poppins(
          color: value ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: value,
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      side: BorderSide(
        color: value ? colorScheme.primary : colorScheme.outline,
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (_) => onChanged(!value),
    );
  }

  Widget _buildPhotoPicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: file == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

