class TenantPortableProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String currentAddress;
  final List<TenantRentalHistoryItem> history;
  final TenantReviewSummary review;

  const TenantPortableProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.currentAddress,
    required this.history,
    required this.review,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'currentAddress': currentAddress,
        'history': history.map((e) => e.toJson()).toList(),
        'review': review.toJson(),
      };

  static TenantPortableProfile mock() => const TenantPortableProfile(
        id: 'tp-001',
        fullName: 'Alex Tenant',
        email: 'alex.tenant@email.com',
        phone: '+1 (201) 555-0188',
        currentAddress: '123 Main St, Unit 5B, Jersey City, NJ',
        history: [
          TenantRentalHistoryItem(
            propertyName: 'Main St Apartments',
            unitLabel: '5B',
            start: '2024-03',
            end: 'Present',
            onTimePaymentRate: 0.97,
          ),
          TenantRentalHistoryItem(
            propertyName: 'River View Residences',
            unitLabel: '12A',
            start: '2022-01',
            end: '2024-02',
            onTimePaymentRate: 0.93,
          ),
        ],
        review: TenantReviewSummary(
          rating: 4.7,
          reviewCount: 8,
          highlight: 'Clean, respectful, and consistent on-time payments.',
        ),
      );
}

class TenantRentalHistoryItem {
  final String propertyName;
  final String unitLabel;
  final String start; // YYYY-MM
  final String end; // YYYY-MM or "Present"
  final double onTimePaymentRate; // 0..1

  const TenantRentalHistoryItem({
    required this.propertyName,
    required this.unitLabel,
    required this.start,
    required this.end,
    required this.onTimePaymentRate,
  });

  Map<String, dynamic> toJson() => {
        'propertyName': propertyName,
        'unitLabel': unitLabel,
        'start': start,
        'end': end,
        'onTimePaymentRate': onTimePaymentRate,
      };
}

class TenantReviewSummary {
  final double rating;
  final int reviewCount;
  final String highlight;

  const TenantReviewSummary({
    required this.rating,
    required this.reviewCount,
    required this.highlight,
  });

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'reviewCount': reviewCount,
        'highlight': highlight,
      };
}
