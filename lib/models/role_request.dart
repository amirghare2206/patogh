import 'package:patogh/models/user_role.dart';

class RoleRequest {
  final String id;
  final String applicantName;
  final UserRole requestedRole;
  final String note;
  final String status;

  const RoleRequest({
    required this.id,
    required this.applicantName,
    required this.requestedRole,
    required this.note,
    this.status = 'pending',
  });

  RoleRequest copyWith({String? status}) {
    return RoleRequest(
      id: id,
      applicantName: applicantName,
      requestedRole: requestedRole,
      note: note,
      status: status ?? this.status,
    );
  }
}
