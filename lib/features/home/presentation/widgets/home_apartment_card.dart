import 'package:flutter/material.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';
import 'package:project1/features/home/presentation/pages/apartment_details_screen.dart';

class HomeApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;

  const HomeApartmentCard({super.key, required this.apartment});
  static const String baseImageUrl = "http://127.0.0.1:8000/storage/";

  @override
  Widget build(BuildContext context) {
    final String imageUrl = apartment.firstPhotoUrl != null
        ? baseImageUrl + apartment.firstPhotoUrl!
        : 'https://via.placeholder.com/400x200';

    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ApartmentDetailsScreen(
              apartment: apartment,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colorScheme.surface, // استخدام colorScheme بدل الألوان الثابتة
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الشقة
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: colorScheme.onSurface.withOpacity(0.1), // استخدام الألوان من colorScheme
                    child: Icon(Icons.broken_image, size: 50, color: colorScheme.onSurface),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان (الموقع التفصيلي)
                  Text(
                    apartment.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface, // استخدام colorScheme للنصوص
                    ),
                  ),

                  const SizedBox(height: 4),

                  // المدينة + المحافظة
                  Text(
                    '${apartment.city}, ${apartment.province}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant, // اللون المتغير بناءً على الثيم
                    ),
                  ),

                  const SizedBox(height: 8),

                  // السعر
                  Text(
                    '${apartment.pricePerNight.toStringAsFixed(0)} / night',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary, // استخدام primary من colorScheme
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
