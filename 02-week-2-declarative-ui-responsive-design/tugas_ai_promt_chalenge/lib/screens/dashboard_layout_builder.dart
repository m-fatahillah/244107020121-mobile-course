import 'package:flutter/material.dart';
import '../models/academic_data.dart';
import '../widgets/academic_widgets.dart';

class DashboardLayoutBuilderScreen extends StatelessWidget {
  const DashboardLayoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final bool isMobile = maxWidth < 650;
        final bool isDesktop = maxWidth >= 1000;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Badge Constraints
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.layers_rounded, color: colorScheme.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'LayoutBuilder: BoxConstraints [${maxWidth.toStringAsFixed(0)}px] → '
                        '${isDesktop ? "Split Multi-Pane Desktop" : isMobile ? "Single Column Adaptif" : "2-Column Paired Rows"}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Desktop Multi-Pane (>1000px)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Profil + Aksi Cepat + Metrik
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StudentProfileCard(profile: StudentProfile.defaultStudent),
                          const SizedBox(height: 16),
                          const StudentQuickActions(),
                          const SizedBox(height: 16),
                          _buildAdaptiveMetrics(context, columns: 2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Kolom Kanan: Jadwal Kuliah + Tenggat Tugas
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildScheduleSection(context),
                          const SizedBox(height: 16),
                          _buildTaskTimelineSection(context),
                        ],
                      ),
                    ),
                  ],
                )
              // Mobile / Tablet (<1000px): Vertical Column
              else ...[
                const StudentProfileCard(profile: StudentProfile.defaultStudent),
                const SizedBox(height: 16),
                const StudentQuickActions(),
                const SizedBox(height: 20),
                _buildAdaptiveMetrics(
                  context,
                  columns: isMobile ? 1 : 2,
                ),
                const SizedBox(height: 20),
                _buildScheduleSection(context),
                const SizedBox(height: 20),
                _buildTaskTimelineSection(context),
              ],
              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }

  // Komponen Metrik Adaptif: Menggunakan Intrinsic Height (Bebas Overflow Saat Font Membesar)
  Widget _buildAdaptiveMetrics(BuildContext context, {required int columns}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.auto_awesome_mosaic_rounded, size: 18, color: colorScheme.secondary),
            ),
            const SizedBox(width: 10),
            Text(
              'Metrik Akademik (LayoutBuilder + Column)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 1 Kolom Vertikal (Mobile) -> Tinggi Alami Bebas Rasio Kaku
        if (columns == 1)
          Column(
            children: sampleAcademicStats
                .map(
                  (stat) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AcademicStatCard(stat: stat),
                  ),
                )
                .toList(),
          )
        // 2 Kolom Berpasangan (Tablet / Desktop)
        else
          Column(
            children: [
              for (int i = 0; i < sampleAcademicStats.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: AcademicStatCard(stat: sampleAcademicStats[i]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: (i + 1 < sampleAcademicStats.length)
                            ? AcademicStatCard(stat: sampleAcademicStats[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Kuliah Hari Ini',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...sampleSchedules.map((s) => ScheduleCardTile(schedule: s)),
      ],
    );
  }

  Widget _buildTaskTimelineSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Daftar Tenggat Tugas Akademik Mahasiswa',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tenggat Tugas Mendatang',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${sampleTasks.length} Pending',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sampleTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${task.course} • ${task.deadline}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          color: task.priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
