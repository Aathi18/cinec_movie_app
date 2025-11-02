import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Small admin utilities to populate movie metadata like synopses.
/// Use only in development to seed missing fields.
class MovieAdmin {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Map of movieId -> synopsis text. Edit/extend as needed.
  static final Map<String, String> defaultSynopses = {
    'H9RsfxlZK8gdw7hRw2xM': 'Beast is an action-packed thriller starring a lone hero fighting against overwhelming odds to save his family and city.',
    'LEXOYJ6E0ppG67S2PGDn': 'Caribbean follows a high-seas adventure full of humor, romance and swashbuckling action.',
    'SlB0kUnkM1BE4ffBK8In': 'Puli is a historical drama exploring courage, legacy and the battles of a legendary warrior.',
    'aY11GLa6UxAxN1mX0CCh': 'Avengers: An epic superhero spectacle where heroes unite to stop a global threat.',
    'lUHTOcR1vE5yVuDlQn9y': 'Dude is a light-hearted comedy about friendship, mishaps and finding purpose in unexpected places.',
    'mZA6Yhkxe9YlmAn2yLVb': 'Vinnaithandi Varuvaya is a romantic tale of love, longing and cultural barriers between two souls.',
    'qKSGRRe2j9ojn3KQaVW5': 'Leo is an intense character study of a conflicted man forced to confront his past.',
    'uH7NLaeRfJv46ZJou4de': 'Ponniyin Selvan: A grand historical epic woven with politics, betrayal and epic battles.',
  };

  /// Write default synopses to the `movies` collection for any movie id present in the map.
  /// Returns a map of movieId -> success(bool).
  static Future<Map<String, bool>> populateSynopses() async {
    final results = <String, bool>{};

    for (final entry in defaultSynopses.entries) {
      final id = entry.key;
      final synopsis = entry.value;
      try {
        await _db.collection('movies').doc(id).set({'synopsis': synopsis}, SetOptions(merge: true));
        results[id] = true;
        if (kDebugMode) print('Populated synopsis for $id');
      } catch (e) {
        results[id] = false;
        if (kDebugMode) print('Failed to populate synopsis for $id: $e');
      }
    }

    return results;
  }
}
