import 'package:flutter/material.dart';

class TradeOffAnalysisScreen extends StatelessWidget {
  const TradeOffAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Pengantar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Analisis Trade-Off Arsitektur',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Studi Komparatif: Implementasi Dashboard Akademik Flutter berbasis GridView vs LayoutBuilder + Column dari sudut pandang Responsivitas & Aksesibilitas (WCAG).',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Trade-off Responsif
          _buildSectionHeader(
            context,
            icon: Icons.aspect_ratio_rounded,
            title: '1. Trade-Off Responsivitas (Responsiveness)',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            title: 'Pendekatan GridView (SliverGrid / GridView.builder)',
            points: [
              'Kelebihan: Sangat efisien dan ringkas dalam membagi grid menjadi 2, 3, atau 4 kolom seragam secara otomatis.',
              'Limitasi Aspect Ratio: Sangat terikat pada parameter `childAspectRatio` (lebar : tinggi). Karena rasio ini kaku, kartu metrik tidak dapat menyesuaikan tingginya secara otomatis jika salah satu kartu memiliki teks subtitle atau progress bar yang lebih panjang.',
              'Risiko Clipping: Pada layar sempit (small phone), aspect ratio yang tidak pas dapat menyebabkan teks terpotong atau overflow.',
            ],
            icon: Icons.grid_on_rounded,
            accentColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            title: 'Pendekatan LayoutBuilder + Column / Row',
            points: [
              'Kelebihan Fluid Height: Tinggi kartu ditentukan secara alami (*Intrinsic Content Height*). Berapa pun panjang teks atau komponen di dalam kartu, layout akan memanjang secara mulus tanpa terpotong.',
              'Fleksibilitas Restrukturisasi: Dapat membaca `constraints.maxWidth` parent secara real-time untuk mengubah susunan UI secara radikal (1 kolom vertikal di HP -> 2 kolom di tablet -> split multi-pane di desktop/web).',
              'Trade-off: Memerlukan penulisan kode perulangan baris berpasangan (`Row` pairing) secara manual untuk item dalam jumlah banyak.',
            ],
            icon: Icons.dashboard_customize_rounded,
            accentColor: Colors.purple,
          ),

          const SizedBox(height: 24),

          // 2. Trade-off Aksesibilitas (A11y)
          _buildSectionHeader(
            context,
            icon: Icons.accessibility_new_rounded,
            title: '2. Trade-Off Aksesibilitas (Accessibility & A11y)',
            color: Colors.teal,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            title: 'Dukungan Low-Vision & Pembaca Layar (Screen Reader)',
            points: [
              'Toleransi Skala Teks (Text Scale Factor): LayoutBuilder + Column memiliki ketahanan superior terhadap pengguna low-vision yang memperbesar font sistem (> 1.3x). Sebaliknya, GridView dengan childAspectRatio statis akan langsung mengalami RenderFlex Overflow kuning-hitam saat ukuran font dinaikkan.',
              'Urutan Pembacaan (Focus Traversal): GridView membaca secara horizontal per-baris (Kiri -> Kanan -> Baris Berikutnya). LayoutBuilder + Column memungkinkan hierarki semantik terkelompok per-seksi (Header Profil -> Aksi Cepat -> Metrik -> Jadwal Kuliah).',
              'Standar Sentuhan (Touch Target): Kedua pendekatan mendukung target sentuh >= 48x48 dp sesuai standar WCAG, namun Column/Row memberikan ruang vertikal yang lebih aman untuk padding.',
            ],
            icon: Icons.record_voice_over_rounded,
            accentColor: Colors.teal,
          ),

          const SizedBox(height: 24),

          // 3. Matriks Perbandingan Ringkas
          _buildSectionHeader(
            context,
            icon: Icons.table_chart_rounded,
            title: '3. Matriks Perbandingan Ringkas',
            color: Colors.amber.shade900,
          ),
          const SizedBox(height: 12),
          _buildComparisonTable(context),

          const SizedBox(height: 24),

          // 4. Kesimpulan & Rekomendasi
          _buildSectionHeader(
            context,
            icon: Icons.lightbulb_rounded,
            title: '4. Rekomendasi Arsitektural',
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              'Gunakan GridView untuk katalog data homogen yang ukurannya seragam (misal e-library, galeri foto). Gunakan kombinasi LayoutBuilder + CustomScrollView/Column untuk halaman Dashboard Akademik utama yang memadukan berbagai komponen heterogen (Profil, Metrik, Jadwal, Tugas) demi menjamin ketahanan skala teks aksesibilitas dan adaptabilitas multi-device yang maksimal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<String> points,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  Expanded(
                    child: Text(
                      p,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.45,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rows = [
      {'param': 'Adaptabilitas Tinggi Item', 'grid': 'Kaku (childAspectRatio)', 'layout': 'Alami & Otomatis (Fluid)'},
      {'param': 'Ketahanan Text Scaling (>1.3x)', 'grid': 'Rentan Overflow', 'layout': 'Sangat Aman & Bebas Overflow'},
      {'param': 'Kemudahan Implementasi', 'grid': 'Sangat Cepat & Praktis', 'layout': 'Butuh Kalkulasi Breakpoints'},
      {'param': 'Urutan Semantics A11y', 'grid': 'Linear Row-by-Row', 'layout': 'Hierarki Terstruktur Per-Seksi'},
      {'param': 'Restrukturisasi Multi-Pane', 'grid': 'Terbatas Kolom Grid', 'layout': 'Sangat Fleksibel (Split View)'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.1),
          2: FlexColumnWidth(1.1),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3), width: 1),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh),
            children: [
              _buildTableCell('Aspek Evaluasi', isHeader: true, theme: theme),
              _buildTableCell('GridView', isHeader: true, theme: theme),
              _buildTableCell('LayoutBuilder + Col', isHeader: true, theme: theme),
            ],
          ),
          ...rows.map(
            (r) => TableRow(
              children: [
                _buildTableCell(r['param']!, isBold: true, theme: theme),
                _buildTableCell(r['grid']!, theme: theme),
                _buildTableCell(r['layout']!, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 12 : 11,
          color: isHeader ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
