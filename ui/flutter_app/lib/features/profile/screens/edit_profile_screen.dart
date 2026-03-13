import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../config/app_providers.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  bool _isSaving = false;
  bool _hasFilled = false;
  String? _error;
  String? _pickedImagePath;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _fillFromUser(User? user) {
    if (user == null) return;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _profilePictureUrl = user.profilePictureUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final ext = p.extension(picked.path);
      final savedPath = p.join(appDir.path, 'profile_picture$ext');
      final savedFile = await File(picked.path).copy(savedPath);

      setState(() => _pickedImagePath = savedFile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showUrlDialog() {
    final controller = TextEditingController(text: _profilePictureUrl ?? '');
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profile picture URL'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'https://example.com/photo.jpg',
            prefixIcon: Icon(Icons.link_rounded, color: scheme.primary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              Navigator.of(ctx).pop();
              if (url.isEmpty) return;
              setState(() {
                _profilePictureUrl = url;
                _pickedImagePath = null;
              });
              ref.read(localProfilePictureProvider.notifier).clear();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _showImagePickerSheet() {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Change profile picture',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.link_rounded,
                      label: 'URL',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _showUrlDialog();
                      },
                    ),
                  ),
                  if (_pickedImagePath != null || _profilePictureUrl != null || ref.read(localProfilePictureProvider) != null) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PickerOption(
                        icon: Icons.delete_outline_rounded,
                        label: 'Remove',
                        color: scheme.error,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _pickedImagePath = null;
                            _profilePictureUrl = null;
                          });
                          ref.read(localProfilePictureProvider.notifier).clear();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authStateProvider).valueOrNull;
    final userId = auth?.userId;
    if (userId == null || userId.isEmpty) {
      setState(() => _error = 'Not logged in');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.updateUser(
        userId,
        firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
        profilePictureUrl: _profilePictureUrl,
      );

      if (_pickedImagePath != null) {
        await ref.read(localProfilePictureProvider.notifier).setPath(_pickedImagePath!);
      } else if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
        await ref.read(localProfilePictureProvider.notifier).clear();
      }

      ref.invalidate(userProfileProvider(userId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated'), behavior: SnackBarBehavior.floating),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final userId = auth?.userId ?? '';
    final userAsync = ref.watch(userProfileProvider(userId));
    final scheme = Theme.of(context).colorScheme;
    final localPicPath = ref.watch(localProfilePictureProvider);

    final displayImagePath = _pickedImagePath ?? localPicPath;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Edit profile'),
      ),
      body: auth == null
          ? const Center(child: Text('Please log in to edit your profile.'))
          : userAsync.when(
              data: (User? user) {
                if (user != null && !_hasFilled) {
                  _hasFilled = true;
                  _fillFromUser(user);
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _showImagePickerSheet,
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: CustomPaint(
                                      painter: _GradientRingPainter(
                                        colors: [
                                          scheme.primary,
                                          scheme.secondary,
                                          const Color(0xFF34A853),
                                          const Color(0xFFEA4335),
                                        ],
                                        strokeWidth: 4,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 112,
                                    height: 112,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: scheme.surfaceContainerHigh,
                                    ),
                                    child: ClipOval(
                                      child: displayImagePath != null && File(displayImagePath).existsSync()
                                          ? Image.file(
                                              File(displayImagePath),
                                              width: 112,
                                              height: 112,
                                              fit: BoxFit.cover,
                                            )
                                          : (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty)
                                              ? CachedNetworkImage(
                                                  imageUrl: _profilePictureUrl!,
                                                  width: 112,
                                                  height: 112,
                                                  fit: BoxFit.cover,
                                                  placeholder: (_, __) => Icon(Icons.person, size: 48, color: scheme.onSurfaceVariant),
                                                  errorWidget: (_, __, ___) => Icon(Icons.person, size: 48, color: scheme.onSurfaceVariant),
                                                )
                                              : Icon(Icons.person, size: 48, color: scheme.onSurfaceVariant),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: scheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: scheme.surface, width: 2),
                                      ),
                                      child: Icon(Icons.camera_alt_rounded, size: 18, color: scheme.onPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: _showImagePickerSheet,
                            child: const Text('Change photo'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First name',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: user?.email ?? auth.email,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            helperText: 'Email cannot be changed here',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: user?.username ?? '',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                            helperText: 'Username cannot be changed here',
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(_error!, style: TextStyle(color: scheme.error)),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Save changes'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load profile: $e')),
            ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = color ?? scheme.primary;
    return Material(
      color: fg.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 28, color: fg),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({required this.colors, required this.strokeWidth});
  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(center: Alignment.center, colors: colors);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - strokeWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
