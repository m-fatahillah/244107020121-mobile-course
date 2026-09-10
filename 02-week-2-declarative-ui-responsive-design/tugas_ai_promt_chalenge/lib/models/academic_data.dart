import 'package:flutter/material.dart';

class StudentProfile {
  final String name;
  final String nim;
  final String program;
  final String faculty;
  final int semester;
  final String status;
  final String academicAdvisor;

  const StudentProfile({
    required this.name,
    required this.nim,
    required this.program,
    required this.faculty,
    required this.semester,
    required this.status,
    required this.academicAdvisor,
  });

  static const defaultStudent = StudentProfile(
    name: 'Muhammad Fatahillah',
    nim: '244107020121',
    program: 'D4 Teknik Informatika',
    faculty: 'Teknologi Informasi',
    semester: 5,
    status: 'Mahasiswa Aktif (Reguler)',
    academicAdvisor: 'Dr. Eng. Rosa Andrie Asmara, S.T., M.T.',
  );
}

class AcademicStat {
  final String title;
  final String value;
  final String note;
  final IconData icon;
  final Color accentColor;
  final double progress; // 0.0 sampai 1.0
  final String semanticsLabel;

  const AcademicStat({
    required this.title,
    required this.value,
    required this.note,
    required this.icon,
    required this.accentColor,
    required this.progress,
    required this.semanticsLabel,
  });
}

class ScheduleItem {
  final String code;
  final String name;
  final String lecturer;
  final String room;
  final String time;
  final int sks;
  final Color tagColor;

  const ScheduleItem({
    required this.code,
    required this.name,
    required this.lecturer,
    required this.room,
    required this.time,
    required this.sks,
    required this.tagColor,
  });
}

class AcademicTaskItem {
  final String title;
  final String course;
  final String deadline;
  final String priority;
  final Color priorityColor;

  const AcademicTaskItem({
    required this.title,
    required this.course,
    required this.deadline,
    required this.priority,
    required this.priorityColor,
  });
}

// Data Dummy Akademik Mahasiswa
final List<AcademicStat> sampleAcademicStats = [
  const AcademicStat(
    title: 'IPK Kumulatif',
    value: '3.88',
    note: '+0.03 dari Semester 4',
    icon: Icons.school_rounded,
    accentColor: Colors.indigo,
    progress: 0.97,
    semanticsLabel: 'Indeks Prestasi Kumulatif 3.88 dari skala 4.00, naik 0.03 dari semester lalu',
  ),
  const AcademicStat(
    title: 'Total SKS Lulus',
    value: '92 / 144',
    note: '63.8% Menuju Kelulusan',
    icon: Icons.auto_stories_rounded,
    accentColor: Colors.teal,
    progress: 0.638,
    semanticsLabel: 'Total 92 dari 144 SKS telah lulus, mencapai 63.8 persen target kelulusan',
  ),
  const AcademicStat(
    title: 'Kehadiran Kuliah',
    value: '96.5%',
    note: 'Status Sangat Baik (Min 80%)',
    icon: Icons.fact_check_rounded,
    accentColor: Colors.amber,
    progress: 0.965,
    semanticsLabel: 'Tingkat kehadiran kuliah 96.5 persen, status Sangat Baik di atas syarat 80 persen',
  ),
  const AcademicStat(
    title: 'Tugas & Proyek',
    value: '3 Pending',
    note: '1 tugas deadline hari ini',
    icon: Icons.assignment_late_rounded,
    accentColor: Colors.deepOrange,
    progress: 0.33,
    semanticsLabel: '3 tugas akademik menunggu pengumpulan, 1 tugas berprioritas tinggi mendekati tenggat',
  ),
];

final List<ScheduleItem> sampleSchedules = [
  const ScheduleItem(
    code: 'TI-501',
    name: 'Pemrograman Mobile Terapan (Flutter)',
    lecturer: 'Dr. Hendra Kusuma, M.Kom.',
    room: 'Lab Komputasi C-204',
    time: '08:00 - 10:30 WIB',
    sks: 3,
    tagColor: Colors.indigo,
  ),
  const ScheduleItem(
    code: 'TI-503',
    name: 'Rekayasa Perangkat Lunak Lanjut',
    lecturer: 'Ir. Siti Aminah, M.T.',
    room: 'Ruang Teori TI-02',
    time: '11:00 - 13:30 WIB',
    sks: 3,
    tagColor: Colors.purple,
  ),
  const ScheduleItem(
    code: 'TI-508',
    name: 'Keamanan Siber & Ethical Hacking',
    lecturer: 'Budi Santoso, S.Kom., M.Cs.',
    room: 'Lab Cyber Security B-101',
    time: '14:00 - 16:30 WIB',
    sks: 2,
    tagColor: Colors.teal,
  ),
];

final List<AcademicTaskItem> sampleTasks = [
  const AcademicTaskItem(
    title: 'Laporan Tugas Responsif & A11y Flutter',
    course: 'Pemrograman Mobile Terapan',
    deadline: 'Hari ini, 23:59 WIB',
    priority: 'Prioritas Tinggi',
    priorityColor: Colors.red,
  ),
  const AcademicTaskItem(
    title: 'Analisis Use Case Proyek Akhir',
    course: 'Rekayasa Perangkat Lunak Lanjut',
    deadline: 'Besok, 17:00 WIB',
    priority: 'Prioritas Sedang',
    priorityColor: Colors.orange,
  ),
  const AcademicTaskItem(
    title: 'Setup Lab Penetration Testing',
    course: 'Keamanan Siber',
    deadline: '3 Hari lagi',
    priority: 'Prioritas Normal',
    priorityColor: Colors.blue,
  ),
];
