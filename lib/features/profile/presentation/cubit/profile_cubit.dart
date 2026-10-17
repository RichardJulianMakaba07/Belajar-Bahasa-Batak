import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileState extends Equatable {
  final String name;
  final bool reminder;

  const ProfileState({
    required this.name,
    required this.reminder,
  });

  const ProfileState.initial()
      : name = 'Pengguna',
        reminder = false;

  ProfileState copyWith({
    String? name,
    bool? reminder,
  }) {
    return ProfileState(
      name: name ?? this.name,
      reminder: reminder ?? this.reminder,
    );
  }

  @override
  List<Object?> get props => [name, reminder];
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
