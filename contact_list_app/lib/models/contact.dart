class Contact {
  int? id;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? email;
  String? address;
  String? profilePhoto;
  bool isFavorite;

  Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.profilePhoto,
    this.isFavorite = false,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      phoneNumber: json['phone_number'] ?? "",
      email: json['email'] ?? "",
      address: json['address'] ?? "",
      profilePhoto: json['profile_photo'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'profile_photo': profilePhoto,
    };
  }
}
