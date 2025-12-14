import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/features/home/cubit/apartment_cubit.dart';
import 'package:project1/features/home/cubit/apartment_state.dart';

import 'package:project1/features/home/presentation/widgets/home_apartment_card.dart';

class FilterResultsPage extends StatefulWidget {
  final String? province;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final bool? hasWifi;
  final bool? hasParking;

  const FilterResultsPage({
    super.key,
    this.province,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.hasWifi,
    this.hasParking,
  });

  @override
  State<FilterResultsPage> createState() => _FilterResultsPageState();
}

class _FilterResultsPageState extends State<FilterResultsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ApartmentCubit>().filterApartments(
        province: widget.province,
        city: widget.city,
        minPrice: widget.minPrice,
        maxPrice: widget.maxPrice,
        bedrooms: widget.bedrooms,
        hasWifi: widget.hasWifi,
        hasParking: widget.hasParking,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtered Results")),

      body: BlocBuilder<ApartmentCubit, ApartmentState>(
        builder: (context, state) {
          if (state is ApartmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApartmentEmpty) {
            return const Center(
              child: Text("No apartments found with these filters"),
            );
          }

          if (state is ApartmentFailure) {
            return Center(child: Text("Error: ${state.message}"));
          }

          if (state is ApartmentLoaded) {
            final apartments = state.apartments;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apartments.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HomeApartmentCard(apartment: apartments[i]),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
