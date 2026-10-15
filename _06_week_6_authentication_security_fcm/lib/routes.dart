class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';

  static String announcementPath(String id) => '/pengumuman/$id';
}
