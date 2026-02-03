import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/bloc/profile_bloc.dart';
import 'package:money/services/auth_service.dart';
import 'package:money/screens/login_screen.dart';
import 'package:money/screens/change_password.dart';
import 'package:money/screens/edit_profile.dart';
import 'package:money/utils/app_urls.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _cachedUser;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileEvent());
    _loadUser();
  }

  Future<void> _loadUser() async {
    _cachedUser = await AuthService().getUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: _buildAppBar(),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic>? profileMap;
          if (state is ProfileLoaded) {
            profileMap = state.profile;
          } else if (state is ProfileUpdated) {
            profileMap = state.profile;
          } else if (widget.user != null) {
            profileMap = widget.user;
          }
          profileMap ??= _cachedUser;

          if (profileMap != null) {
            final pic = profileMap['picture']?.toString();
            final normalizedPic = pic?.replaceAll('\\', '/');
            final imageUrl = (normalizedPic != null && normalizedPic.isNotEmpty)
                ? (normalizedPic.startsWith('http')
                      ? normalizedPic
                      : '${AppUrls.baseUrl}/$normalizedPic')
                : null;
            final userName = profileMap['name'] ?? 'Unknown';
            final userEmail = profileMap['email'] ?? '';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Image Section
                    GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(profile: profileMap!),
                          ),
                        );
                        if (updated != null) {
                          // ignore: use_build_context_synchronously
                          context.read<ProfileBloc>().add(FetchProfileEvent());
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF9DB2CE),
                                width: 3,
                              ),
                              color: const Color(0xFFE8EDF5),
                              image: imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFF2D4379),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Color(0xFF2D4379),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Color(0xFF1E2D4A),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Info Cards
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      text: userName,
                      trailing: Icons.edit_outlined,
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(profile: profileMap!),
                          ),
                        );
                        if (updated != null) {
                          // ignore: use_build_context_synchronously
                          context.read<ProfileBloc>().add(FetchProfileEvent());
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      text: userEmail,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.lock_outline,
                      text: "Change Password",
                      trailing: Icons.arrow_forward_ios,
                      isArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.logout,
                      text: "Log Out",
                      trailing: Icons.arrow_forward_ios,
                      isArrow: true,
                      isLogout: true,
                      onTap: () async {
                        await AuthService().logout();
                        if (mounted) {
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('No profile data'));
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FC),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF1E2D4A)),
        ),
      ),
      centerTitle: true,
      title: const Text(
        "Profile",
        style: TextStyle(
          color: Color(0xFF1E2D4A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    IconData? trailing,
    bool isArrow = false,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(
          icon,
          color: isLogout ? const Color(0xFFC62828) : const Color(0xFF2D4379),
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isLogout ? const Color(0xFFC62828) : const Color(0xFF2D4379),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: trailing != null
            ? Icon(
                trailing,
                size: isArrow ? 18 : 22,
                color: isLogout
                    ? const Color(0xFFC62828)
                    : const Color(0xFF2D4379),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
