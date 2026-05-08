import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../models/app_models.dart';

class ServicePlusApp extends StatefulWidget {
  const ServicePlusApp({super.key});

  @override
  State<ServicePlusApp> createState() => _ServicePlusAppState();
}

class _ServicePlusAppState extends State<ServicePlusApp> {
  final AppRepository repository = AppRepository();

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Servis Plus Mobile',
          theme: _buildTheme(),
          home: Stack(
            children: [
              RootScreen(repository: repository),
              if (repository.isBusy) const _LoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF3B82F6);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF020617),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF020617),
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F172A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF020617),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    if (repository.isAdminAuthenticated) {
      return AdminShell(repository: repository);
    }
    if (repository.isMemberAuthenticated) {
      return MemberShell(repository: repository);
    }
    return AuthGatewayScreen(repository: repository);
  }
}

class AuthGatewayScreen extends StatefulWidget {
  const AuthGatewayScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<AuthGatewayScreen> createState() => _AuthGatewayScreenState();
}

class _AuthGatewayScreenState extends State<AuthGatewayScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  final _memberLoginEmail = TextEditingController();
  final _memberLoginPassword = TextEditingController();
  final _registerName = TextEditingController();
  final _registerPhone = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _adminUser = TextEditingController();
  final _adminPassword = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _memberLoginEmail.dispose();
    _memberLoginPassword.dispose();
    _registerName.dispose();
    _registerPhone.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    _adminUser.dispose();
    _adminPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D6EFD), Color(0xFF11B980)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroBadge(label: 'Servis Plus Mobile'),
                        SizedBox(height: 16),
                        Text(
                          'Devam etmek icin giris yap.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Uye paneli, servis talepleri ve admin operasyon merkezi giristen sonra acilir.',
                          style: TextStyle(
                            color: Color(0xFFEFF6FF),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Uye Giris'),
                              Tab(text: 'Kayit'),
                              Tab(text: 'Admin'),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 470,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildMemberLogin(context),
                                _buildRegister(context),
                                _buildAdminLogin(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberLogin(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _memberLoginEmail,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _memberLoginPassword,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Sifre'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () async {
            final error = await widget.repository.loginMember(
              email: _memberLoginEmail.text,
              password: _memberLoginPassword.text,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
            }
          },
          child: const Text('Panele Gir'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) =>
                PasswordResetDialog(repository: widget.repository),
          ),
          child: const Text('Sifremi Unuttum'),
        ),
      ],
    );
  }

  Widget _buildRegister(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _registerName,
          decoration: const InputDecoration(labelText: 'Ad Soyad'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _registerPhone,
          decoration: const InputDecoration(labelText: 'Telefon'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _registerEmail,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _registerPassword,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Sifre'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () async {
            if (_registerName.text.trim().isEmpty ||
                _registerPhone.text.trim().isEmpty ||
                _registerEmail.text.trim().isEmpty ||
                _registerPassword.text.length < 5) {
              _showSnack(
                context,
                'Tum alanlari doldur ve sifreyi en az 5 karakter yap.',
                true,
              );
              return;
            }

            final error = await widget.repository.registerMember(
              fullName: _registerName.text,
              phone: _registerPhone.text,
              email: _registerEmail.text,
              password: _registerPassword.text,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
            }
          },
          child: const Text('Kayit Ol'),
        ),
      ],
    );
  }

  Widget _buildAdminLogin(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _adminUser,
          decoration: const InputDecoration(labelText: 'Kullanici Adi'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _adminPassword,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Sifre'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () async {
            final error = await widget.repository.loginAdmin(
              username: _adminUser.text,
              password: _adminPassword.text,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
            }
          },
          child: const Text('Admin Girisi'),
        ),
      ],
    );
  }
}

class MemberShell extends StatefulWidget {
  const MemberShell({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final member = widget.repository.currentMember;
    final pages = [
      MemberDashboardScreen(repository: widget.repository),
      MemberRequestsScreen(repository: widget.repository),
      NewRequestScreen(repository: widget.repository),
      ProfileScreen(repository: widget.repository),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          member == null
              ? 'Uye Paneli'
              : 'Hos geldin ${member.fullName.split(' ').first}',
        ),
        actions: [
          IconButton(
            onPressed: widget.repository.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Talepler',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            label: 'Yeni Talep',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        onDestinationSelected: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardScreen(repository: widget.repository),
      CustomersScreen(repository: widget.repository),
      DevicesScreen(repository: widget.repository),
      ServicesScreen(repository: widget.repository),
      OperationsScreen(repository: widget.repository),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Operasyon Merkezi'),
        actions: [
          IconButton(
            onPressed: widget.repository.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            label: 'Musteriler',
          ),
          NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            label: 'Cihazlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_circle_outlined),
            label: 'Servis',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            label: 'Operasyon',
          ),
        ],
      ),
    );
  }
}

class MemberDashboardScreen extends StatelessWidget {
  const MemberDashboardScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final data = repository.memberDashboard();
    final member = repository.currentMember;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _MemberPanelHero(
          name: member?.fullName ?? 'Uye',
          activeRequestCount: data.activeRequestCount,
          totalRequestCount: data.totalRequestCount,
        ),
        const SizedBox(height: 18),
        _StatsGrid(
          items: [
            _StatData(
              'Cihaz Sayisi',
              data.deviceCount.toString(),
              const Color(0xFF0F766E),
            ),
            _StatData(
              'Aktif Talep',
              data.activeRequestCount.toString(),
              const Color(0xFFD97706),
            ),
            _StatData(
              'Toplam Talep',
              data.totalRequestCount.toString(),
              const Color(0xFF1D4ED8),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Son Talepler',
          child: Column(
            children: data.recentRequests.isEmpty
                ? const [Text('Henuz servis talebi bulunmuyor.')]
                : data.recentRequests
                      .map(
                        (item) => _ServiceTile(view: item, showMember: false),
                      )
                      .toList(),
          ),
        ),
      ],
    );
  }
}

class MemberRequestsScreen extends StatelessWidget {
  const MemberRequestsScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final member = repository.currentMember;
    final requests = member == null
        ? const <ServiceRecordView>[]
        : repository.serviceViewsForMember(member.id);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'Tum Taleplerim',
          child: Column(
            children: requests
                .map((item) => _ServiceTile(view: item, showMember: false))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _issue = TextEditingController();

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _issue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'Yeni Servis Talebi',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _brand,
                decoration: const InputDecoration(labelText: 'Marka'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _model,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _issue,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ariza Aciklamasi',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () async {
                  if (_brand.text.trim().isEmpty ||
                      _model.text.trim().isEmpty ||
                      _issue.text.trim().isEmpty) {
                    _showSnack(
                      context,
                      'Tum alanlari doldurman gerekiyor.',
                      true,
                    );
                    return;
                  }
                  final message = await widget.repository.createServiceRequest(
                    brand: _brand.text,
                    model: _model.text,
                    issueDescription: _issue.text,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  if (message.isEmpty) {
                    _showSnack(
                      context,
                      'Talep gonderilirken bir sorun olustu.',
                      true,
                    );
                    return;
                  }
                  _brand.clear();
                  _model.clear();
                  _issue.clear();
                  _showSnack(context, message, false);
                },
                child: const Text('Talep Gonder'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  final TextEditingController _newPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    final member = widget.repository.currentMember!;
    _fullName = TextEditingController(text: member.fullName);
    _phone = TextEditingController(text: member.phone);
    _email = TextEditingController(text: member.email);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'Profil Bilgileri',
          child: Column(
            children: [
              TextField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Telefon'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Yeni Sifre'),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () async {
                  final error = await widget.repository.updateProfile(
                    fullName: _fullName.text,
                    phone: _phone.text,
                    email: _email.text,
                    newPassword: _newPassword.text,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  if (error.isNotEmpty) {
                    _showSnack(context, error, true);
                    return;
                  }
                  _newPassword.clear();
                  _showSnack(context, 'Profilin guncellendi.', false);
                },
                child: const Text('Profili Guncelle'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final data = repository.adminDashboard();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AdminPanelHero(data: data),
        const SizedBox(height: 18),
        _StatsGrid(
          items: [
            _StatData(
              'Toplam Musteri',
              data.totalMembers.toString(),
              const Color(0xFF0F766E),
            ),
            _StatData(
              'Toplam Cihaz',
              data.totalDevices.toString(),
              const Color(0xFF2563EB),
            ),
            _StatData(
              'Aktif Servis',
              data.activeServices.toString(),
              const Color(0xFFD97706),
            ),
            _StatData(
              'Teslim Edilen',
              data.deliveredServices.toString(),
              const Color(0xFF7C3AED),
            ),
            _StatData(
              'Bu Ay Ciro',
              '${data.completedRevenue.toStringAsFixed(0)} TL',
              const Color(0xFFBE123C),
            ),
            _StatData(
              'Ort. Servis',
              '${data.averageServiceAmount.toStringAsFixed(0)} TL',
              const Color(0xFF475569),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Son Servisler',
          child: Column(
            children: data.recentServices
                .map((item) => _ServiceTile(view: item))
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Son Uyeler',
          child: Column(
            children: data.recentMembers
                .map(
                  (member) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFCCFBF1),
                      child: Text(member.fullName.characters.first),
                    ),
                    title: Text(member.fullName),
                    subtitle: Text('${member.email} • ${member.phone}'),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final members = repository.members;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) =>
                  CreateCustomerDialog(repository: repository),
            ),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Musteri Ekle'),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Musteri Listesi',
          child: Column(
            children: members
                .map(
                  (member) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: member.hasAccount
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFFDE68A),
                      child: Text(member.fullName.characters.first),
                    ),
                    title: Text(member.fullName),
                    subtitle: Text('${member.phone} • ${member.email}'),
                    trailing: Text(member.hasAccount ? 'Uye' : 'Pasif'),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => CreateDeviceDialog(repository: repository),
            ),
            icon: const Icon(Icons.add_to_photos_outlined),
            label: const Text('Cihaz Ekle'),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Cihaz Listesi',
          child: Column(
            children: repository.devices.map((device) {
              final member = repository.members.firstWhere(
                (item) => item.id == device.memberId,
              );
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.phone_android)),
                title: Text('${device.brand} ${device.model}'),
                subtitle: Text(
                  '${member.fullName} • ${device.issueDescription}',
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final services = repository.serviceViews();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Servis kayitlarini burada MVC tarafindaki gibi duzenleyebilir, islem secip durumu guncelleyebilirsin.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) =>
                    CreateServiceRecordDialog(repository: repository),
              ),
              icon: const Icon(Icons.build_outlined),
              label: const Text('Servis Kaydi Ekle'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Servis Kayitlari',
          child: Column(
            children: services
                .map(
                  (item) => _ServiceTile(
                    view: item,
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Duzenle',
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (context) => EditServiceRecordDialog(
                              repository: repository,
                              record: item.record,
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Sil',
                          style: IconButton.styleFrom(
                            foregroundColor: const Color(0xFFFCA5A5),
                          ),
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Servis kaydi silinsin mi?'),
                                content: Text(
                                  '${item.device.brand} ${item.device.model} kaydi kaldirilacak.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Vazgec'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Sil'),
                                  ),
                                ],
                              ),
                            );
                            if (shouldDelete != true || !context.mounted) {
                              return;
                            }
                            final error = await repository.deleteServiceRecord(
                              item.record.id,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            if (error.isNotEmpty) {
                              _showSnack(context, error, true);
                              return;
                            }
                            _showSnack(
                              context,
                              'Servis kaydi silindi.',
                              false,
                            );
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    final services = repository.serviceViews();
    final pending = services
        .where((item) => item.record.status == 'Bekliyor')
        .toList();
    final inProgress = services
        .where((item) => item.record.status == 'Islemde')
        .toList();
    final completed = services
        .where(
          (item) =>
              item.record.status == 'Tamamlandi' ||
              item.record.status == 'Teslim Edildi',
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => CreateActionDialog(repository: repository),
            ),
            icon: const Icon(Icons.playlist_add_outlined),
            label: const Text('Yeni Islem'),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Islem Katalogu',
          child: Column(
            children: repository.actions
                .map(
                  (action) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(action.name),
                    subtitle: Text(
                      '${action.price.toStringAsFixed(0)} TL',
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Duzenle',
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (context) => EditActionDialog(
                              repository: repository,
                              action: action,
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Sil',
                          style: IconButton.styleFrom(
                            foregroundColor: const Color(0xFFFCA5A5),
                          ),
                          onPressed: () async {
                            final error = await repository.deleteAction(
                              action.id,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            if (error.isNotEmpty) {
                              _showSnack(context, error, true);
                              return;
                            }
                            _showSnack(context, 'Islem silindi.', false);
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Bekleyen Servisler',
          child: Column(
            children: pending.map((item) => _ServiceTile(view: item)).toList(),
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Islemdeki Servisler',
          child: Column(
            children: inProgress
                .map((item) => _ServiceTile(view: item))
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Tamamlanan / Teslim',
          child: Column(
            children: completed
                .map((item) => _ServiceTile(view: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sifre Sifirlama'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: '6 Haneli Kod'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Yeni Sifre'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final message = await widget.repository.sendPasswordResetCode(
              _email.text,
            );
            if (!context.mounted) {
              return;
            }
            _showSnack(
              context,
              message,
              !message.toLowerCase().contains('gonderildi'),
            );
          },
          child: const Text('Kod Gonder'),
        ),
        FilledButton(
          onPressed: () async {
            final error = await widget.repository.resetPassword(
              email: _email.text,
              code: _code.text,
              newPassword: _password.text,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
              return;
            }
            Navigator.of(context).pop();
            _showSnack(
              context,
              'Sifren guncellendi. Yeni sifrenle giris yapabilirsin.',
              false,
            );
          },
          child: const Text('Sifreyi Yenile'),
        ),
      ],
    );
  }
}

class CreateCustomerDialog extends StatefulWidget {
  const CreateCustomerDialog({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<CreateCustomerDialog> createState() => _CreateCustomerDialogState();
}

class _CreateCustomerDialogState extends State<CreateCustomerDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool createAccount = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Musteri'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Telefon'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Uye hesabi olustur'),
              value: createAccount,
              onChanged: (value) => setState(() => createAccount = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        FilledButton(
          onPressed: () async {
            final error = await widget.repository.createCustomer(
              fullName: _name.text,
              phone: _phone.text,
              email: _email.text,
              createAccount: createAccount,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
              return;
            }
            Navigator.of(context).pop();
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

class CreateDeviceDialog extends StatefulWidget {
  const CreateDeviceDialog({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<CreateDeviceDialog> createState() => _CreateDeviceDialogState();
}

class _CreateDeviceDialogState extends State<CreateDeviceDialog> {
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _issue = TextEditingController();
  int? selectedMemberId;

  @override
  void initState() {
    super.initState();
    if (widget.repository.members.isNotEmpty) {
      selectedMemberId = widget.repository.members.first.id;
    }
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _issue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Cihaz'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedMemberId,
              items: widget.repository.members
                  .map(
                    (member) => DropdownMenuItem(
                      value: member.id,
                      child: Text(member.fullName),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedMemberId = value),
              decoration: const InputDecoration(labelText: 'Musteri'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Marka'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _model,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _issue,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Ariza Aciklamasi'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        FilledButton(
          onPressed: selectedMemberId == null
              ? null
              : () async {
                  final error = await widget.repository.createDevice(
                    memberId: selectedMemberId!,
                    brand: _brand.text,
                    model: _model.text,
                    issueDescription: _issue.text,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  if (error.isNotEmpty) {
                    _showSnack(context, error, true);
                    return;
                  }
                  Navigator.of(context).pop();
                },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

class CreateServiceRecordDialog extends StatefulWidget {
  const CreateServiceRecordDialog({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<CreateServiceRecordDialog> createState() =>
      _CreateServiceRecordDialogState();
}

class _CreateServiceRecordDialogState extends State<CreateServiceRecordDialog> {
  int? selectedDeviceId;
  String status = 'Bekliyor';
  final Set<int> selectedActionIds = {};
  bool sendPriceApproval = false;

  @override
  void initState() {
    super.initState();
    if (widget.repository.devices.isNotEmpty) {
      selectedDeviceId = widget.repository.devices.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Servis Kaydi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedDeviceId,
              items: widget.repository.devices
                  .map(
                    (device) => DropdownMenuItem(
                      value: device.id,
                      child: Text('${device.brand} ${device.model}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedDeviceId = value),
              decoration: const InputDecoration(labelText: 'Cihaz'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              items: serviceStatusOptions
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => status = value ?? 'Bekliyor'),
              decoration: const InputDecoration(labelText: 'Durum'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fiyati onaya gonder'),
              subtitle: const Text(
                'Secili islem tutari musterinin onayina duser.',
              ),
              value: sendPriceApproval,
              onChanged: (value) =>
                  setState(() => sendPriceApproval = value),
            ),
            const SizedBox(height: 12),
            ...widget.repository.actions.map(
              (action) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: selectedActionIds.contains(action.id),
                title: Text(
                  '${action.name} • ${action.price.toStringAsFixed(0)} TL',
                ),
                onChanged: (selected) {
                  setState(() {
                    if (selected ?? false) {
                      selectedActionIds.add(action.id);
                    } else {
                      selectedActionIds.remove(action.id);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        FilledButton(
          onPressed: selectedDeviceId == null
              ? null
              : () async {
                  final error = await widget.repository.createServiceRecord(
                    deviceId: selectedDeviceId!,
                    status: status,
                    actionIds: selectedActionIds.toList(),
                    sendPriceApproval: sendPriceApproval,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  if (error.isNotEmpty) {
                    _showSnack(context, error, true);
                    return;
                  }
                  Navigator.of(context).pop();
                },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

class EditServiceRecordDialog extends StatefulWidget {
  const EditServiceRecordDialog({
    super.key,
    required this.repository,
    required this.record,
  });

  final AppRepository repository;
  final ServiceRecord record;

  @override
  State<EditServiceRecordDialog> createState() => _EditServiceRecordDialogState();
}

class _EditServiceRecordDialogState extends State<EditServiceRecordDialog> {
  late int selectedDeviceId = widget.record.deviceId;
  late String status = widget.record.status;
  late final Set<int> selectedActionIds = widget.record.actionIds.toSet();
  late bool sendPriceApproval =
      widget.record.priceApprovalStatus == 'Onay Bekliyor';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Servis Kaydini Duzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedDeviceId,
              items: widget.repository.devices
                  .map(
                    (device) => DropdownMenuItem(
                      value: device.id,
                      child: Text('${device.brand} ${device.model}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedDeviceId = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Cihaz'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              items: serviceStatusOptions
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => status = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Durum'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fiyati onaya gonder'),
              subtitle: Text(
                'Mevcut durum: ${widget.record.priceApprovalStatus}',
              ),
              value: sendPriceApproval,
              onChanged: (value) =>
                  setState(() => sendPriceApproval = value),
            ),
            const SizedBox(height: 12),
            ...widget.repository.actions.map(
              (action) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: selectedActionIds.contains(action.id),
                title: Text(
                  '${action.name} • ${action.price.toStringAsFixed(0)} TL',
                ),
                onChanged: (selected) {
                  setState(() {
                    if (selected ?? false) {
                      selectedActionIds.add(action.id);
                    } else {
                      selectedActionIds.remove(action.id);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        FilledButton(
          onPressed: () async {
            final error = await widget.repository.updateServiceRecord(
              serviceId: widget.record.id,
              deviceId: selectedDeviceId,
              date: widget.record.date,
              status: status,
              actionIds: selectedActionIds.toList(),
              sendPriceApproval: sendPriceApproval,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
              return;
            }
            Navigator.of(context).pop();
            _showSnack(context, 'Servis kaydi guncellendi.', false);
          },
          child: const Text('Guncelle'),
        ),
      ],
    );
  }
}

class CreateActionDialog extends StatefulWidget {
  const CreateActionDialog({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<CreateActionDialog> createState() => _CreateActionDialogState();
}

class _CreateActionDialogState extends State<CreateActionDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Islem'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Islem Adi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Fiyat'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        FilledButton(
          onPressed: () async {
            final price = double.tryParse(_price.text.replaceAll(',', '.'));
            if (_name.text.trim().isEmpty || price == null) {
              _showSnack(context, 'Islem adi ve fiyat gerekli.', true);
              return;
            }
            final error = await widget.repository.createAction(
              name: _name.text,
              price: price,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
              return;
            }
            Navigator.of(context).pop();
            _showSnack(context, 'Yeni islem eklendi.', false);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

class EditActionDialog extends StatefulWidget {
  const EditActionDialog({
    super.key,
    required this.repository,
    required this.action,
  });

  final AppRepository repository;
  final ServiceAction action;

  @override
  State<EditActionDialog> createState() => _EditActionDialogState();
}

class _EditActionDialogState extends State<EditActionDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.action.name,
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.action.price.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Islem Duzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Islem Adi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Fiyat'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        FilledButton(
          onPressed: () async {
            final price = double.tryParse(_price.text.replaceAll(',', '.'));
            if (_name.text.trim().isEmpty || price == null) {
              _showSnack(context, 'Islem adi ve fiyat gerekli.', true);
              return;
            }
            final error = await widget.repository.updateAction(
              actionId: widget.action.id,
              name: _name.text,
              price: price,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
              return;
            }
            Navigator.of(context).pop();
            _showSnack(context, 'Islem guncellendi.', false);
          },
          child: const Text('Guncelle'),
        ),
      ],
    );
  }
}

const List<String> serviceStatusOptions = [
  'Bekliyor',
  'Islemde',
  'Fiyat Onayi Bekliyor',
  'Tamamlandi',
  'Teslim Edildi',
  'Fiyat Reddedildi',
];

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.view,
    this.showMember = true,
    this.trailing,
  });

  final ServiceRecordView view;
  final bool showMember;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final actions = view.actions.isEmpty
        ? 'Henuz islem atanmis degil'
        : view.actions.map((action) => action.name).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${view.device.brand} ${view.device.model}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              _StatusChip(status: view.record.status),
            ],
          ),
          const SizedBox(height: 8),
          if (showMember)
            Text('${view.member.fullName} • ${view.member.phone}'),
          Text('Ariza: ${view.device.issueDescription}'),
          Text('Islemler: $actions'),
          Text('Tutar: ${view.record.totalPrice.toStringAsFixed(0)} TL'),
          if (view.record.priceApprovalStatus.isNotEmpty)
            Text('Fiyat onayi: ${view.record.priceApprovalStatus}'),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Bekliyor' => const Color(0xFFF59E0B),
      'Islemde' => const Color(0xFF0284C7),
      'Fiyat Onayi Bekliyor' => const Color(0xFFE11D48),
      'Tamamlandi' => const Color(0xFF16A34A),
      'Teslim Edildi' => const Color(0xFF7C3AED),
      'Fiyat Reddedildi' => const Color(0xFFEF4444),
      _ => const Color(0xFF475569),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x660F172A),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(height: 12),
                Text('Sunucu ile esleniyor...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});

  final List<_StatData> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 172,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.label),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AdminPanelHero extends StatelessWidget {
  const _AdminPanelHero({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    return _PanelHero(
      badge: 'Executive Overview',
      title: 'Servis operasyonlari tam kontrol altinda.',
      copy:
          'Bekleyen isleri, aktif akisi, gelir performansini ve son musteri hareketlerini tek mobil ekrandan izle.',
      trailing: '${data.completedRevenue.toStringAsFixed(0)} TL',
      trailingLabel: 'Tamamlanan ciro',
      colors: const [Color(0xFF0D6EFD), Color(0xFF11B980)],
    );
  }
}

class _MemberPanelHero extends StatelessWidget {
  const _MemberPanelHero({
    required this.name,
    required this.activeRequestCount,
    required this.totalRequestCount,
  });

  final String name;
  final int activeRequestCount;
  final int totalRequestCount;

  @override
  Widget build(BuildContext context) {
    return _PanelHero(
      badge: 'Canli Ozet',
      title: 'Hos geldin, ${name.split(' ').first}',
      copy:
          'Acik servislerini, gecmis kayitlarini ve yeni taleplerini tek ekrandan yonetebilirsin.',
      trailing: '$activeRequestCount / $totalRequestCount',
      trailingLabel: 'Aktif talep nabzi',
      colors: const [Color(0xFF07111F), Color(0xFF0EA5E9)],
    );
  }
}

class _PanelHero extends StatelessWidget {
  const _PanelHero({
    required this.badge,
    required this.title,
    required this.copy,
    required this.trailing,
    required this.trailingLabel,
    required this.colors,
  });

  final String badge;
  final String title;
  final String copy;
  final String trailing;
  final String trailingLabel;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBadge(label: badge),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            copy,
            style: const TextStyle(color: Color(0xFFEFF6FF), height: 1.45),
          ),
          const SizedBox(height: 16),
          _HeroMiniStat(label: trailingLabel, value: trailing),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFDDEBFF), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;
}

void _showSnack(BuildContext context, String message, bool isError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? const Color(0xFFB91C1C)
          : const Color(0xFF0F766E),
    ),
  );
}
