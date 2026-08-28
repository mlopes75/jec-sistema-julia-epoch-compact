/// Classe responsável por implementar a arquitetura do
/// **Sistema Julia** (Julia Epoch Compact - JEC).
/// 
/// O algoritmo gera carimbos temporais (timestamps) compactos,
/// imunes ao Bug do Ano 2038 e otimizados contra ambiguidade visual.
abstract final class SistemaJulia {
  /// Alfabeto de 25 caracteres (Base 35) sem a letra 'O' para
  /// evitar confusão visual com o número zero ('0').
  static const String _letrasSemO = "ABCDEFGHIJKLMNPQRSTUVWXYZ";

  /// Gera um identificador único compacto com base em um [DateTime]
  /// ou no tempo UTC atual.
  /// 
  /// Estrutura (10 caracteres temporais incluindo o ponto padrão):
  /// `[ALIAS].[SÉCULO][ANO][MÊS][DIA][HORA][MINUTOS][SEGUNDOS]`
  static String gerarID({String alias = "", DateTime? dataHora}) {
    final DateTime tempo = (dataHora ?? DateTime.now()).toUtc();

    // 1. Século na Base 35 com Escalabilidade Milenar (ex: 2026 -> 'V')
    final int seculoCompleto = tempo.year ~/ 100;
    String seculoStr;
    
    if (seculoCompleto <= 25) {
      // Século 20 vira índice 19 ('V'). Século 25 vira índice 24 ('Z')
      seculoStr = _letrasSemO[seculoCompleto - 1];
    } else {
      // A partir do Século 26 (Ano 2600), começa de 1 a 9
      final int digitoSeculo = seculoCompleto - 25;
      if (digitoSeculo > 9) {
        throw ArgumentError('Século fora do limite suportado pelo protocolo JEC.');
      }
      seculoStr = digitoSeculo.toString();
    }

    // 2. Ano explícito em 2 dígitos (ex: 2026 -> "26")
    final String anoStr = (tempo.year % 100)
        .toString()
        .padLeft(2, '0');

    // 3. Mês mapeado de 'A' (Jan) a 'L' (Dez) através da tabela oficial
    final String mesStr = _letrasSemO[tempo.month - 1];

    // 4. Dia (1 a 25 usam 'A'-'Z' sem 'O'; 26 a 31 usam '1'-'6')
    final String diaStr = (tempo.day <= 25)
        ? _letrasSemO[tempo.day - 1]
        : (tempo.day - 25).toString();

    // 5. Hora (00h a 23h mapeadas de 'A' a 'Y' sem 'O')
    final String horaStr = _letrasSemO[tempo.hour];

    // 6. Minutos e Segundos (00-59 em 2 dígitos)
    final String minutosStr = tempo.minute
        .toString()
        .padLeft(2, '0');
    final String segundosStr = tempo.second
        .toString()
        .padLeft(2, '0');

    // Construção do prefixo/alias (Garante o ponto inicial caso o alias seja vazio)
    final String prefixo = alias.isNotEmpty ? "$alias." : ".";

    return "$prefixo$seculoStr$anoStr$mesStr$diaStr$horaStr$minutosStr$segundosStr";
  }

  /// Converte um valor Epoch (ms) para o formato Sistema Julia.
  static String deEpoch(int epochMs, {String alias = ""}) {
    final DateTime data = DateTime.fromMillisecondsSinceEpoch(
      epochMs, 
      isUtc: true,
    );
    return gerarID(alias: alias, dataHora: data);
  }
}

void main() {
  // Teste com o ano atual (2026) -> Deve imprimir: .V26...
  print("Atual JEC: ${SistemaJulia.gerarID()}");
  
  // Teste de validação com Alias -> Deve imprimir: TX.V26...
  print("Com Alias: ${SistemaJulia.gerarID(alias: 'TX')}");
}
