class Contact {
  final String id;
  final String nom;
  final String numero;

  Contact({required this.id, required this.nom, required this.numero});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? '',
      numero: json['numero'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'numero': numero,
    };
  }
}
