typedef Company = ({String name, String catchPhrase});

class Geo {
  const Geo({required this.lat, required this.lng});

  final double lat;
  final double lng;

  // the server sends strings: "-37.3159"
  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
        lat: double.parse(json['lat'] as String),
        lng: double.parse(json['lng'] as String),
      );

  Map<String, dynamic> toJson() => {
        'lat': lat.toString(),
        'lng': lng.toString(),
      };
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        street: json['street'] as String,
        suite: json['suite'] as String,
        city: json['city'] as String,
        zipcode: json['zipcode'] as String,
        geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'suite': suite,
        'city': city,
        'zipcode': zipcode,
        'geo': geo.toJson(),
      };
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone; // raw string from the server
  final String? website; // the only optional field
  final Address address;
  final Company company;

  String get phoneDigits => phone.replaceAll(RegExp(r'[^\d+]'), '');

  factory User.fromJson(Map<String, dynamic> json) {
    final c = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: c['name'] as String,
        catchPhrase: c['catchPhrase'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'website': website,
        'address': address.toJson(),
        'company': {
          'name': company.name,
          'catchPhrase': company.catchPhrase,
        },
      };

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $name, $email)';
}
