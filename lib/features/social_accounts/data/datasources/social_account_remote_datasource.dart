import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_account_model.dart';
import '../../domain/entities/social_account_entity.dart';

abstract class SocialAccountRemoteDataSource {
  Future<List<SocialAccountEntity>> getSocialAccounts(String companyId);
  Future<void> connectAccount(SocialAccountEntity account);
  Future<void> disconnectAccount(String companyId, String accountId);
}

class SocialAccountRemoteDataSourceImpl implements SocialAccountRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<SocialAccountEntity>> getSocialAccounts(String companyId) async {
    final snapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('social_accounts')
        .get();

    return snapshot.docs.map((doc) => SocialAccountModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> connectAccount(SocialAccountEntity account) async {
    final model = SocialAccountModel(
      id: account.id,
      companyId: account.companyId,
      platform: account.platform,
      accountName: account.accountName,
      profilePictureUrl: account.profilePictureUrl,
      isConnected: account.isConnected,
      connectedAt: account.connectedAt,
    );
    
    // Save to the company's social_accounts subcollection
    await _firestore
        .collection('companies')
        .doc(account.companyId)
        .collection('social_accounts')
        .doc(account.id)
        .set(model.toFirestore());
  }

  @override
  Future<void> disconnectAccount(String companyId, String accountId) async {
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('social_accounts')
        .doc(accountId)
        .update({'isConnected': false});
  }
}
