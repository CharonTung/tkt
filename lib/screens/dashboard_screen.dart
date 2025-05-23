import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import 'announcement_screen.dart';
import 'campus_map_screen.dart';
import 'course_schedule_screen.dart';
import 'calendar_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 在進入頁面時自動載入公告
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('台科通'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AnnouncementProvider>().refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildUserInfoCard(context),
            const SizedBox(height: 16),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 16),
            _buildAnnouncementPreview(context),
            const SizedBox(height: 16),
            _buildCoursePreview(context),
            const SizedBox(height: 16),
            _buildEventPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userProfile = authService.userProfile;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '歡迎回來，${userProfile?.fullName ?? '同學'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '學號：${userProfile?.account ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.calendar_today,
        label: '行事曆',
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalendarScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.school,
        label: '課程',
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseScheduleScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.map,
        label: '校園地圖',
        color: Colors.purple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CampusMapScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.directions_bus,
        label: '交通資訊',
        color: Colors.teal,
        onTap: () {
          // TODO: 實現交通資訊功能
        },
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快速功能',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: actions.map((action) => _buildActionButton(context, action)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, _QuickAction action) {
    return Material(
      color: action.color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 32,
                color: action.color,
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: TextStyle(
                  color: action.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最新公告',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnnouncementScreen()),
                    );
                  },
                  child: const Text('查看更多'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<AnnouncementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(provider.error!),
                    ),
                  );
                }

                if (provider.announcements.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('目前沒有公告'),
                    ),
                  );
                }

                // 只顯示前3則公告
                final previewAnnouncements = provider.announcements.take(3).toList();
                return Column(
                  children: previewAnnouncements.map((announcement) {
                    return ListTile(
                      title: Text(
                        announcement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(announcement.date),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnnouncementScreen(),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursePreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日課程',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CourseScheduleScreen(),
                      ),
                    );
                  },
                  child: const Text('查看更多'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<CourseService>(
              builder: (context, courseService, child) {
                final todayCourses = courseService.getTodayCourses();
                final upcomingCourses = courseService.getUpcomingCourses();
                debugPrint('今日所有課程: ${todayCourses.length}');
                debugPrint('即將到來的課程: ${upcomingCourses.length}');
                
                if (upcomingCourses.isEmpty) {
                  if (todayCourses.isNotEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('今日課程已結束'),
                      ),
                    );
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('今日無課程'),
                    ),
                  );
                }

                return Column(
                  children: upcomingCourses.take(3).map((course) {
                    return ListTile(
                      title: Text(course.name),
                      subtitle: Text(
                        '${course.teacher} - ${course.classroom}\n${course.formattedTimeRange}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CourseScheduleScreen(),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '近期活動',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 導航到活動頁面
                  },
                  child: const Text('查看更多'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // TODO: 實現活動預覽
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('目前沒有活動'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
} 