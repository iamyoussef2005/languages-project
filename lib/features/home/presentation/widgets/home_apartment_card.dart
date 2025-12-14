import 'package:flutter/material.dart';
import 'package:project1/features/home/data/models/apartment_model.dart';
import 'package:project1/features/home/presentation/pages/apartment_details_screen.dart';

class HomeApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;

  const HomeApartmentCard({super.key, required this.apartment});

  // رابط الصور الأساسي (عدّله حسب السيرفر لديك)
  static const String baseImageUrl = "http://127.0.0.1:8000/storage/";

  @override
  Widget build(BuildContext context) {
    final String imageUrl = apartment.firstPhotoUrl != null
        ? baseImageUrl + apartment.firstPhotoUrl!
        : 'https://via.placeholder.com/400x200';

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
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
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
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // المدينة + المحافظة
                  Text(
                    '${apartment.city}, ${apartment.province}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // السعر
                  Text(
                    '${apartment.pricePerNight.toStringAsFixed(0)} / night',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
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
