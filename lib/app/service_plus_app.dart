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
    const primary = Color(0xFF0B1F3A);
    const secondary = Color(0xFF2563EB);
    const background = Color(0xFFF3F7FC);
    const surface = Color(0xFFFFFFFF);
    const border = Color(0xFFD7E2F0);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          secondary: secondary,
          tertiary: const Color(0xFF0F766E),
          surface: surface,
          surfaceContainerHighest: const Color(0xFFEAF2FB),
          error: const Color(0xFFDC2626),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w900),
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w800),
        bodyMedium: TextStyle(height: 1.35),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: const Color(0x1A0F172A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIconColor: const Color(0xFF64748B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 8,
        shadowColor: const Color(0x1A0F172A),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        labelColor: primary,
        unselectedLabelColor: Color(0xFF64748B),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: const Color(0xFFDDF7EE),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final authCard = _AuthCard(
              controller: _tabController,
              memberLogin: _buildMemberLogin(context),
              register: _buildRegister(context),
              adminLogin: _buildAdminLogin(context),
            );

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 1080 : 560),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _AuthShowcase()),
                            const SizedBox(width: 22),
                            SizedBox(width: 430, child: authCard),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _AuthShowcase(compact: true),
                            const SizedBox(height: 16),
                            authCard,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberLogin(BuildContext context) {
    return _AuthFormLayout(
      children: [
        TextField(
          controller: _memberLoginEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.alternate_email_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _memberLoginPassword,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Sifre',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
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
            icon: const Icon(Icons.login_outlined),
            label: const Text('Panele Gir'),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) =>
                  PasswordResetDialog(repository: widget.repository),
            ),
            icon: const Icon(Icons.key_outlined, size: 18),
            label: const Text('Sifremi Unuttum'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegister(BuildContext context) {
    return _AuthFormLayout(
      children: [
        TextField(
          controller: _registerName,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _registerPhone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefon',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _registerEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.alternate_email_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _registerPassword,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Sifre',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
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
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Kayit Ol'),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLogin(BuildContext context) {
    return _AuthFormLayout(
      children: [
        TextField(
          controller: _adminUser,
          decoration: const InputDecoration(
            labelText: 'Kullanici Adi',
            prefixIcon: Icon(Icons.admin_panel_settings_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _adminPassword,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Sifre',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
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
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Admin Girisi'),
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.controller,
    required this.memberLogin,
    required this.register,
    required this.adminLogin,
  });

  final TabController controller;
  final Widget memberLogin;
  final Widget register;
  final Widget adminLogin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.home_repair_service_outlined,
                    color: Color(0xFF0B1F3A),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servis Plus Mobile',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Hesabina guvenli gecis',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TabBar(
              controller: controller,
              tabs: const [
                Tab(text: 'Uye Giris'),
                Tab(text: 'Kayit'),
                Tab(text: 'Admin'),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 390,
              child: TabBarView(
                controller: controller,
                children: [memberLogin, register, adminLogin],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthFormLayout extends StatelessWidget {
  const _AuthFormLayout({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _AuthShowcase extends StatelessWidget {
  const _AuthShowcase({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 250 : 560),
      padding: EdgeInsets.all(compact ? 20 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF071A33), Color(0xFF123A66), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x300B1F3A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _HeroBadge(label: 'Servis Plus Mobile'),
          const SizedBox(height: 22),
          Text(
            'Teknik servis akisini elinin altina al.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 30 : 42,
              height: 1.04,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Talep, fiyat onayi, servis takibi ve admin operasyonlari ayni mobil deneyimde.',
            style: TextStyle(color: Color(0xFFEFF6FF), height: 1.45),
          ),
          if (!compact) const SizedBox(height: 28),
          const _ServiceDeskIllustration(),
          if (compact) const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _ServiceDeskIllustration extends StatelessWidget {
  const _ServiceDeskIllustration();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.42,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26071A33),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: Color(0xFF0B1F3A),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Isletmemiz ne sunuyor?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF0B1F3A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Guvenli, hizli ve seffaf teknik servis deneyimi.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: const [
                        Expanded(
                          child: _BusinessHighlightTile(
                            icon: Icons.flash_on_outlined,
                            title: 'Hizli Islem',
                            copy:
                                'Talep alininca kayit acilir, servis sureci bekletmeden baslar.',
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _BusinessHighlightTile(
                            icon: Icons.price_check_outlined,
                            title: 'Seffaf Fiyat',
                            copy:
                                'Fiyat kalemleri tek tek gorunur, onay senden gelmeden ilerlemez.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      children: const [
                        Expanded(
                          child: _BusinessHighlightTile(
                            icon: Icons.engineering_outlined,
                            title: 'Uzman Servis',
                            copy:
                                'Cihaz arizasi uzman ekip tarafindan kontrol edilir ve raporlanir.',
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _BusinessHighlightTile(
                            icon: Icons.notifications_active_outlined,
                            title: 'Mobil Takip',
                            copy:
                                'Servis durumu, fiyat onayi ve teslim bilgisi panelden izlenir.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessHighlightTile extends StatelessWidget {
  const _BusinessHighlightTile({
    required this.icon,
    required this.title,
    required this.copy,
  });

  final IconData icon;
  final String title;
  final String copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0B1F3A), size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0B1F3A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  copy,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      ActionCatalogScreen(repository: widget.repository),
      OperationsScreen(repository: widget.repository),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        actions: [
          IconButton(
            tooltip: 'Admin sifresi',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) =>
                  AdminPasswordDialog(repository: widget.repository),
            ),
            icon: const Icon(Icons.lock_reset_outlined),
          ),
          IconButton(
            tooltip: 'Cikis',
            onPressed: widget.repository.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
            icon: Icon(Icons.format_list_bulleted_outlined),
            label: 'Islem',
          ),
          NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'Takip'),
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
    final memberRequests = member == null
        ? const <ServiceRecordView>[]
        : repository.serviceViewsForMember(member.id);
    final priceOffers = memberRequests
        .where((item) => item.record.priceApprovalStatus == 'Onay Bekliyor')
        .toList();
    final completedNews = memberRequests
        .where((item) => item.record.status == 'Tamamlandi')
        .take(3)
        .toList();

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
        if (priceOffers.isNotEmpty) ...[
          _SectionCard(
            title: 'Fiyat Onayi Bekleyen',
            child: Column(
              children: priceOffers
                  .map(
                    (item) => _MemberRequestCard(
                      view: item,
                      repository: repository,
                      compact: true,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
        ],
        _SectionCard(
          title: 'Son Talepler',
          child: Column(
            children: data.recentRequests.isEmpty
                ? const [Text('Henuz servis talebi bulunmuyor.')]
                : data.recentRequests
                      .map(
                        (item) => _MemberRequestCard(
                          view: item,
                          repository: repository,
                          compact: true,
                        ),
                      )
                      .toList(),
          ),
        ),
        if (completedNews.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Servis Haberleri',
            child: Column(
              children: completedNews
                  .map((item) => _ServiceNotificationCard(view: item))
                  .toList(),
            ),
          ),
        ],
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
            children: requests.isEmpty
                ? const [Text('Henuz servis kaydin yok.')]
                : requests
                      .map(
                        (item) => _MemberRequestCard(
                          view: item,
                          repository: repository,
                        ),
                      )
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
        const _FeatureHero(
          icon: Icons.add_task_outlined,
          badge: 'Yeni Talep',
          title: 'Cihazini anlat, servis akisini baslatalim.',
          copy:
              'Marka, model ve ariza detayini eklediginde kayit servis ekibine duser.',
          colors: [Color(0xFF115E59), Color(0xFF0F766E)],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Talep Bilgileri',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _brand,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Marka',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _model,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _issue,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ariza Aciklamasi',
                  prefixIcon: Icon(Icons.report_problem_outlined),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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
                    final message = await widget.repository
                        .createServiceRequest(
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
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Talep Gonder'),
                ),
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
    final member = widget.repository.currentMember!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ProfileSummaryCard(member: member),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Profil Bilgileri',
          child: Column(
            children: [
              TextField(
                controller: _fullName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Yeni Sifre',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Profili Guncelle'),
                ),
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
        _FeatureHero(
          icon: Icons.build_circle_outlined,
          badge: 'Servis Merkezi',
          title: '${services.length} servis kaydi tek akista.',
          copy:
              'Kayitlari kompakt izle, satiri acip fiyat kalemlerini ve operasyon detaylarini guncelle.',
          colors: const [Color(0xFF312E81), Color(0xFF0F766E)],
          action: FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) =>
                  CreateServiceRecordDialog(repository: repository),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Servis Ekle'),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Servis Kayitlari',
          child: Column(
            children: services.isEmpty
                ? const [Text('Servis kaydi bulunmuyor.')]
                : services
                      .map(
                        (item) => _AdminServiceExpansionCard(
                          view: item,
                          repository: repository,
                        ),
                      )
                      .toList(),
          ),
        ),
      ],
    );
  }
}

class ActionCatalogScreen extends StatefulWidget {
  const ActionCatalogScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<ActionCatalogScreen> createState() => _ActionCatalogScreenState();
}

class _ActionCatalogScreenState extends State<ActionCatalogScreen> {
  String selectedCategory = 'Tum';

  @override
  Widget build(BuildContext context) {
    final actions = widget.repository.actions;
    final categories = _actionCategories(actions);
    final filteredActions = selectedCategory == 'Tum'
        ? actions
        : actions
              .where((action) => action.displayCategory == selectedCategory)
              .toList();
    final groupedActions = _actionsByCategory(filteredActions);
    final averagePrice = actions.isEmpty
        ? 0
        : actions.fold<double>(0, (sum, action) => sum + action.price) /
              actions.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 430,
              child: Text(
                'Katalogu kategoriye gore suz, fiyat araligini hizli kontrol et.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) =>
                    CreateActionDialog(repository: widget.repository),
              ),
              icon: const Icon(Icons.playlist_add_outlined),
              label: const Text('Yeni Islem'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatsGrid(
          items: [
            _StatData(
              'Islem',
              actions.length.toString(),
              const Color(0xFF0F766E),
            ),
            _StatData(
              'Kategori',
              categories.length.toString(),
              const Color(0xFF2563EB),
            ),
            _StatData(
              'Ortalama',
              '${averagePrice.toStringAsFixed(0)} TL',
              const Color(0xFFD97706),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Tum'),
              selected: selectedCategory == 'Tum',
              onSelected: (_) => setState(() => selectedCategory = 'Tum'),
            ),
            ...categories.map(
              (category) => Tooltip(
                message: category,
                child: ChoiceChip(
                  label: Text(_shortCategoryLabel(category)),
                  selected: selectedCategory == category,
                  onSelected: (_) =>
                      setState(() => selectedCategory = category),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (groupedActions.isEmpty)
          const _SectionCard(
            title: 'Islem Katalogu',
            child: Text('Bu kategoride islem bulunmuyor.'),
          )
        else
          ...groupedActions.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SectionCard(
                title:
                    '${_shortCategoryLabel(entry.key)} (${entry.value.length})',
                child: Column(
                  children: entry.value
                      .map(
                        (action) => _ActionCatalogTile(
                          action: action,
                          repository: widget.repository,
                        ),
                      )
                      .toList(),
                ),
              ),
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
    final pricePending = services
        .where((item) => item.record.status == 'Fiyat Onayi Bekliyor')
        .toList();
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
        _StatsGrid(
          items: [
            _StatData(
              'Bekleyen',
              pending.length.toString(),
              const Color(0xFFF59E0B),
            ),
            _StatData(
              'Onay',
              pricePending.length.toString(),
              const Color(0xFFE11D48),
            ),
            _StatData(
              'Islemde',
              inProgress.length.toString(),
              const Color(0xFF0284C7),
            ),
            _StatData(
              'Tamam',
              completed.length.toString(),
              const Color(0xFF16A34A),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Fiyat Onayi Bekleyen',
          child: Column(
            children: pricePending
                .map((item) => _ServiceTile(view: item))
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

class _ActionCatalogTile extends StatelessWidget {
  const _ActionCatalogTile({required this.action, required this.repository});

  final ServiceAction action;
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  action.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              _MiniPill(label: _shortCategoryLabel(action.displayCategory)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${action.priceRangeLabel} • Ort. ${action.price.toStringAsFixed(0)} TL',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (action.description.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              action.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF475569), height: 1.35),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
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
                    final error = await repository.deleteAction(action.id);
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
        ],
      ),
    );
  }
}

class AdminPasswordDialog extends StatefulWidget {
  const AdminPasswordDialog({super.key, required this.repository});

  final AppRepository repository;

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
  late final TextEditingController _username = TextEditingController(
    text: widget.repository.activeAdminUsername ?? '',
  );
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _current.dispose();
    _newPassword.dispose();
    _repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin Sifresi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(
                labelText: 'Kullanici Adi',
                prefixIcon: Icon(Icons.admin_panel_settings_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mevcut Sifre',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Sifre',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repeat,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Sifre Tekrar',
                prefixIcon: Icon(Icons.lock_reset_outlined),
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
            final username = _username.text.trim();
            final passwordWillChange =
                _newPassword.text.isNotEmpty || _repeat.text.isNotEmpty;

            if (username.length < 3 || username.length > 50) {
              _showSnack(
                context,
                'Kullanici adi 3-50 karakter arasinda olmali.',
                true,
              );
              return;
            }
            if (passwordWillChange && _newPassword.text.length < 5) {
              _showSnack(context, 'Yeni sifre en az 5 karakter olmali.', true);
              return;
            }
            if (passwordWillChange && _newPassword.text != _repeat.text) {
              _showSnack(context, 'Yeni sifreler eslesmiyor.', true);
              return;
            }

            final error = await widget.repository.changeAdminPassword(
              currentPassword: _current.text,
              newPassword: _newPassword.text,
              newUsername: username,
            );
            if (!context.mounted) {
              return;
            }
            if (error.isNotEmpty) {
              _showSnack(context, error, true);
              return;
            }
            Navigator.of(context).pop();
            _showSnack(context, 'Admin hesabi guncellendi.', false);
          },
          child: const Text('Guncelle'),
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
              value: selectedMemberId,
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
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedDeviceId,
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
                value: status,
                items: serviceStatusOptions
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
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
                onChanged: (value) => setState(() => sendPriceApproval = value),
              ),
              const SizedBox(height: 12),
              _ServiceActionSelector(
                actions: widget.repository.actions,
                selectedActionIds: selectedActionIds,
                onActionChanged: (actionId, selected) {
                  setState(() {
                    if (selected) {
                      selectedActionIds.add(actionId);
                    } else {
                      selectedActionIds.remove(actionId);
                    }
                  });
                },
              ),
            ],
          ),
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
  State<EditServiceRecordDialog> createState() =>
      _EditServiceRecordDialogState();
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
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedDeviceId,
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
                value: status,
                items: serviceStatusOptions
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
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
                onChanged: (value) => setState(() => sendPriceApproval = value),
              ),
              const SizedBox(height: 12),
              _ServiceActionSelector(
                actions: widget.repository.actions,
                selectedActionIds: selectedActionIds,
                onActionChanged: (actionId, selected) {
                  setState(() {
                    if (selected) {
                      selectedActionIds.add(actionId);
                    } else {
                      selectedActionIds.remove(actionId);
                    }
                  });
                },
              ),
            ],
          ),
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

class _ServiceActionSelector extends StatefulWidget {
  const _ServiceActionSelector({
    required this.actions,
    required this.selectedActionIds,
    required this.onActionChanged,
  });

  final List<ServiceAction> actions;
  final Set<int> selectedActionIds;
  final void Function(int actionId, bool selected) onActionChanged;

  @override
  State<_ServiceActionSelector> createState() => _ServiceActionSelectorState();
}

class _ServiceActionSelectorState extends State<_ServiceActionSelector> {
  final TextEditingController _search = TextEditingController();
  String selectedCategory = 'Tum';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _actionCategories(widget.actions);
    final query = _search.text.trim().toLowerCase();
    final filteredActions = widget.actions.where((action) {
      final matchesCategory =
          selectedCategory == 'Tum' ||
          action.displayCategory == selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          action.name.toLowerCase().contains(query) ||
          action.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
    final groupedActions = _actionsByCategory(filteredActions);
    final selectedTotal = widget.actions
        .where((action) => widget.selectedActionIds.contains(action.id))
        .fold<double>(0, (sum, action) => sum + action.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _SelectorStat(
                label: 'Secili',
                value: widget.selectedActionIds.length.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SelectorStat(
                label: 'Tutar',
                value: '${selectedTotal.toStringAsFixed(0)} TL',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Islem ara',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Tum'),
              selected: selectedCategory == 'Tum',
              onSelected: (_) => setState(() => selectedCategory = 'Tum'),
            ),
            ...categories.map(
              (category) => Tooltip(
                message: category,
                child: ChoiceChip(
                  label: Text(_shortCategoryLabel(category)),
                  selected: selectedCategory == category,
                  onSelected: (_) =>
                      setState(() => selectedCategory = category),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (groupedActions.isEmpty)
          const Text('Bu filtrede islem bulunmuyor.')
        else
          ...groupedActions.entries.map(
            (entry) => _ActionSelectorGroup(
              category: entry.key,
              actions: entry.value,
              selectedActionIds: widget.selectedActionIds,
              initiallyExpanded:
                  selectedCategory != 'Tum' ||
                  entry.value.any(
                    (action) => widget.selectedActionIds.contains(action.id),
                  ),
              onActionChanged: widget.onActionChanged,
            ),
          ),
      ],
    );
  }
}

class _SelectorStat extends StatelessWidget {
  const _SelectorStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _ActionSelectorGroup extends StatelessWidget {
  const _ActionSelectorGroup({
    required this.category,
    required this.actions,
    required this.selectedActionIds,
    required this.initiallyExpanded,
    required this.onActionChanged,
  });

  final String category;
  final List<ServiceAction> actions;
  final Set<int> selectedActionIds;
  final bool initiallyExpanded;
  final void Function(int actionId, bool selected) onActionChanged;

  @override
  Widget build(BuildContext context) {
    final selectedCount = actions
        .where((action) => selectedActionIds.contains(action.id))
        .length;

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      title: Text(
        _shortCategoryLabel(category),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        selectedCount == 0
            ? '${actions.length} islem'
            : '$selectedCount secili / ${actions.length}',
      ),
      children: actions.map((action) {
        final selected = selectedActionIds.contains(action.id);
        return InkWell(
          onTap: () => onActionChanged(action.id, !selected),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFDDF7EE)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? const Color(0xFF0F766E)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) =>
                      onActionChanged(action.id, value ?? false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              action.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${action.price.toStringAsFixed(0)} TL',
                            style: const TextStyle(
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.priceRangeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF0369A1)),
                      ),
                      if (action.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          action.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
  final _category = TextEditingController(text: 'Genel');
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    _price.dispose();
    _description.dispose();
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
              controller: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Min Fiyat'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxPrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Max Fiyat'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Ortalama Fiyat'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Aciklama'),
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
            final minPrice = _parseMoney(_minPrice.text);
            final maxPrice = _parseMoney(_maxPrice.text);
            final price = _effectiveActionPrice(
              _parseMoney(_price.text),
              minPrice,
              maxPrice,
            );
            if (_name.text.trim().isEmpty ||
                _category.text.trim().isEmpty ||
                price <= 0) {
              _showSnack(
                context,
                'Islem adi, kategori ve fiyat gerekli.',
                true,
              );
              return;
            }
            final error = await widget.repository.createAction(
              name: _name.text,
              price: price,
              category: _category.text,
              minPrice: minPrice,
              maxPrice: maxPrice,
              description: _description.text,
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
  late final TextEditingController _category = TextEditingController(
    text: widget.action.displayCategory,
  );
  late final TextEditingController _minPrice = TextEditingController(
    text: _moneyInput(widget.action.minPrice),
  );
  late final TextEditingController _maxPrice = TextEditingController(
    text: _moneyInput(widget.action.maxPrice),
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.action.price.toStringAsFixed(0),
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.action.description,
  );

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    _price.dispose();
    _description.dispose();
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
              controller: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Min Fiyat'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxPrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Max Fiyat'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Ortalama Fiyat'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Aciklama'),
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
            final minPrice = _parseMoney(_minPrice.text);
            final maxPrice = _parseMoney(_maxPrice.text);
            final price = _effectiveActionPrice(
              _parseMoney(_price.text),
              minPrice,
              maxPrice,
            );
            if (_name.text.trim().isEmpty ||
                _category.text.trim().isEmpty ||
                price <= 0) {
              _showSnack(
                context,
                'Islem adi, kategori ve fiyat gerekli.',
                true,
              );
              return;
            }
            final error = await widget.repository.updateAction(
              actionId: widget.action.id,
              name: _name.text,
              price: price,
              category: _category.text,
              minPrice: minPrice,
              maxPrice: maxPrice,
              description: _description.text,
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

List<String> _actionCategories(List<ServiceAction> actions) {
  final categories =
      actions.map((action) => action.displayCategory).toSet().toList()..sort();
  return categories;
}

Map<String, List<ServiceAction>> _actionsByCategory(
  List<ServiceAction> actions,
) {
  final grouped = <String, List<ServiceAction>>{};
  for (final action in actions) {
    grouped.putIfAbsent(action.displayCategory, () => []).add(action);
  }

  final sortedEntries = grouped.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return {
    for (final entry in sortedEntries)
      entry.key: entry.value..sort((a, b) => a.name.compareTo(b.name)),
  };
}

double _parseMoney(String value) {
  var normalized = value.trim().replaceAll(' ', '');
  if (normalized.contains(',') && normalized.contains('.')) {
    normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
  } else {
    normalized = normalized.replaceAll(',', '.');
  }
  return double.tryParse(normalized) ?? 0;
}

double _effectiveActionPrice(double price, double minPrice, double maxPrice) {
  if (price > 0) {
    return price;
  }
  if (minPrice > 0 && maxPrice > 0) {
    return (minPrice + maxPrice) / 2;
  }
  return 0;
}

String _moneyInput(double value) => value <= 0 ? '' : value.toStringAsFixed(0);

String _shortCategoryLabel(String category) {
  return switch (category.trim()) {
    'Yazilim & Destek' => 'Yazilim',
    'Oyun Konsolu' => 'Konsol',
    'Masaustu' => 'PC',
    '' => 'Genel',
    _ => category.trim(),
  };
}

String _money(double value) => '${value.toStringAsFixed(0)} TL';

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDate(local)} $hour:$minute';
}

bool _isPriceOfferPending(ServiceRecordView view) {
  return view.record.priceApprovalStatus == 'Onay Bekliyor';
}

bool _looksLikeError(String message) {
  final lower = message.toLowerCase();
  return lower.contains('bulunamadi') ||
      lower.contains('hata') ||
      lower.contains('hatali') ||
      lower.contains('yok') ||
      lower.contains('sorun') ||
      lower.contains('basarisiz');
}

class _FeatureHero extends StatelessWidget {
  const _FeatureHero({
    required this.icon,
    required this.badge,
    required this.title,
    required this.copy,
    required this.colors,
    this.action,
  });

  final IconData icon;
  final String badge;
  final String title;
  final String copy;
  final List<Color> colors;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const Spacer(),
              _HeroBadge(label: badge),
            ],
          ),
          const SizedBox(height: 18),
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
            style: const TextStyle(color: Color(0xFFEFF6FF), height: 1.42),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: action!),
          ],
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFDDF7EE),
            foregroundColor: const Color(0xFF0F766E),
            child: Text(
              member.fullName.trim().isEmpty
                  ? 'U'
                  : member.fullName.trim().characters.first.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.email} • ${member.phone}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniPill(
                      label: 'Kayit ${_formatDate(member.registeredAt)}',
                    ),
                    _MiniPill(
                      label: member.lastLoginAt == null
                          ? 'Ilk giris'
                          : 'Son giris ${_formatDate(member.lastLoginAt!)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceNotificationCard extends StatelessWidget {
  const _ServiceNotificationCard({required this.view});

  final ServiceRecordView view;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${view.device.brand} ${view.device.model} hazir',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Servis islemi tamamlandi. Teslim icin servis noktasina gelebilirsin.',
                  style: const TextStyle(color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRequestCard extends StatelessWidget {
  const _MemberRequestCard({
    required this.view,
    required this.repository,
    this.compact = false,
  });

  final ServiceRecordView view;
  final AppRepository repository;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final awaitingOffer = _isPriceOfferPending(view);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: awaitingOffer ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: awaitingOffer
              ? const Color(0xFFFDE68A)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: awaitingOffer
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFE6F6F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  awaitingOffer
                      ? Icons.price_check_outlined
                      : Icons.phone_android_outlined,
                  color: awaitingOffer
                      ? const Color(0xFFD97706)
                      : const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${view.device.brand} ${view.device.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      view.device.issueDescription,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(view.record.date),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatusChip(status: view.record.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PriceBreakdown(view: view, dense: compact && !awaitingOffer),
          if (awaitingOffer) ...[
            const SizedBox(height: 12),
            _OfferDecisionBar(view: view, repository: repository),
          ] else if (view.record.priceApprovalStatus.isNotEmpty) ...[
            const SizedBox(height: 10),
            _MiniPill(label: 'Fiyat onayi: ${view.record.priceApprovalStatus}'),
          ],
        ],
      ),
    );
  }
}

class _OfferDecisionBar extends StatelessWidget {
  const _OfferDecisionBar({required this.view, required this.repository});

  final ServiceRecordView view;
  final AppRepository repository;

  Future<void> _answer(BuildContext context, bool accepted) async {
    final message = await repository.answerPriceOffer(
      serviceId: view.record.id,
      accepted: accepted,
    );
    if (!context.mounted) {
      return;
    }
    _showSnack(
      context,
      message.isEmpty ? 'Fiyat onayi guncellendi.' : message,
      _looksLikeError(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.end,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              'Teklifi yanitla',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          TextButton.icon(
            onPressed: () => _answer(context, false),
            icon: const Icon(Icons.close_outlined),
            label: const Text('Reddet'),
          ),
          FilledButton.icon(
            onPressed: () => _answer(context, true),
            icon: const Icon(Icons.check_outlined),
            label: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.view, this.dense = false});

  final ServiceRecordView view;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (view.actions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Fiyat kalemleri servis incelemesinden sonra gorunecek.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    final visibleActions = dense ? view.actions.take(2).toList() : view.actions;
    final hiddenCount = view.actions.length - visibleActions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ...visibleActions.map((action) => _PriceLine(action: action)),
          if (hiddenCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _MiniPill(label: '+$hiddenCount islem daha'),
              ),
            ),
          const Divider(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Toplam teklif',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                _money(view.record.totalPrice),
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.action});

  final ServiceAction action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.handyman_outlined,
              size: 16,
              color: Color(0xFF0369A1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (action.description.trim().isNotEmpty)
                  Text(
                    action.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _money(action.price),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _AdminServiceExpansionCard extends StatelessWidget {
  const _AdminServiceExpansionCard({
    required this.view,
    required this.repository,
  });

  final ServiceRecordView view;
  final AppRepository repository;

  Future<void> _delete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Servis kaydi silinsin mi?'),
        content: Text(
          '${view.member.fullName} - ${view.device.brand} ${view.device.model} kaydi kaldirilacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgec'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) {
      return;
    }
    final error = await repository.deleteServiceRecord(view.record.id);
    if (!context.mounted) {
      return;
    }
    if (error.isNotEmpty) {
      _showSnack(context, error, true);
      return;
    }
    _showSnack(context, 'Servis kaydi silindi.', false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F6F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.build_outlined,
            color: Color(0xFF0F766E),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                view.member.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(view.record.date),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${view.device.brand} ${view.device.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: view.record.status),
            ],
          ),
        ),
        children: [
          _InfoLine(
            icon: Icons.report_problem_outlined,
            text: view.device.issueDescription,
          ),
          _InfoLine(
            icon: Icons.person_outline,
            text: '${view.member.phone} • ${view.member.email}',
          ),
          const SizedBox(height: 8),
          _PriceBreakdown(view: view),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => EditServiceRecordDialog(
                    repository: repository,
                    record: view.record,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Duzenle'),
              ),
              FilledButton.tonal(
                onPressed: () => _delete(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Sil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${view.device.brand} ${view.device.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(view.record.date),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(status: view.record.status),
              if (view.record.priceApprovalStatus.isNotEmpty)
                _MiniPill(label: 'Onay: ${view.record.priceApprovalStatus}'),
              _MiniPill(label: _money(view.record.totalPrice)),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight, child: trailing!),
          ],
          const SizedBox(height: 10),
          if (showMember)
            _InfoLine(
              icon: Icons.person_outline,
              text: '${view.member.fullName} • ${view.member.phone}',
            ),
          _InfoLine(
            icon: Icons.report_problem_outlined,
            text: view.device.issueDescription,
          ),
          const SizedBox(height: 10),
          _ActionSummaryChips(actions: view.actions),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF475569), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSummaryChips extends StatelessWidget {
  const _ActionSummaryChips({required this.actions});

  final List<ServiceAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const _MiniPill(label: 'Islem atanmadı');
    }

    final visibleActions = actions.take(3).toList();
    final hiddenCount = actions.length - visibleActions.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...visibleActions.map(
          (action) => Tooltip(
            message: action.name,
            child: _MiniPill(
              label:
                  '${_compactActionName(action.name)} • ${_shortCategoryLabel(action.displayCategory)}',
            ),
          ),
        ),
        if (hiddenCount > 0) _MiniPill(label: '+$hiddenCount islem'),
      ],
    );
  }
}

String _compactActionName(String value) {
  final trimmed = value.trim();
  if (trimmed.length <= 22) {
    return trimmed;
  }
  return '${trimmed.substring(0, 21)}...';
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
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
