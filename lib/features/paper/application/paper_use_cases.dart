import '../domain/models/paper_template.dart';

/// Application operations for changing the paper configuration of a page.
class PaperUseCases {
  const PaperUseCases();

  PaperTemplate updateTemplate(PaperTemplate current, PaperTemplate updated) {
    return updated;
  }
}
