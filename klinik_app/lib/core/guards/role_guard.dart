class RoleGuard {
  static bool canAccessRoute(String route, String userRole) {
    if (userRole == 'admin') return true;

    if (route.startsWith('/home')) return true;

    if (route.startsWith('/daftar-poli') || route.startsWith('/riwayat')) {
      return userRole == 'pasien';
    }

    if (route.startsWith('/pasien-list')) {
      return userRole == 'dokter' || userRole == 'admin';
    }

    if (route.startsWith('/admin-panel')) {
      return userRole == 'admin';
    }

    // Default allow if not protected explicitly, though usually we deny by default
    // For this case, let's deny by default for unknown protected routes
    return false;
  }
}
