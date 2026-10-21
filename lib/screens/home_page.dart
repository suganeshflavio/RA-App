import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/dashboard_content.dart';
import '../models/testimonial.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/testimonial_repository.dart';
import '../state/session_state.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/brand_title.dart';
import '../widgets/custom_card.dart';
import '../widgets/reviews_carousel.dart';
import '../widgets/skeleton.dart';
import 'about_page.dart';
import 'contact_page.dart';
import 'courses_page.dart';
import 'privacy_policy_page.dart';
import 'subject_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late Future<DashboardContent> _dashboardFuture;
  late Future<List<Testimonial>> _testimonialsFuture;
  final _testimonialRepository = TestimonialRepository(ApiClient());
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = DashboardRepository().load();
    _testimonialsFuture = _testimonialRepository.fetchPublicTestimonials();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final dashboardFuture = DashboardRepository().load();
    final testimonialsFuture = _testimonialRepository.fetchPublicTestimonials();
    final coursesFuture = context.read<SessionState>().refreshCourses();

    setState(() {
      _isRefreshing = true;
      _dashboardFuture = dashboardFuture;
      _testimonialsFuture = testimonialsFuture;
    });

    try {
      await Future.wait([
        dashboardFuture.catchError(
          (_) => const DashboardContent(
            school: SchoolProfile(name: '', location: ''),
            resources: [],
            tests: [],
            progress: [],
            videos: [],
            courses: [],
          ),
        ),
        testimonialsFuture.catchError((_) => <Testimonial>[]),
        coursesFuture.catchError((_) {}),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final courses = session.courses;
    final isLoadingCourses = session.isLoadingCourses;
    final fewCourses = courses.take(2).toList();
    final username = session.user?.name.split(' ').first ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primarySubtle,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 30, showBackground: true),
            SizedBox(width: 10),
            Text(
              'TKS Academy',
              style: AppTypography.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.textPrimary,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(size: 64),
                    const SizedBox(height: 14),
                    BrandTitle(
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Empowering Education Everywhere',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_rounded, color: AppColors.primary),
                      title: Text('Home', style: AppTypography.titleMedium),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.menu_book_rounded, color: AppColors.textSecondary),
                      title: Text('My Courses', style: AppTypography.titleMedium),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CoursesPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                      title: Text('About Us', style: AppTypography.titleMedium),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AboutPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.contact_support_outlined, color: AppColors.textSecondary),
                      title: Text('Contact Us', style: AppTypography.titleMedium),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ContactPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                      title: Text('Privacy Policy', style: AppTypography.titleMedium),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Text(
                  '© 2026 TKS Academy',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
      body: AppBackground(
        child: FutureBuilder<DashboardContent>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (_isRefreshing ||
                snapshot.connectionState != ConnectionState.done) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: const DashboardSkeleton(),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Unable to load dashboard content.',
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                '$username 👋',
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.primaryDark,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const BannerCarousel(
                      imagePaths: [
                        'assets/images/tks-banner1.jpg',
                        'assets/images/tks-banner2.jpg',
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (isLoadingCourses)
                      const CourseSectionSkeleton()
                    else if (courses.isEmpty)
                      AppCard(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.auto_stories_outlined,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No enrolled courses found.',
                                style: AppTypography.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Courses',
                            style: AppTypography.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CoursesPage(),
                                ),
                              );
                            },
                            child: Text(
                              'See all',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...fewCourses.map((course) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SubjectPage(course: course),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    color: AppColors.primaryDark,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.courseName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${course.subjects.length} subjects • ${course.chapterCount} chapters',
                                        style: AppTypography.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 20),
                    FutureBuilder<List<Testimonial>>(
                      future: _testimonialsFuture,
                      builder: (context, testimonialSnapshot) {
                        if (testimonialSnapshot.connectionState !=
                            ConnectionState.done) {
                          return const TestimonialSectionSkeleton();
                        }
                        final testimonials = testimonialSnapshot.data ?? [];
                        if (testimonials.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Testimonials',
                              style: AppTypography.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            ReviewsCarousel(testimonials: testimonials),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
