/// Preferências locais do protótipo. Permanecem disponíveis ao navegar entre
/// telas, mas ainda não são gravadas em armazenamento persistente.
class PreferenciasStore {
  PreferenciasStore._();

  static bool notificacoes = true;
  static bool sincronizarFavoritos = true;
  static bool sugestoes = true;

  static void reset() {
    notificacoes = true;
    sincronizarFavoritos = true;
    sugestoes = true;
  }
}
