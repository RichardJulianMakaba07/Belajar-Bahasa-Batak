import 'package:equatable/equatable.dart';

class LearningProgress extends Equatable {
  final int learnedCount;
  final int streakDays;
  final int xp;
  final int level;
  final int correctAnswers;
  final int totalAnswers;
  final int perfectExercises;

  const LearningProgress({
    required this.learnedCount,
    required this.streakDays,
    required this.xp,
    required this.level,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.perfectExercises = 0,
  });

  const LearningProgress.initial()
      : learnedCount = 0,
        streakDays = 0,
        xp = 0,
        level = 1,
        correctAnswers = 0,
        totalAnswers = 0,
        perfectExercises = 0;

  LearningProgress copyWith({
    int? learnedCount,
    int? streakDays,
    int? xp,
    int? level,
    int? correctAnswers,
    int? totalAnswers,
    int? perfectExercises,
  }) {
    return LearningProgress(
      learnedCount: learnedCount ?? this.learnedCount,
      streakDays: streakDays ?? this.streakDays,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      perfectExercises: perfectExercises ?? this.perfectExercises,
    );
  }

  @override
  List<Object?> get props => [
        learnedCount,
        streakDays,
        xp,
        level,
        correctAnswers,
        totalAnswers,
        perfectExercises,
      ];
}
