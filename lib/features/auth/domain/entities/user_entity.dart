import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? username;
  final String? name;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.username,
    this.name,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, username, name];
}
