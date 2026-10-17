import 'package:equatable/equatable.dart';

class LearningProgress extends Equatable {
  final int learnedCount;
  final int streakDays;
  final int xp;
  final int level;

  const LearningProgress({
    required this.learnedCount,
    required this.streakDays,
    required this.xp,
    required this.level,
  });

  const LearningProgress.initial()
      : learnedCount = 32,
        streakDays = 7,
        xp = 340,
        level = 3;

  LearningProgress copyWith({
    int? learnedCount,
    int? streakDays,
    int? xp,
    int? level,
  }) {
    return LearningProgress(
      learnedCount: learnedCount ?? this.learnedCount,
      streakDays: streakDays ?? this.streakDays,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props => [learnedCount, streakDays, xp, level];
}
