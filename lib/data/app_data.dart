import '../models/models.dart';

/// Static, bundled learning plan (no network). All quiz content lives in SQLite.
abstract final class AppData {
  static const userName = 'Studente';

  static List<FastTrackTask> fastTrackTasks() => [
        const FastTrackTask(id: 'd1-1', titleIt: 'Segnali di pericolo essenziali', titleEn: 'Essential danger signs', day: 1, done: true, minutes: 20),
        const FastTrackTask(id: 'd1-2', titleIt: 'Vocabolario: pericolo, curva, dosso', titleEn: 'Vocabulary: danger, curve, bump', day: 1, done: true, minutes: 15),
        const FastTrackTask(id: 'd1-3', titleIt: 'Segnali di precedenza', titleEn: 'Priority signs', day: 1, done: true, minutes: 25),
        const FastTrackTask(id: 'd1-4', titleIt: 'Quiz rapido Giorno 1 (20 Q)', titleEn: 'Day 1 quick quiz (20 Q)', day: 1, done: true, minutes: 15),
        const FastTrackTask(id: 'd2-1', titleIt: 'Limiti di velocità', titleEn: 'Speed limits', day: 2, minutes: 20),
        const FastTrackTask(id: 'd2-2', titleIt: 'Distanza di sicurezza', titleEn: 'Safe following distance', day: 2, minutes: 15),
        const FastTrackTask(id: 'd2-3', titleIt: 'Divieti e obblighi chiave', titleEn: 'Key prohibitions & obligations', day: 2, minutes: 25),
        const FastTrackTask(id: 'd2-4', titleIt: 'Simulazione mini-esame', titleEn: 'Mini exam simulation', day: 2, minutes: 20),
      ];
}
