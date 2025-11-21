class Contact {
  final int? id;
  final String nom;
  final String numero;
  final int? userId;

  Contact({
    this.id,
    required this.nom,
    required this.numero,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'numero': numero,
      'user_id': userId,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      nom: map['nom'],
      numero: map['numero'],
      userId: map['user_id'],
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, nom: $nom, numero: $numero, userId: $userId}';
  }
}