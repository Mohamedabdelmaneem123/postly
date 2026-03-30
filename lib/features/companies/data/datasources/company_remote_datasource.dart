import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/company_member_entity.dart';

abstract class CompanyRemoteDataSource {
  Future<List<CompanyEntity>> getUserCompanies(String userId);
  Future<CompanyEntity> createCompany({
    required String name,
    required String industry,
    required String country,
    required String description,
    required String ownerId,
    String logo = '',
  });
  Future<void> updateCompany(CompanyEntity company);
  Future<void> deleteCompany(String companyId, String ownerId);
  
  Future<List<CompanyMemberEntity>> getCompanyMembers(String companyId);
  Future<void> inviteTeamMember(String companyId, String userEmail, String role);
  Future<void> updateMemberRole(String companyId, String userId, String newRole);
  Future<void> removeTeamMember(String companyId, String userId);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<CompanyEntity>> getUserCompanies(String userId) async {
    // Determine which companies the user is a part of via a Collection Group query
    // or by checking the company's team subcollection.
    // For scalability with 100k companies, we use a collectionGroup query on 'team'
    final teamSnapshot = await _firestore
        .collectionGroup('team')
        .where('userId', isEqualTo: userId)
        .get();

    final companyIds = teamSnapshot.docs.map((e) {
      // The parent of 'team/{userId}' is 'companies/{companyId}'
      return e.reference.parent.parent!.id;
    }).toList();
    
    if (companyIds.isEmpty) return [];

    // Since Firestore 'in' queries are limited to 10, chunk if necessary.
    final companySnapshot = await _firestore
        .collection('companies')
        .where(FieldPath.documentId, whereIn: companyIds)
        .get();

    return companySnapshot.docs.map((doc) => _mapDocToEntity(doc)).toList();
  }

  @override
  Future<CompanyEntity> createCompany({
    required String name,
    required String industry,
    required String country,
    required String description,
    required String ownerId,
    String logo = '',
  }) async {
    final docRef = _firestore.collection('companies').doc();
    
    final newCompany = CompanyEntity(
      id: docRef.id,
      ownerId: ownerId,
      name: name,
      industry: industry,
      country: country,
      description: description,
      logo: logo,
      createdAt: DateTime.now(),
    );

    // Batch to write company and add owner to its 'team' subcollection
    final batch = _firestore.batch();
    
    batch.set(docRef, _entityToMap(newCompany));
    
    final teamMemberRef = docRef.collection('team').doc(ownerId);
    batch.set(teamMemberRef, {
      'userId': ownerId,
      'role': 'Owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return newCompany;
  }

  @override
  Future<void> updateCompany(CompanyEntity company) async {
    await _firestore.collection('companies').doc(company.id).update(_entityToMap(company));
  }

  @override
  Future<void> deleteCompany(String companyId, String ownerId) async {
    final doc = await _firestore.collection('companies').doc(companyId).get();
    if (doc.data()?['ownerId'] != ownerId) {
      throw Exception('Only owners can delete the company');
    }

    // deletion of subcollections in a batch is complex; usually done via a Cloud Function
    // or by deleting all known docs. For MVP, we delete the company doc.
    // Note: Cloud Firestore doesn't automatically delete subcollections when parent is deleted.
    await _firestore.collection('companies').doc(companyId).delete();
  }

  @override
  Future<List<CompanyMemberEntity>> getCompanyMembers(String companyId) async {
    final snapshot = await _firestore.collection('companies').doc(companyId).collection('team').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CompanyMemberEntity(
        userId: doc.id,
        companyId: companyId,
        role: data['role'],
      );
    }).toList();
  }

  @override
  Future<void> inviteTeamMember(String companyId, String userEmail, String role) async {
    final userSnapshot = await _firestore.collection('users').where('email', isEqualTo: userEmail).limit(1).get();
    if (userSnapshot.docs.isEmpty) {
      throw Exception('User with this email not found.');
    }
    
    final userId = userSnapshot.docs.first.id;
    
    await _firestore.collection('companies').doc(companyId).collection('team').doc(userId).set({
      'userId': userId,
      'role': role,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateMemberRole(String companyId, String userId, String newRole) async {
    await _firestore.collection('companies').doc(companyId).collection('team').doc(userId).update({'role': newRole});
  }

  @override
  Future<void> removeTeamMember(String companyId, String userId) async {
    await _firestore.collection('companies').doc(companyId).collection('team').doc(userId).delete();
  }

  CompanyEntity _mapDocToEntity(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return CompanyEntity(
      id: doc.id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      industry: map['industry'] ?? '',
      country: map['country'] ?? '',
      logo: map['logo'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _entityToMap(CompanyEntity entity) {
    return {
      'id': entity.id,
      'ownerId': entity.ownerId,
      'name': entity.name,
      'industry': entity.industry,
      'country': entity.country,
      'logo': entity.logo,
      'description': entity.description,
      'createdAt': entity.createdAt.toIso8601String(),
    };
  }
}
