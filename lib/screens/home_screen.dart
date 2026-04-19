import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/medical_record_bloc.dart';
import 'dashboard/dashboard_screen.dart';
import 'patients/patient_list_screen.dart';
import 'payments/payment_list_screen.dart';
import 'payments/payment_form_screen.dart';
import 'records/medical_record_list_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool initialDarkMode;
  final Function(bool) onToggleTheme;

  const HomeScreen({
    super.key,
    required this.initialDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isDarkMode;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PatientBloc()),
        BlocProvider(create: (_) => PaymentBloc()),
        BlocProvider(create: (_) => MedicalRecordBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Klinik Merah Putih'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() => _isDarkMode = !_isDarkMode);
                widget.onToggleTheme(_isDarkMode);
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const DashboardScreen(),
            const PatientListScreen(),
            const MedicalRecordListScreen(),
            const PaymentListScreen(),
            ProfileScreen(
              isDarkMode: _isDarkMode,
              onToggleTheme: (val) {
                setState(() => _isDarkMode = val);
                widget.onToggleTheme(val);
              },
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outlined),
              selectedIcon: Icon(Icons.people),
              label: 'Pasien',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_information_outlined),
              selectedIcon: Icon(Icons.medical_information),
              label: 'Rekam Medis',
            ),
            NavigationDestination(
              icon: Icon(Icons.payment_outlined),
              selectedIcon: Icon(Icons.payment),
              label: 'Pembayaran',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 3
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => PaymentBloc(),
                        child: const PaymentFormScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Pembayaran Baru'),
              )
            : null,
      ),
    );
  }
}
