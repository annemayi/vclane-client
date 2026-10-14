import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vclane_client/domain/entities/group.dart';

class GroupModel {
  static Group fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      location: data['location'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(Group group) {
    return {
      'name': group.name,
      if (group.description != null) 'description': group.description,
      if (group.location != null) 'location': group.location,
      'createdAt': Timestamp.fromDate(group.createdAt),
    };
  }
}
