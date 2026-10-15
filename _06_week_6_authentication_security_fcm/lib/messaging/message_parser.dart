String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'] as String?;
  if (route == null || route.trim().isEmpty) {
    return '/';
  }
  final cleanRoute = route.trim();
  return cleanRoute.startsWith('/') ? cleanRoute : '/$cleanRoute';
}
