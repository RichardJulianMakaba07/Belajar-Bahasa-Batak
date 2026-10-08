import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileState extends Equatable {
  final String name;
  final bool reminder;
  final int level;
  final int xp;
  final int xpTarget;

  const ProfileState({
    required this.name,
    required this.reminder,
    required this.level,
    required this.xp,
    required this.xpTarget,
  });

  const ProfileState.initial()
      : name = 'Maruli Sihombing',
        reminder = true,
        level = 3,
        xp = 340,
        xpTarget = 500;

  ProfileState copyWith({
    String? name,
    bool? reminder,
    int? level,
    int? xp,
    int? xpTarget,
  }) {
    return ProfileState(
      name: name ?? this.name,
      reminder: reminder ?? this.reminder,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpTarget: xpTarget ?? this.xpTarget,
    );
  }

  @override
  List<Object?> get props => [name, reminder, level, xp, xpTarget];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState.initial());

  void updateName(String name) {
    final value = name.trim();
    if (value.isEmpty) return;
    emit(state.copyWith(name: value));
  }

  void setReminder(bool value) {
    emit(state.copyWith(reminder: value));
  }
}
