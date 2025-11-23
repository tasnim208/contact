import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDeleteButton;

  const ContactCard({
    Key? key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    this.showDeleteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageService = ImageService();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onEdit, // Clic sur la carte pour éditer
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Photo du contact
                imageService.buildContactImage(contact.imagePath),

                SizedBox(width: 16),

                // Informations du contact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.nom,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.textColor),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        contact.numero,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(AppConstants.accentColor),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu des 3 points
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Color(AppConstants.accentColor),
                    size: 24,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        if (showDeleteButton) {
                          onDelete();
                        }
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              color: Color(AppConstants.primaryColor),
                              size: 20),
                          SizedBox(width: 12),
                          Text('Modifier',
                              style: TextStyle(
                                color: Color(AppConstants.textColor),
                              )),
                        ],
                      ),
                    ),
                    if (showDeleteButton)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Supprimer',
                                style: TextStyle(
                                  color: Colors.red,
                                )),
                          ],
                        ),
                      ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  offset: Offset(0, 40), // Position du menu
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}