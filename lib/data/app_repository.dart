import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_models.dart';

class AppRepository extends ChangeNotifier {
  AppRepository({http.Client? client, String? apiBaseUrl})
    : _client = client ?? http.Client(),
      _apiBaseUrl = apiBaseUrl ?? _defaultApiBaseUrl();

  final http.Client _client;
  final String _apiBaseUrl;

  final List<Member> _members = [];
  final List<Device> _devices = [];
  final List<ServiceAction> _actions = [];
  final List<ServiceRecord> _serviceRecords = [];

  UserRole? _activeRole;
  int? _activeMemberId;
  String? _activeAdminUsername;
  bool _isBusy = false;

  UserRole? get activeRole => _activeRole;
  bool get isMemberAuthenticated => _activeRole == UserRole.member;
  bool get isAdminAuthenticated => _activeRole == UserRole.admin;
  bool get isBusy => _isBusy;
  Member? get currentMember {
    if (_activeMemberId == null) {
      return null;
    }

    for (final member in _members) {
      if (member.id == _activeMemberId) {
        return member;
      }
    }
    return null;
  }

  List<Member> get members => List.unmodifiable(_members);
  List<Device> get devices => List.unmodifiable(_devices);
  List<ServiceAction> get actions => List.unmodifiable(_actions);
  List<ServiceRecord> get serviceRecords => List.unmodifiable(_serviceRecords);

  Future<String> loginMember({
    required String email,
    required String password,
  }) async {
    return _run(() async {
      final data = await _postJson('member/login', {
        'email': email.trim(),
        'password': password,
      });
      _applyMemberSync(data);
      return '';
    });
  }

  Future<String> registerMember({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      final data = await _postJson('member/register', {
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password,
      });
      _applyMemberSync(data);
      return '';
    });
  }

  Future<String> loginAdmin({
    required String username,
    required String password,
  }) async {
    return _run(() async {
      final data = await _postJson('admin/login', {
        'username': username.trim(),
        'password': password,
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> changeAdminPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('admin/password', {
        'adminUsername': _activeAdminUsername,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> sendPasswordResetCode(String email) async {
    return _runMessage(() async {
      final data = await _postJson('member/password-reset-code', {
        'email': email.trim(),
      });
      return (data['message'] as String?) ?? 'Kod e-posta adresine gonderildi.';
    });
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return _run(() async {
      await _postJson('member/password-reset', {
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      });
      return '';
    });
  }

  Future<String> updateProfile({
    required String fullName,
    required String phone,
    required String email,
    String? newPassword,
  }) async {
    final member = currentMember;
    if (member == null) {
      return 'Aktif uye bulunamadi.';
    }

    return _run(() async {
      final data = await _putJson('member/${member.id}/profile', {
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'newPassword': (newPassword ?? '').trim(),
      });
      _applyMemberSync(data);
      return '';
    });
  }

  Future<String> createServiceRequest({
    required String brand,
    required String model,
    required String issueDescription,
  }) async {
    final member = currentMember;
    if (member == null) {
      return 'Aktif uye bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('member/${member.id}/service-requests', {
        'brand': brand.trim(),
        'model': model.trim(),
        'issueDescription': issueDescription.trim(),
      });
      _applyMemberSync(data);
      return (data['message'] as String?) ?? '';
    });
  }

  Future<String> createCustomer({
    required String fullName,
    required String phone,
    required String email,
    bool createAccount = false,
  }) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('admin/members', {
        'adminUsername': _activeAdminUsername,
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'createAccount': createAccount,
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> createDevice({
    required int memberId,
    required String brand,
    required String model,
    required String issueDescription,
  }) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('admin/devices', {
        'adminUsername': _activeAdminUsername,
        'memberId': memberId,
        'brand': brand.trim(),
        'model': model.trim(),
        'issueDescription': issueDescription.trim(),
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> createServiceRecord({
    required int deviceId,
    required String status,
    required List<int> actionIds,
    bool sendPriceApproval = false,
  }) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('admin/services', {
        'adminUsername': _activeAdminUsername,
        'deviceId': deviceId,
        'status': status,
        'actionIds': actionIds,
        'sendPriceApproval': sendPriceApproval,
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> updateServiceRecord({
    required int serviceId,
    required int deviceId,
    required DateTime date,
    required String status,
    required List<int> actionIds,
    bool sendPriceApproval = false,
  }) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _putJson('admin/services/$serviceId', {
        'adminUsername': _activeAdminUsername,
        'deviceId': deviceId,
        'date': date.toUtc().toIso8601String(),
        'status': status,
        'actionIds': actionIds,
        'sendPriceApproval': sendPriceApproval,
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> deleteServiceRecord(int serviceId) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('admin/services/$serviceId/delete', {
        'adminUsername': _activeAdminUsername,
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> createAction({
    required String name,
    required double price,
    required String category,
    required double minPrice,
    required double maxPrice,
    required String description,
  }) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('admin/actions', {
        'adminUsername': _activeAdminUsername,
        'name': name.trim(),
        'price': price,
        'category': category.trim(),
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'description': description.trim(),
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> updateAction({
    required int actionId,
    required String name,
    required double price,
    required String category,
    required double minPrice,
    required double maxPrice,
    required String description,
  }) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _putJson('admin/actions/$actionId', {
        'adminUsername': _activeAdminUsername,
        'name': name.trim(),
        'price': price,
        'category': category.trim(),
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'description': description.trim(),
      });
      _applyAdminSync(data);
      return '';
    });
  }

  Future<String> deleteAction(int actionId) async {
    if ((_activeAdminUsername ?? '').isEmpty) {
      return 'Admin oturumu bulunamadi.';
    }

    return _run(() async {
      final data = await _postJson('admin/actions/$actionId/delete', {
        'adminUsername': _activeAdminUsername,
      });
      _applyAdminSync(data);
      return '';
    });
  }

  void logout() {
    _activeRole = null;
    _activeMemberId = null;
    _activeAdminUsername = null;
    _members.clear();
    _devices.clear();
    _actions.clear();
    _serviceRecords.clear();
    notifyListeners();
  }

  MemberDashboardData memberDashboard() {
    final member = currentMember;
    if (member == null) {
      return const MemberDashboardData(
        deviceCount: 0,
        activeRequestCount: 0,
        totalRequestCount: 0,
        recentRequests: [],
      );
    }

    final requests = serviceViewsForMember(member.id);
    return MemberDashboardData(
      deviceCount: _devices
          .where((device) => device.memberId == member.id)
          .length,
      activeRequestCount: requests
          .where(
            (item) =>
                item.record.status == 'Bekliyor' ||
                item.record.status == 'Islemde',
          )
          .length,
      totalRequestCount: requests.length,
      recentRequests: requests.take(6).toList(),
    );
  }

  AdminDashboardData adminDashboard() {
    final views = serviceViews();
    final completedStatuses = {'Tamamlandi', 'Teslim Edildi'};
    final completedRecords = views.where(
      (view) => completedStatuses.contains(view.record.status),
    );

    final totalAmount = _serviceRecords.fold<double>(
      0,
      (sum, record) => sum + record.totalPrice,
    );

    return AdminDashboardData(
      totalMembers: _members.length,
      totalDevices: _devices.length,
      activeServices: _serviceRecords
          .where(
            (record) =>
                record.status == 'Bekliyor' || record.status == 'Islemde',
          )
          .length,
      deliveredServices: _serviceRecords
          .where((record) => record.status == 'Teslim Edildi')
          .length,
      pendingServices: _serviceRecords
          .where((record) => record.status == 'Bekliyor')
          .length,
      inProgressServices: _serviceRecords
          .where((record) => record.status == 'Islemde')
          .length,
      completedRevenue: completedRecords.fold<double>(
        0,
        (sum, view) => sum + view.record.totalPrice,
      ),
      averageServiceAmount: _serviceRecords.isEmpty
          ? 0
          : totalAmount / _serviceRecords.length,
      recentServices: views.take(8).toList(),
      recentMembers: [..._members]
        ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt))
        ..length = _members.length < 5 ? _members.length : 5,
    );
  }

  List<ServiceRecordView> serviceViewsForMember(int memberId) {
    return serviceViews().where((view) => view.member.id == memberId).toList();
  }

  List<ServiceRecordView> serviceViews() {
    final items = <ServiceRecordView>[];

    for (final record in _serviceRecords) {
      final device = _devices.firstWhere((item) => item.id == record.deviceId);
      final member = _members.firstWhere((item) => item.id == device.memberId);
      final recordActions = _actions
          .where((action) => record.actionIds.contains(action.id))
          .toList(growable: false);
      items.add(
        ServiceRecordView(
          record: record,
          device: device,
          member: member,
          actions: recordActions,
        ),
      );
    }

    items.sort((a, b) => b.record.date.compareTo(a.record.date));
    return items;
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<String> _run(Future<String> Function() action) async {
    _isBusy = true;
    notifyListeners();

    try {
      return await action();
    } on _ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Sunucuya baglanirken bir sorun olustu.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<String> _runMessage(Future<String> Function() action) async {
    _isBusy = true;
    notifyListeners();

    try {
      return await action();
    } on _ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Sunucuya baglanirken bir sorun olustu.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.put(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final payload = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw _ApiException(
        (payload['message'] as String?) ?? 'Sunucu istegi basarisiz oldu.',
      );
    }

    return payload;
  }

  Uri _uri(String path) => Uri.parse('$_apiBaseUrl/$path');

  void _applyMemberSync(Map<String, dynamic> data) {
    _activeRole = UserRole.member;
    _activeAdminUsername = null;

    final member = _memberFromJson(data['member'] as Map<String, dynamic>);
    _activeMemberId = member.id;

    _members
      ..clear()
      ..add(member);
    _devices
      ..clear()
      ..addAll(
        (data['devices'] as List<dynamic>).map(
          (item) => _deviceFromJson(item as Map<String, dynamic>),
        ),
      );
    _actions
      ..clear()
      ..addAll(
        (data['actions'] as List<dynamic>).map(
          (item) => _actionFromJson(item as Map<String, dynamic>),
        ),
      );
    _serviceRecords
      ..clear()
      ..addAll(
        (data['services'] as List<dynamic>).map(
          (item) => _serviceRecordFromJson(item as Map<String, dynamic>),
        ),
      );
  }

  void _applyAdminSync(Map<String, dynamic> data) {
    _activeRole = UserRole.admin;
    _activeMemberId = null;
    _activeAdminUsername = data['adminUsername'] as String?;

    _members
      ..clear()
      ..addAll(
        (data['members'] as List<dynamic>).map(
          (item) => _memberFromJson(item as Map<String, dynamic>),
        ),
      );
    _devices
      ..clear()
      ..addAll(
        (data['devices'] as List<dynamic>).map(
          (item) => _deviceFromJson(item as Map<String, dynamic>),
        ),
      );
    _actions
      ..clear()
      ..addAll(
        (data['actions'] as List<dynamic>).map(
          (item) => _actionFromJson(item as Map<String, dynamic>),
        ),
      );
    _serviceRecords
      ..clear()
      ..addAll(
        (data['services'] as List<dynamic>).map(
          (item) => _serviceRecordFromJson(item as Map<String, dynamic>),
        ),
      );
  }

  Member _memberFromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      hasAccount: json['hasAccount'] as bool,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      lastLoginAt: _dateTimeOrNull(json['lastLoginAt']),
      resetCode: json['resetCode'] as String?,
      resetCodeExpiresAt: _dateTimeOrNull(json['resetCodeExpiresAt']),
    );
  }

  Device _deviceFromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      issueDescription: json['issueDescription'] as String,
    );
  }

  ServiceAction _actionFromJson(Map<String, dynamic> json) {
    return ServiceAction(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String? ?? 'Genel',
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  ServiceRecord _serviceRecordFromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      id: json['id'] as int,
      deviceId: json['deviceId'] as int,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      actionIds: (json['actionIds'] as List<dynamic>)
          .map((item) => item as int)
          .toList(growable: false),
      priceApprovalStatus: json['priceApprovalStatus'] as String? ?? '',
      priceApprovalSentAt: _dateTimeOrNull(json['priceApprovalSentAt']),
      priceApprovalAnsweredAt: _dateTimeOrNull(json['priceApprovalAnsweredAt']),
    );
  }

  DateTime? _dateTimeOrNull(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }

  static String _defaultApiBaseUrl() {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (kIsWeb) {
      const apiPort = int.fromEnvironment('API_PORT', defaultValue: 5106);
      const apiScheme = String.fromEnvironment(
        'API_SCHEME',
        defaultValue: 'http',
      );
      final pageUri = Uri.base;

      if (pageUri.hasPort == false ||
          pageUri.port == apiPort ||
          pageUri.port == 7202) {
        return '${pageUri.origin}/api/mobile';
      }

      return Uri(
        scheme: apiScheme,
        host: pageUri.host,
        port: apiPort,
        path: 'api/mobile',
      ).toString();
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5106/api/mobile';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:5106/api/mobile';
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:5106/api/mobile';
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:5106/api/mobile';
    }
  }
}

final class _ApiException implements Exception {
  const _ApiException(this.message);

  final String message;
}
