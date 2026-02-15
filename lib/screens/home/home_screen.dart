import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/stream_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../stream/start_stream_screen.dart';
import '../stream/viewer_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<StreamModel> _streams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStreams();
  }

  Future<void> _loadStreams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final streams = await _apiService.getActiveStreams();
      setState(() {
        _streams = streams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('BIDS', style: AppTheme.headingMedium.copyWith(fontSize: 20)),
            Text(
              'RUSH',
              style: AppTheme.headingMedium.copyWith(
                fontSize: 20,
                color: AppTheme.primaryYellow,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (!auth.isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                );
              }

              return PopupMenuButton<String>(
                icon: const Icon(Icons.person_outline),
                offset: const Offset(0, 50),
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  } else if (value == 'logout') {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/sign-in',
                        (route) => false,
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStreams,
        color: AppTheme.primaryBlue,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const StartStreamScreen()));
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.videocam),
        label: Text(
          'GO LIVE',
          style: AppTheme.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading streams...');
    }

    if (_error != null) {
      return EmptyState(
        message: 'Failed to load streams',
        icon: Icons.error_outline,
        action: CustomButton(text: 'Retry', onPressed: _loadStreams),
      );
    }

    if (_streams.isEmpty) {
      return EmptyState(
        message: 'No active streams found',
        icon: Icons.live_tv_outlined,
        action: CustomButton(
          text: 'Start the first stream',
          onPressed: () {
            // TODO: Navigate to start stream
          },
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalMargin = screenWidth * 0.05;
    final verticalMargin = screenHeight * 0.05;

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _streams.length,
      itemBuilder: (context, index) {
        return _StreamCard(stream: _streams[index]);
      },
    );
  }
}

class _StreamCard extends StatelessWidget {
  final StreamModel stream;

  const _StreamCard({required this.stream});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ViewerScreen(
                callId: stream.callId,
                title: stream.title,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(gradient: AppTheme.cardGradient),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'PREVIEW',
                        style: AppTheme.labelSmall.copyWith(
                          fontSize: 9,
                          color: AppTheme.textMuted.withOpacity(0.5),
                        ),
                      ),
                    ),
                    // Live badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: AppTheme.labelSmall.copyWith(
                                fontSize: 9,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.title,
                    style: AppTheme.headingSmall.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Host: ${stream.hostId.substring(0, 8)}...',
                    style: AppTheme.bodySmall.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
