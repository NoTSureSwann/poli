import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/medical_record_bloc.dart';
import '../services/auth_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'chatbot_screen.dart';
import 'patients/patient_list_screen.dart';
import 'dokter/dokter_list_screen.dart';
import 'tarif/tarif_screen.dart';
import 'patients/patient_form_screen.dart';
import 'payments/payment_list_screen.dart';
import 'payments/payment_form_screen.dart';
import 'records/medical_record_list_screen.dart';
import 'records/medical_record_form_screen.dart';
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
    // Default user ID for chatbot - actual ID is loaded asynchronously
    const currentUserId = 1;

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
            DashboardScreen(
              onNavigate: (index) => setState(() => _selectedIndex = index),
              onAction: (action) {
                switch (action) {
                  case 'add_patient':
                    _openPatientForm();
                    break;
                  case 'add_payment':
                    _openPaymentForm();
                    break;
                  case 'add_record':
                    _openRecordForm();
                    break;
                  case 'view_dokter':
                    _openDokterList();
                    break;
                  case 'view_tarif':
                    _openTarif();
                    break;
                }
              },
            ),
            const PatientListScreen(),
            const MedicalRecordListScreen(),
            const PaymentListScreen(),
            ChatbotScreen(userId: currentUserId),
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
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: 'AI Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  Widget? _buildFab() {
    if (_selectedIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () => _openPatientForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Pasien Baru'),
      );
    }

    if (_selectedIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () => _openRecordForm(),
        icon: const Icon(Icons.add_moderator),
        label: const Text('Rekam Medis'),
      );
    }

    if (_selectedIndex == 3) {
      return FloatingActionButton.extended(
        onPressed: () => _openPaymentForm(),
        icon: const Icon(Icons.add),
        label: const Text('Pembayaran Baru'),
      );
    }

    return null;
  }

  void _openPatientForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PatientBloc(),
          child: const PatientFormScreen(),
        ),
      ),
    );
  }

  void _openPaymentForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PaymentBloc(),
          child: const PaymentFormScreen(),
        ),
      ),
    );
  }

  void _openRecordForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => MedicalRecordBloc(),
          child: const MedicalRecordFormScreen(),
        ),
      ),
    );
  }

  void _openDokterList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DokterListScreen()),
    );
  }

  void _openTarif() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TarifScreen()),
    );
  }
}
