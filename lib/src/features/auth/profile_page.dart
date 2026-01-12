import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/cloudinary_service.dart';
import '../payments/subscription_page.dart';
import '../payments/payment_methods_page.dart';
import '../payments/payment_history_page.dart';
import 'widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cloudinaryService = CloudinaryService();
  bool _isEditing = false;
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _loadUserData({bool force = false}) {
    // Only load if not modifying (unless forced)
    if (_isEditing && !force) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    String? avatarUrl;
    if (_selectedImage != null) {
      avatarUrl = await _cloudinaryService.uploadImage(_selectedImage!);
      debugPrint('Cloudinary upload result: $avatarUrl');
      if (avatarUrl == null) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    debugPrint(
      'Updating profile with: name=${_nameController.text.trim()}, phone=${_phoneController.text.trim()}, avatarUrl=$avatarUrl',
    );
    final success = await authProvider.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarUrl: avatarUrl,
    );
    debugPrint('Profile update success: $success');

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }

    if (success && mounted) {
      setState(() {
        _isEditing = false;
        _selectedImage = null; // Reset selected image after successful update
      });
      // Force reload user data into fields since we are no longer editing
      _loadUserData(force: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to update profile',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                // If canceling edit, reload original data
                if (!_isEditing) {
                  _loadUserData(force: true);
                  _selectedImage = null;
                }
              });
            },
            icon: Icon(_isEditing ? Iconsax.tick_circle : Iconsax.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child:
                        (_selectedImage != null ||
                            (user?.avatarUrl != null &&
                                user!.avatarUrl!.isNotEmpty))
                        ? ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    user!.avatarUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Iconsax.user,
                                        size: 60,
                                        color: Colors.blue.shade700,
                                      );
                                    },
                                  ),
                          )
                        : Icon(
                            Iconsax.user,
                            size: 60,
                            color: Colors.blue.shade700,
                          ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Iconsax.camera,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Email (non-editable)
              Text(
                user?.email ?? 'No email',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),

              if (user?.isPremium == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Premium Member',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Name Field
              AuthTextField(
                controller: _nameController,
                hintText: 'Full Name',
                prefixIcon: Iconsax.user,
                textCapitalization: TextCapitalization.words,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone Field
              AuthTextField(
                controller: _phoneController,
                hintText: 'Phone Number',
                prefixIcon: Iconsax.call,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),

              if (_isEditing) ...[
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Menu Items
              _buildMenuItem(
                icon: Iconsax.notification,
                title: 'Notifications',
                onTap: () {},
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Iconsax.crown,
                title: 'Subscription',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Iconsax.card,
                title: 'Payment Methods',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentMethodsPage(),
                    ),
                  );
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Iconsax.receipt_item,
                title: 'Payment History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentHistoryPage(),
                    ),
                  );
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Iconsax.shield_tick,
                title: 'Privacy & Security',
                onTap: () {},
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Iconsax.message_question,
                title: 'Help & Support',
                onTap: () {},
                isDark: isDark,
              ),
              _buildMenuItem(
                icon: Iconsax.info_circle,
                title: 'About',
                onTap: () {},
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Iconsax.logout, color: Colors.red),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        size: 20,
      ),
    );
  }
}
