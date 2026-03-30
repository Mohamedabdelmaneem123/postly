import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedIndustry = 'Technology';
  String _selectedCountry = 'Egypt';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<CompanyCubit>().createCompany(
        name: _nameController.text.trim(),
        industry: _selectedIndustry,
        country: _selectedCountry,
        description: _descriptionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Company')),
      body: BlocConsumer<CompanyCubit, CompanyState>(
        listener: (context, state) {
          if (state is CompanyError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CompanyLoaded && state.selectedCompany != null) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Company Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Company Name', prefixIcon: Icon(Icons.business)),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedIndustry,
                    decoration: const InputDecoration(labelText: 'Industry', prefixIcon: Icon(Icons.category)),
                    items: ['Technology', 'E-commerce', 'Real Estate', 'Restaurant', 'Clinic', 'Gym', 'Other']
                        .map((ind) => DropdownMenuItem(value: ind, child: Text(ind)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedIndustry = val!),
                  ),
                  const SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                    initialValue: _selectedCountry,
                    decoration: const InputDecoration(labelText: 'Country', prefixIcon: Icon(Icons.flag)),
                    items: ['Egypt', 'Saudi Arabia', 'UAE', 'Jordan', 'Oman', 'Qatar', 'Kuwait', 'Bahrain']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCountry = val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Brief Description', prefixIcon: Icon(Icons.description)),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Create Company'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
