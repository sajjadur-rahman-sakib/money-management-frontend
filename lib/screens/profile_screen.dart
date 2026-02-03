import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/bloc/profile_bloc.dart';
import 'package:money/services/auth_service.dart';
import 'package:money/screens/login_screen.dart';
import 'package:money/screens/change_password.dart';
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
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic>? profileMap;
          if (state is ProfileLoaded) {
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
            debugPrint('Profile picture URL: $imageUrl');

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    imageUrl != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(imageUrl),
                            onBackgroundImageError: (exception, stackTrace) {
                              debugPrint('Image load error: $exception');
                            },
                          )
                        : CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 40),
                          ),
                    const SizedBox(height: 20),
                    Text(
                      '${profileMap['name'] ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${profileMap['email'] ?? ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChangePasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('Change Password'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await AuthService().logout();
                        Navigator.pushReplacement(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Logout'),
                    ),
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
}
