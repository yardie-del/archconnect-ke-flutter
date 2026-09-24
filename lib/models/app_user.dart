import 'architect_tier.dart';

/// Ported from the Kotlin `UserRole` enum. Concept doc's 5 roles collapse
/// into 3 here, same as the Kotlin app: Student/Non-Registered/Registered/
/// Firm are all `architect` with a different [ArchitectTier].
enum UserRole { client, architect, admin }

/// The logged-in user. Ported from the Kotlin `UserEntity` (+ the
/// architect-specific signup fields captured in `AuthScreen`).
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.role,
    this.bio = '',
    this.firmName = '',
    this.tier,
    this.boraqsNumber = '',
    this.services = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final UserRole role;
  final String bio;

  // Architect-only fields
  final String firmName;
  final ArchitectTier? tier;
  final String boraqsNumber;
  final List<String> services;
}