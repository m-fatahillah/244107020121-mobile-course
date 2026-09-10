import 'package:flutter/material.dart';
import '../models/academic_data.dart';
import '../widgets/academic_widgets.dart';

class DashboardGridViewScreen extends StatelessWidget {
  const DashboardGridViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive GridView Breakpoint Logic
    final int crossAxisCount = screenWidth >= 1100
        ? 4
        : screenWidth >= 650
            ? 2
            : 2;

    final double childAspectRatio = screenWidth >= 1100
        ? 1.45
        : screenWidth >= 650
            ? 1.4
            : (screenWidth < 360 ? 0.95 : 1.15);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Profil Mahasiswa
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: StudentProfileCard(
              profile: StudentProfile.defaultStudent,
            ),
          ),
        ),

        // 2. Baris Aksi Cepat
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: StudentQuickActions(),
          ),
        ),

        // 3. Section Title GridView
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.grid_view_rounded, size: 18, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Metrik Akademik (GridView.builder)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Semantics(
                  label: 'Grid aktif $crossAxisCount kolom',
                  child: Chip(
                    label: Text(
                      '$crossAxisCount Kolom',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. GridView Kartu Metrik
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return AcademicStatCard(
                  stat: sampleAcademicStats[index],
                  compact: screenWidth < 400,
                );
              },
              childCount: sampleAcademicStats.length,
            ),
          ),
        ),

        // 5. Section Title Jadwal Hari Ini
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadwal Kuliah Hari Ini',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${sampleSchedules.length} Mata Kuliah',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 6. List Jadwal Kuliah
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ScheduleCardTile(schedule: sampleSchedules[index]);
              },
              childCount: sampleSchedules.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 36),
        ),
      ],
    );
  }
}
