import 'package:flutter/material.dart';

/// Animated shimmer wrapper that sweeps a light highlight across child [Skeleton] components.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFF3E7DB),
    this.highlightColor = const Color(0xFFFFF7F0),
    this.duration = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  @override
  State<Shimmer> createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Listenable get shimmerChanges => _controller;

  LinearGradient get gradient => LinearGradient(
        colors: [
          widget.baseColor,
          widget.highlightColor,
          widget.baseColor,
        ],
        stops: const [0.1, 0.5, 0.9],
        begin: Alignment(-1.0 + (_controller.value * 3.0), -0.3),
        end: Alignment(1.0 + (_controller.value * 3.0), 0.3),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return gradient.createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Basic atomic building block for skeleton UI placeholders.
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.margin,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final shimmer = Shimmer.of(context);
    final baseDecoration = BoxDecoration(
      color: shimmer != null ? Colors.white : const Color(0xFFF3E7DB),
      shape: shape,
      borderRadius: shape == BoxShape.rectangle
          ? BorderRadius.circular(borderRadius)
          : null,
    );

    final container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: baseDecoration,
    );

    if (shimmer == null) {
      return Shimmer(child: container);
    }
    return container;
  }
}

/// Skeleton placeholder for School Banner Card.
class SchoolBannerSkeleton extends StatelessWidget {
  const SchoolBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      height: 112,
      borderRadius: 26,
    );
  }
}

/// Skeleton placeholder for Home Page Course section.
class CourseSectionSkeleton extends StatelessWidget {
  const CourseSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Skeleton(width: 100, height: 22, borderRadius: 6),
            Skeleton(width: 50, height: 18, borderRadius: 6),
          ],
        ),
        const SizedBox(height: 12),
        const Skeleton(height: 76, borderRadius: 18),
        const SizedBox(height: 12),
        const Skeleton(height: 76, borderRadius: 18),
      ],
    );
  }
}

/// Skeleton placeholder for Home Page Testimonials section.
class TestimonialSectionSkeleton extends StatelessWidget {
  const TestimonialSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Skeleton(width: 140, height: 22, borderRadius: 6),
        SizedBox(height: 12),
        Skeleton(height: 130, borderRadius: 20),
      ],
    );
  }
}

/// Skeleton placeholder representation for Dashboard/HomePage.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: const [
            // School Banner Skeleton
            SchoolBannerSkeleton(),
            SizedBox(height: 16),

            // Course Section Skeleton
            CourseSectionSkeleton(),
            SizedBox(height: 16),

            // Banner Carousel Skeleton
            Skeleton(
              height: 160,
              borderRadius: 20,
            ),
            SizedBox(height: 20),

            // Testimonials Section Skeleton
            TestimonialSectionSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder representation for CoursesPage.
class CourseListSkeleton extends StatelessWidget {
  const CourseListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFFEAD8)),
              ),
              child: Row(
                children: [
                  const Skeleton(
                    width: 52,
                    height: 52,
                    borderRadius: 16,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Skeleton(width: 160, height: 18, borderRadius: 6),
                        SizedBox(height: 8),
                        Skeleton(width: 100, height: 14, borderRadius: 4),
                      ],
                    ),
                  ),
                  const Skeleton(
                    width: 28,
                    height: 28,
                    shape: BoxShape.circle,
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

/// Skeleton placeholder representation for VideosPage.
class VideoListSkeleton extends StatelessWidget {
  const VideoListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFEAD8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Thumbnail Skeleton
                const Skeleton(
                  width: 100,
                  height: 68,
                  borderRadius: 14,
                ),
                const SizedBox(width: 12),
                // Video Details Skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      const Skeleton(
                        width: 120,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Skeleton(width: 60, height: 18, borderRadius: 6),
                          SizedBox(width: 8),
                          Skeleton(width: 50, height: 18, borderRadius: 6),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton placeholder for CommentsSection.
class CommentListSkeleton extends StatelessWidget {
  const CommentListSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(itemCount, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEAD8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Skeleton(
                  width: 22,
                  height: 22,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Skeleton(width: 90, height: 11, borderRadius: 4),
                      SizedBox(height: 4),
                      Skeleton(width: double.infinity, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton placeholder for PDF/Document viewers.
class DocumentSkeleton extends StatelessWidget {
  const DocumentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Center(
        child: Container(
          width: double.infinity,
          height: 400,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFEAD8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Skeleton(width: 180, height: 24, borderRadius: 6),
              SizedBox(height: 20),
              Skeleton(width: double.infinity, height: 14, borderRadius: 4),
              SizedBox(height: 10),
              Skeleton(width: double.infinity, height: 14, borderRadius: 4),
              SizedBox(height: 10),
              Skeleton(width: 240, height: 14, borderRadius: 4),
              SizedBox(height: 30),
              Skeleton(width: double.infinity, height: 180, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}
