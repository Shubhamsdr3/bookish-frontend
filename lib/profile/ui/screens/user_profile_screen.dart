import 'package:bookish/feedback/screens/feedback_screen.dart';
import 'package:bookish/onboarding/screen/edit_profile_screen.dart';
import 'package:bookish/profile/ui/notifiers/user_profile_state.dart';
import 'package:bookish/profile/ui/providers/profile_state_providers.dart';
import 'package:bookish/settings/account_setting_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_service/util/user_store.dart';

class UserProfileScreen extends ConsumerWidget {
  static String routeName = '/profile';

  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Profile'),
        actions: [
          if (state.isOwner)
            IconButton(
              onPressed: () => _onEditProfileClicked(),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: Center(
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProfileState state) {
    switch (state.status) {
      case ProfileStatus.initial:
      case ProfileStatus.loading:
        return const CircularProgressIndicator();
      case ProfileStatus.error:
        return _buildErrorWidget(
          ref,
          state.errorMessage ?? 'Something went wrong',
        );
      case ProfileStatus.loaded:
        return _buildProfileContent(context, ref, state);
    }
  }

  Widget _buildErrorWidget(WidgetRef ref, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: $message'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () =>
              ref.read(profileNotifierProvider.notifier).fetchUserProfile(),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    ProfileState state,
  ) {
    final notifier = ref.read(profileNotifierProvider.notifier);
    final profile = state.profile!;

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  width: double.infinity,
                  child: Center(
                    child: InkWell(
                      onTap: () => _showImagePickerSheet(context, ref),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                notifier.getProfileImage(profile.profileIcon),
                            radius: 80.r,
                          ),
                          if (state.isImageUploading)
                            const Positioned.fill(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          const Positioned(
                            bottom: 8,
                            right: 8,
                            child: Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Card(
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ProfileRowItem(
                        icon: Icons.person,
                        title: 'User name',
                        subTitle: profile.userName,
                      ),
                      const Divider(),
                      ProfileRowItem(
                        icon: Icons.phone,
                        title: 'Phone number',
                        subTitle: state.isOwner
                            ? (profile.phoneNumber ?? '')
                            : '+91 **********',
                      ),
                      const Divider(),
                      _buildTappableRow(
                        icon: Icons.feedback_outlined,
                        label: 'Share feedback',
                        onTap: () => Get.toNamed(FeedbackScreen.routeName),
                      ),
                      const Divider(),
                      if (kDebugMode) ...[
                        _buildTappableRow(
                          icon: Icons.settings,
                          label: 'Setting',
                          onTap: () =>
                              Get.toNamed(AccountSettingScreen.routeName),
                        ),
                        const Divider(),
                      ],
                      _buildTappableRow(
                        icon: Icons.logout,
                        label: 'Logout',
                        onTap: () {
                          // TODO: Add logout logic
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.r),
            child: Text(
              'v${state.appVersion}',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerSheet(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileNotifierProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _ImagePickerSheet(
        onGalleryTap: () {
          Navigator.pop(context);
          notifier.openGallery();
        },
        onCameraTap: () {
          Navigator.pop(context);
          notifier.openCamera();
        },
      ),
    );
  }

  Future<void> _onEditProfileClicked() async {
    final userDetail = await UserStore.getUserDetail();
    Get.to(
      () => EditProfileScreen(
        phoneNumber: userDetail?.phoneNumber ?? '',
      ),
    );
  }

  Widget _buildTappableRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerSheet extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const _ImagePickerSheet({
    required this.onGalleryTap,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Choose profile picture',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: onGalleryTap,
                      icon: Icon(Icons.photo, size: 32.r),
                    ),
                    const Text('Gallery'),
                  ],
                ),
                const SizedBox(width: 46),
                Column(
                  children: [
                    IconButton(
                      onPressed: onCameraTap,
                      icon: Icon(Icons.camera_alt, size: 32.r),
                    ),
                    const Text('Camera'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileRowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;

  const ProfileRowItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Text(
                    subTitle,
                    style: GoogleFonts.roboto(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
