import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vclane_client/core/theme/app_theme.dart';
import 'package:vclane_client/core/utils/validators.dart';
import 'package:vclane_client/domain/entities/user.dart';
import 'package:vclane_client/presentation/providers/auth_provider.dart';

const int _maxImageSizeBytes = 10 * 1024 * 1024; // 10MB

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = _getUser();
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  User? _getUser() {
    final authState = ref.read(authProvider);
    return switch (authState) {
      Authenticated(user: final u) => u,
      _ => null,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final file = File(picked.path);
    final size = await file.length();
    if (size > _maxImageSizeBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be less than 10MB')),
        );
      }
      return;
    }

    setState(() => _isUploadingPhoto = true);

    try {
      final user = _getUser();
      if (user == null) return;

      final storageDataSource = ref.read(storageDataSourceProvider);
      final downloadUrl = await storageDataSource.uploadProfileImage(
        user.id,
        file,
      );

      await ref
          .read(authRepositoryProvider)
          .updateUserProfile(photoUrl: downloadUrl);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload photo: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .updateUserProfile(
            displayName: _nameController.text.trim(),
            address: _addressController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
      if (mounted) context.go('/profile');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUser();
    if (user == null) return const SizedBox.shrink();

    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        actions: [
          TextButton(
            onPressed: (_isLoading || _isUploadingPhoto) ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: AppColors.primary, fontSize: 16),
                  ),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _isUploadingPhoto ? null : _showImageSourceSheet,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    backgroundImage: hasPhoto
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: _isUploadingPhoto
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : hasPhoto
                        ? null
                        : Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (v) => Validators.required(v, 'Display name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (v) => Validators.required(v, 'Address'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+639XXXXXXXXX',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.offline,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildReadOnlyField('Email', user.email, Icons.email_outlined),
                const SizedBox(height: 16),
                _buildReadOnlyField('Role', user.role, Icons.security_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
      enabled: false,
      style: TextStyle(color: AppColors.textSecondary),
    );
  }
}
