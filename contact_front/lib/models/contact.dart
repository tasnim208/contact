class Contact {
  final int? id;
  final String nom;
  final String numero;
  final int? userId;
  final String? imagePath;
  final String? createdAt;

  Contact({
    this.id,
    required this.nom,
    required this.numero,
    this.userId,
    this.imagePath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'numero': numero,
      'user_id': userId,
      'image_path': imagePath,
      'created_at': createdAt,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      nom: map['nom'],
      numero: map['numero'],
      userId: map['user_id'],
      imagePath: map['image_path'],
      createdAt: map['created_at'],
    );
  }

  Contact copyWith({
    int? id,
    String? nom,
    String? numero,
    int? userId,
    String? imagePath,
    String? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      numero: numero ?? this.numero,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, nom: $nom, numero: $numero, imagePath: $imagePath}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.numero == numero;
  }

  @override
  int get hashCode => numero.hashCode;
}