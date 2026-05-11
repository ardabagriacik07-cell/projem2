enum UserRole { member, admin }

final class AdminUser {
  const AdminUser({required this.username, required this.password});

  final String username;
  final String password;
}

final class Member {
  const Member({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.hasAccount,
    required this.registeredAt,
    this.lastLoginAt,
    this.resetCode,
    this.resetCodeExpiresAt,
  });

  final int id;
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final bool hasAccount;
  final DateTime registeredAt;
  final DateTime? lastLoginAt;
  final String? resetCode;
  final DateTime? resetCodeExpiresAt;

  Member copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? password,
    bool? hasAccount,
    DateTime? registeredAt,
    DateTime? lastLoginAt,
    String? resetCode,
    DateTime? resetCodeExpiresAt,
    bool clearReset = false,
  }) {
    return Member(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      hasAccount: hasAccount ?? this.hasAccount,
      registeredAt: registeredAt ?? this.registeredAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      resetCode: clearReset ? null : resetCode ?? this.resetCode,
      resetCodeExpiresAt: clearReset
          ? null
          : resetCodeExpiresAt ?? this.resetCodeExpiresAt,
    );
  }
}

final class Device {
  const Device({
    required this.id,
    required this.memberId,
    required this.brand,
    required this.model,
    required this.issueDescription,
  });

  final int id;
  final int memberId;
  final String brand;
  final String model;
  final String issueDescription;

  Device copyWith({
    int? memberId,
    String? brand,
    String? model,
    String? issueDescription,
  }) {
    return Device(
      id: id,
      memberId: memberId ?? this.memberId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      issueDescription: issueDescription ?? this.issueDescription,
    );
  }
}

final class ServiceAction {
  const ServiceAction({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.description,
  });

  final int id;
  final String name;
  final double price;
  final String category;
  final double minPrice;
  final double maxPrice;
  final String description;

  String get displayCategory => category.trim().isEmpty ? 'Genel' : category;

  String get priceRangeLabel {
    if (minPrice <= 0 && maxPrice <= 0) {
      return '${price.toStringAsFixed(0)} TL';
    }

    return '${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)} TL';
  }
}

final class ServiceRecord {
  const ServiceRecord({
    required this.id,
    required this.deviceId,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.actionIds,
    required this.priceApprovalStatus,
    this.priceApprovalSentAt,
    this.priceApprovalAnsweredAt,
  });

  final int id;
  final int deviceId;
  final DateTime date;
  final String status;
  final double totalPrice;
  final List<int> actionIds;
  final String priceApprovalStatus;
  final DateTime? priceApprovalSentAt;
  final DateTime? priceApprovalAnsweredAt;

  ServiceRecord copyWith({
    int? deviceId,
    DateTime? date,
    String? status,
    double? totalPrice,
    List<int>? actionIds,
    String? priceApprovalStatus,
    DateTime? priceApprovalSentAt,
    DateTime? priceApprovalAnsweredAt,
  }) {
    return ServiceRecord(
      id: id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      actionIds: actionIds ?? this.actionIds,
      priceApprovalStatus: priceApprovalStatus ?? this.priceApprovalStatus,
      priceApprovalSentAt: priceApprovalSentAt ?? this.priceApprovalSentAt,
      priceApprovalAnsweredAt:
          priceApprovalAnsweredAt ?? this.priceApprovalAnsweredAt,
    );
  }
}

final class ServiceRecordView {
  const ServiceRecordView({
    required this.record,
    required this.device,
    required this.member,
    required this.actions,
  });

  final ServiceRecord record;
  final Device device;
  final Member member;
  final List<ServiceAction> actions;
}

final class MemberDashboardData {
  const MemberDashboardData({
    required this.deviceCount,
    required this.activeRequestCount,
    required this.totalRequestCount,
    required this.recentRequests,
  });

  final int deviceCount;
  final int activeRequestCount;
  final int totalRequestCount;
  final List<ServiceRecordView> recentRequests;
}

final class AdminDashboardData {
  const AdminDashboardData({
    required this.totalMembers,
    required this.totalDevices,
    required this.activeServices,
    required this.deliveredServices,
    required this.pendingServices,
    required this.inProgressServices,
    required this.completedRevenue,
    required this.averageServiceAmount,
    required this.recentServices,
    required this.recentMembers,
  });

  final int totalMembers;
  final int totalDevices;
  final int activeServices;
  final int deliveredServices;
  final int pendingServices;
  final int inProgressServices;
  final double completedRevenue;
  final double averageServiceAmount;
  final List<ServiceRecordView> recentServices;
  final List<Member> recentMembers;
}
