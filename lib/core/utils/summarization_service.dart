class SummarizationService {
  static const Set<String> _stopWords = {
    // English
    'the', 'is', 'in', 'at', 'of', 'on', 'and', 'a', 'an', 'it', 'to', 'for', 'with', 'as', 'by', 'that', 'this',
    'i', 'you', 'he', 'she', 'we', 'they', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had',
    'do', 'does', 'did', 'but', 'or', 'so', 'if', 'because', 'what', 'which', 'who', 'whom', 'whose', 'where',
    'when', 'why', 'how', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no',
    'nor', 'not', 'only', 'own', 'same', 'than', 'too', 'very', 'can', 'will', 'just', 'should', 'now',
    // Turkish
    've', 'ile', 'veya', 'ama', 'fakat', 'lakin', 'ancak', 'çünkü', 'eğer', 'ise', 'ki', 'da', 'de', 'mı', 'mi',
    'mu', 'mü', 'bir', 'bu', 'şu', 'o', 'bunlar', 'şunlar', 'onlar', 'ben', 'sen', 'biz', 'siz', 'için', 'gibi',
    'kadar', 'üzere', 'göre', 'karşı', 'başka', 'daha', 'en', 'çok', 'hiç', 'her', 'bazı', 'tüm', 'bütün', 'hep',
    'var', 'yok', 'olan', 'olarak', 'oldu', 'olduğu', 'olmak', 'ol', 'değil', 'gerek', 'böyle', 'şöyle', 'öyle'
  };

  /// Summarizes the text using an extractive text summarization algorithm (Frequency-based).
  static String summarize(String text, {int sentenceCount = 3}) {
    if (text.trim().isEmpty) return "";

    // 1. Split into sentences
    // Matches sentences ending with . ! ? followed by space or newline
    final sentenceRegex = RegExp(r'[^.!?]+[.!?]*');
    final matches = sentenceRegex.allMatches(text);
    List<String> sentences = matches
        .map((m) => m.group(0)?.trim() ?? '')
        .where((s) => s.isNotEmpty && s.length > 10)
        .toList();

    if (sentences.isEmpty) return text;
    if (sentences.length <= sentenceCount) return text;

    // 2. Tokenize and calculate word frequency
    Map<String, int> wordFrequencies = {};
    final wordRegex = RegExp(r'\w+', unicode: true); // allow unicode characters for turkish

    for (var sentence in sentences) {
      final words = wordRegex.allMatches(sentence.toLowerCase());
      for (var wordMatch in words) {
        final word = wordMatch.group(0);
        if (word != null && word.length > 2 && !_stopWords.contains(word)) {
          wordFrequencies[word] = (wordFrequencies[word] ?? 0) + 1;
        }
      }
    }

    if (wordFrequencies.isEmpty) return text;

    // Normalize frequencies
    int maxFreq = wordFrequencies.values.reduce((a, b) => a > b ? a : b);
    Map<String, double> normalizedFrequencies = {};
    wordFrequencies.forEach((key, value) {
      normalizedFrequencies[key] = value / maxFreq;
    });

    // 3. Score sentences
    Map<String, double> sentenceScores = {};
    for (var sentence in sentences) {
      double score = 0.0;
      final words = wordRegex.allMatches(sentence.toLowerCase());
      for (var wordMatch in words) {
        final word = wordMatch.group(0);
        if (word != null && normalizedFrequencies.containsKey(word)) {
          score += normalizedFrequencies[word]!;
        }
      }
      // Average score based on sentence length to not favor long sentences excessively
      final wordCount = words.length;
      if (wordCount > 0) {
        sentenceScores[sentence] = score / wordCount; 
      } else {
        sentenceScores[sentence] = 0.0;
      }
    }

    // 4. Sort and pick top sentences
    List<MapEntry<String, double>> sortedSentences = sentenceScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending order

    int limit = sortedSentences.length < sentenceCount ? sortedSentences.length : sentenceCount;
    List<String> topSentences = sortedSentences.take(limit).map((e) => e.key).toList();

    // 5. Reorder them as they appeared in the original text
    List<String> finalSummary = [];
    for (var sentence in sentences) {
      if (topSentences.contains(sentence)) {
        finalSummary.add(sentence);
      }
    }

    return finalSummary.join(' ');
  }
}
