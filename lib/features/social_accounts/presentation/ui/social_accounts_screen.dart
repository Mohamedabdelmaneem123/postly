import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postly/features/companies/presentation/cubit/company_cubit.dart';
import 'package:postly/features/companies/presentation/cubit/company_state.dart';
import '../../domain/entities/social_account_entity.dart';
import '../../data/datasources/social_account_remote_datasource.dart';

class SocialAccountsScreen extends StatefulWidget {
  const SocialAccountsScreen({super.key});

  @override
  State<SocialAccountsScreen> createState() => _SocialAccountsScreenState();
}

class _SocialAccountsScreenState extends State<SocialAccountsScreen> {
  final _dataSource = SocialAccountRemoteDataSourceImpl();
  List<SocialAccountEntity> _accounts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final state = context.read<CompanyCubit>().state;
    if (state is CompanyLoaded && state.selectedCompany != null) {
      setState(() => _isLoading = true);
      try {
        final accounts = await _dataSource.getSocialAccounts(state.selectedCompany!.id);
        setState(() => _accounts = accounts);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _connectStub(String platform, String name, String logo) async {
    final state = context.read<CompanyCubit>().state;
    if (state is! CompanyLoaded || state.selectedCompany == null) return;

    setState(() => _isLoading = true);
    
    // Simulating OAuth Flow & Secure Vault Server setup
    await Future.delayed(const Duration(seconds: 2));

    final newAccount = SocialAccountEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyId: state.selectedCompany!.id,
      platform: platform,
      accountName: name,
      profilePictureUrl: logo,
      connectedAt: DateTime.now(),
      isConnected: true,
    );

    await _dataSource.connectAccount(newAccount);
    
    // In actual implementation, we'd send the authorization code to our backend to generate
    // an encrypted token and save it to the secure `vault_social_tokens` collection.
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$platform Connected Successfully (Stub)')));
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyCubit, CompanyState>(
      listener: (context, state) {
        if (state is CompanyLoaded) _loadAccounts();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Social Accounts')),
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Connected Accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (_accounts.isEmpty)
                      const Text('No accounts connected to this company yet.', style: TextStyle(color: Colors.grey)),
                    ..._accounts.map((acc) => Card(
                      child: ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(acc.profilePictureUrl)),
                        title: Text(acc.accountName),
                        subtitle: Text(acc.platform),
                        trailing: acc.isConnected ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.error, color: Colors.red),
                      ),
                    )),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('Connect New Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _connectStub('Facebook', 'My Awesome Page', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1024px-Facebook_Logo_%282019%29.png'),
                      icon: const Icon(Icons.facebook),
                      label: const Text('Connect Facebook Page'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _connectStub('Instagram', 'insta_brand', 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Instagram_logo_2016.svg/2048px-Instagram_logo_2016.svg.png'),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Connect Instagram Business'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _connectStub('TikTok', '@trendy_brand', 'https://upload.wikimedia.org/wikipedia/en/thumb/a/a9/TikTok_logo.svg/2560px-TikTok_logo.svg.png'),
                      icon: const Icon(Icons.music_note),
                      label: const Text('Connect TikTok Account'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
