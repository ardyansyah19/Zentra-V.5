class Address {
  final String id;
  final String label;
  final String recipient;
  final String phone;
  final String fullAddress;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.fullAddress,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Alamat',
      recipient: json['recipient'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      fullAddress: json['full_address'] as String? ?? '',
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }
}
