import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postly/features/media/presentation/cubit/media_cubit.dart';
import 'package:postly/features/media/presentation/cubit/media_state.dart';
import 'package:postly/features/companies/presentation/cubit/company_cubit.dart';
import 'package:postly/features/companies/presentation/cubit/company_state.dart';
import 'package:postly/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:postly/features/auth/presentation/cubit/auth_state.dart';

class MediaLibraryScreen extends StatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  void _loadMedia() {
    final companyState = context.read<CompanyCubit>().state;
    if (companyState is CompanyLoaded && companyState.selectedCompany != null) {
      context.read<MediaCubit>().loadCompanyMedia(companyState.selectedCompany!.id);
    }
  }

  Future<void> _pickAndUpload() async {
    final companyState = context.read<CompanyCubit>().state;
    final authState = context.read<AuthCubit>().state;

    if (companyState is! CompanyLoaded || companyState.selectedCompany == null) return;
    if (authState is! AuthAuthenticated) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) return;
      context.read<MediaCubit>().uploadMedia(
        file: File(pickedFile.path),
        companyId: companyState.selectedCompany!.id,
        userId: authState.user.id,
        type: 'image',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedia,
          ),
        ],
      ),
      body: BlocConsumer<MediaCubit, MediaState>(
        listener: (context, state) {
          if (state is MediaUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful!')));
          } else if (state is MediaError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is MediaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MediaLoaded) {
            if (state.mediaFiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('No media found for this company.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: state.mediaFiles.length,
              itemBuilder: (context, index) {
                final media = state.mediaFiles[index];
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          media.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.white),
                          onPressed: () {
                            context.read<MediaCubit>().deleteMedia(
                              media.companyId,
                              media.id,
                              'companies/${media.companyId}/media/${media.id}', // Should ideally be part of entity
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const Center(child: Text('Unexpected state. Try refreshing.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUpload,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
