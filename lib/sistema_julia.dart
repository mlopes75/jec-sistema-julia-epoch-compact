/// SISTEMA JULIA
/// ============================================================================
///
/// Algoritmo de compactação de marcas temporais (timestamps) concebido para
/// gerar identificadores extremamente curtos, legíveis e determinísticos.
///
/// O nome "Julia" é uma homenagem de amor à filha do criador.
///
/// OBJETIVOS
/// ---------
///
/// - Timestamps compactos e legíveis para checkpoints NRS.
/// - Identificadores de sites e transações sem ambiguidade visual.
/// - Auditoria distribuída com IDs humano-legíveis.
/// - Independência do limite clássico do Unix Epoch de 32 bits (Y2038).
/// - Representação temporal compacta e determinística.
/// - Funcionamento em ciclos de 3.500 anos para a codificação do século.
///
/// IMPORTANTE
/// ----------
///
/// O Sistema Julia é EXCLUSIVAMENTE um gerador de identificadores.
///
/// Sua responsabilidade termina em:
///
///     DateTime + Alias
///            ↓
///     USR.W26H1B1420
///
/// O algoritmo NÃO:
///
/// - consulta banco de dados;
/// - verifica se um ID já existe;
/// - rejeita IDs duplicados;
/// - controla concorrência;
/// - adiciona contador;
/// - adiciona nonce;
/// - adiciona milissegundos ao identificador;
/// - controla persistência.
///
/// A unicidade ou rejeição de duplicatas é responsabilidade exclusiva do
/// sistema que consumir o identificador.
///
/// ============================================================================
/// TABELA OFICIAL DE 35 SÍMBOLOS
/// ============================================================================
///
/// O Sistema Julia utiliza uma tabela híbrida composta por 35 símbolos.
///
/// POSIÇÕES 01-25 — ALFABETO
///
///     A B C D E F G H I J K L M N P Q R S T U V W X Y Z
///
/// A letra "O" é deliberadamente excluída para eliminar a ambiguidade visual
/// entre a letra O e o número 0.
///
/// POSIÇÕES 26-35 — NÚMEROS
///
///     1 2 3 4 5 6 7 8 9 0
///
/// ============================================================================
/// ESTRUTURA DO IDENTIFICADOR
/// ============================================================================
///
///     [ALIAS].[SÉCULO][ANO][MÊS][DIA][HORA][MINUTO][SEGUNDO]
///
/// O alias é opcional.
///
/// COM ALIAS:
///
///     USR.W26H1B1420
///
/// SEM ALIAS:
///
///     .W26H1B1420
///
/// ---------------------------------------------------------------------------
///
/// Para:
///
///     26/08/2026 01:14:20 UTC
///
/// temos:
///
///     Século  = W
///     Ano     = 26
///     Mês     = H
///     Dia     = 1
///     Hora    = B
///     Minuto  = 14
///     Segundo = 20
///
/// Resultado:
///
///     USR.W26H1B1420
///
/// ============================================================================
/// MAPEAMENTO DO SÉCULO
/// ============================================================================
///
/// A representação do século utiliza os 35 símbolos da tabela em ciclo.
///
/// O ciclo oficial começa no século XXI.
///
///     2000-2099 = W
///     2100-2199 = X
///     2200-2299 = Y
///     2300-2399 = Z
///     2400-2499 = 1
///     2500-2599 = 2
///     2600-2699 = 3
///     2700-2799 = 4
///     2800-2899 = 5
///     2900-2999 = 6
///     3000-3099 = 7
///     3100-3199 = 8
///     3200-3299 = 9
///     3300-3399 = 0
///     3400-3499 = A
///
/// ATENÇÃO:
///
/// A sequência acima demonstra a rotação dos símbolos a partir de W.
/// Para preservar exatamente a tabela de 35 posições e fazer o próximo W
/// ocorrer 3.500 anos depois, o cálculo é feito matematicamente através
/// de um ciclo de 35 posições.
///
/// O primeiro W ocorre em:
///
///     2000-2099
///
/// O próximo W ocorre em:
///
///     5500-5599
///
/// E o ciclo continua:
///
///     5500-5599 = W
///     5600-5699 = X
///     5700-5799 = Y
///     ...
///
/// Portanto:
///
///     2000 → W
///     5500 → W
///     9000 → W
///     12500 → W
///
/// O período do ciclo é de 3.500 anos.
///
/// ============================================================================
/// ANO
/// ============================================================================
///
/// O ano utiliza somente os dois últimos dígitos.
///
/// Exemplos:
///
///     2026 → 26
///     2099 → 99
///     2100 → 00
///     5500 → 00
///     5599 → 99
///
/// ============================================================================
/// MÊS
/// ============================================================================
///
/// Os meses utilizam as letras A-L.
///
///     Janeiro   → A
///     Fevereiro → B
///     Março     → C
///     Abril     → D
///     Maio      → E
///     Junho     → F
///     Julho     → G
///     Agosto    → H
///     Setembro  → I
///     Outubro   → J
///     Novembro  → K
///     Dezembro  → L
///
/// ============================================================================
/// DIA
/// ============================================================================
///
/// Os dias 01-25 utilizam a tabela alfabética.
///
///     01 → A
///     02 → B
///     03 → C
///     ...
///     14 → N
///     15 → P
///     ...
///     25 → Z
///
/// A letra O não existe na tabela.
///
/// Os dias 26-31 utilizam os números 1-6.
///
///     26 → 1
///     27 → 2
///     28 → 3
///     29 → 4
///     30 → 5
///     31 → 6
///
/// ============================================================================
/// HORA
/// ============================================================================
///
/// As horas 00-23 utilizam os primeiros 24 caracteres da tabela alfabética.
///
///     00 → A
///     01 → B
///     02 → C
///     ...
///     13 → N
///     14 → P
///     ...
///     23 → Y
///
/// ============================================================================
/// MINUTO
/// ============================================================================
///
/// Minutos são representados por dois dígitos.
///
///     00-59
///
/// ============================================================================
/// SEGUNDO
/// ============================================================================
///
/// Segundos são representados por dois dígitos.
///
///     00-59
///
/// ============================================================================
/// UTC
/// ============================================================================
///
/// O Sistema Julia converte o DateTime recebido para UTC antes da codificação.
///
/// Isso garante que o mesmo instante absoluto seja representado da mesma
/// maneira independentemente do fuso horário da aplicação.
///
/// ============================================================================
/// Y2038
/// ============================================================================
///
/// O algoritmo não utiliza um timestamp Unix de 32 bits para decompor a
/// data.
///
/// Os componentes temporais são obtidos diretamente através de DateTime.
///
/// A função deEpoch() aceita Epoch em milissegundos e o converte para DateTime
/// UTC antes da geração do identificador.
///
/// ============================================================================

abstract final class SistemaJulia {
  // ==========================================================================
  // TABELAS OFICIAIS
  // ==========================================================================

  /// 25 letras do Sistema Julia.
  ///
  /// A letra O é excluída propositalmente.
  static const String _alfabeto =
      "ABCDEFGHIJKLMNPQRSTUVWXYZ";

  /// 10 números utilizados nas posições 26-35.
  ///
  /// A ordem é parte da especificação.
  static const String _numerosSiculo =
      "1234567890";

  /// Quantidade total de símbolos utilizados na codificação do século.
  static const int _tamanhoCiclo = 35;

  /// Índice do século XXI:
  ///
  ///     2000 ~/ 100 = 20
  ///
  /// O século 20 é utilizado como origem matemática para que:
  ///
  ///     2000 → W
  static const int _primeiroSeculo = 20;

  // ==========================================================================
  // GERAÇÃO DO ID
  // ==========================================================================

  /// Gera um identificador Sistema Julia.
  ///
  /// PARÂMETROS
  /// ----------
  ///
  /// [alias]
  ///     Namespace ou identificador operacional opcional.
  ///
  /// [dataHora]
  ///     Data/hora utilizada para gerar o ID.
  ///
  ///     Se não for informada, DateTime.now() será utilizado.
  ///
  /// O valor recebido é convertido para UTC.
  ///
  /// RETORNO
  /// -------
  ///
  /// Retorna o identificador no formato:
  ///
  ///     [ALIAS].[SÉCULO][ANO][MÊS][DIA][HORA][MIN][SEG]
  ///
  /// Exemplo:
  ///
  ///     USR.W26H1B1420
  ///
  /// para:
  ///
  ///     2026-08-26 01:14:20 UTC
  static String gerarID({
    String alias = "",
    DateTime? dataHora,
  }) {
    // ------------------------------------------------------------------------
    // CONVERSÃO PARA UTC
    // ------------------------------------------------------------------------
    //
    // A normalização para UTC garante uma representação temporal consistente.
    //
    final DateTime tempo =
        (dataHora ?? DateTime.now()).toUtc();

    // ------------------------------------------------------------------------
    // 1. SÉCULO
    // ------------------------------------------------------------------------
    //
    // O cálculo transforma o século calendário em uma posição dentro do
    // ciclo de 35 símbolos.
    //
    // Século XXI:
    //
    //     2000 ~/ 100 = 20
    //
    // Como _primeiroSeculo = 20:
    //
    //     (20 - 20) = 0
    //
    // A posição 0 da tabela utilizada pelo ciclo corresponde a W no nosso
    // ponto inicial.
    //
    // O operador % 35 faz o ciclo retornar ao início após 35 séculos.
    //
    // Dessa maneira:
    //
    //     2000 → W
    //     ...
    //     5500 → W
    //
    final int seculoPosicao =
        ((tempo.year ~/ 100) - _primeiroSeculo) %
        _tamanhoCiclo;

    // ------------------------------------------------------------------------
    // Conversão da posição para o símbolo correspondente.
    // ------------------------------------------------------------------------
    //
    // Posições 0-24  → letras
    // Posições 25-34 → números
    //
    final String seculoStr =
        seculoPosicao < 25
            ? _alfabeto[seculoPosicao]
            : _numerosSiculo[seculoPosicao - 25];

    // ------------------------------------------------------------------------
    // 2. ANO
    // ------------------------------------------------------------------------
    //
    // Apenas os dois últimos dígitos do ano são utilizados.
    //
    // 2026 → 26
    // 2100 → 00
    //
    final String anoStr =
        (tempo.year % 100)
            .toString()
            .padLeft(2, '0');

    // ------------------------------------------------------------------------
    // 3. MÊS
    // ------------------------------------------------------------------------
    //
    // DateTime.month:
    //
    //     Janeiro = 1
    //     Dezembro = 12
    //
    // A tabela String começa no índice 0, portanto subtraímos 1.
    //
    //     Janeiro → A
    //     Agosto  → H
    //
    final String mesStr =
        _alfabeto[tempo.month - 1];

    // ------------------------------------------------------------------------
    // 4. DIA
    // ------------------------------------------------------------------------
    //
    // Dias 01-25:
    //
    //     utilizam o alfabeto.
    //
    // Dias 26-31:
    //
    //     utilizam os números 1-6.
    //
    final String diaStr =
        tempo.day <= 25
            ? _alfabeto[tempo.day - 1]
            : (tempo.day - 25).toString();

    // ------------------------------------------------------------------------
    // 5. HORA
    // ------------------------------------------------------------------------
    //
    // As horas 00-23 correspondem diretamente aos índices 0-23 do alfabeto.
    //
    // Como a letra O foi removida:
    //
    //     13 → N
    //     14 → P
    //
    final String horaStr =
        _alfabeto[tempo.hour];

    // ------------------------------------------------------------------------
    // 6. MINUTO
    // ------------------------------------------------------------------------
    //
    // Sempre dois caracteres.
    //
    //     0  → 00
    //     9  → 09
    //     14 → 14
    //     59 → 59
    //
    final String minutosStr =
        tempo.minute
            .toString()
            .padLeft(2, '0');

    // ------------------------------------------------------------------------
    // 7. SEGUNDO
    // ------------------------------------------------------------------------
    //
    // Sempre dois caracteres.
    //
    //     0  → 00
    //     9  → 09
    //     59 → 59
    //
    final String segundosStr =
        tempo.second
            .toString()
            .padLeft(2, '0');

    // ------------------------------------------------------------------------
    // 8. ALIAS / PREFIXO
    // ------------------------------------------------------------------------
    //
    // Com alias:
    //
    //     USR.W26H1B1420
    //
    // Sem alias:
    //
    //     .W26H1B1420
    //
    final String prefixo =
        alias.isNotEmpty
            ? "$alias."
            : ".";

    // ------------------------------------------------------------------------
    // 9. CONSTRUÇÃO FINAL
    // ------------------------------------------------------------------------
    //
    // Estrutura:
    //
    //     PREFIXO
    //     +
    //     SÉCULO
    //     +
    //     ANO
    //     +
    //     MÊS
    //     +
    //     DIA
    //     +
    //     HORA
    //     +
    //     MINUTO
    //     +
    //     SEGUNDO
    //
    return "$prefixo"
        "$seculoStr"
        "$anoStr"
        "$mesStr"
        "$diaStr"
        "$horaStr"
        "$minutosStr"
        "$segundosStr";
  }

  // ==========================================================================
  // EPOCH
  // ==========================================================================

  /// Converte Epoch em milissegundos para um identificador Sistema Julia.
  ///
  /// O valor Epoch é interpretado como UTC.
  ///
  /// Exemplo:
  ///
  ///     SistemaJulia.deEpoch(
  ///       epochMs,
  ///       alias: "USR",
  ///     );
  ///
  /// equivale a gerar o ID diretamente para o mesmo instante UTC.
  static String deEpoch(
    int epochMs, {
    String alias = "",
  }) {
    final DateTime data =
        DateTime.fromMillisecondsSinceEpoch(
      epochMs,
      isUtc: true,
    );

    return gerarID(
      alias: alias,
      dataHora: data,
    );
  }
}


// ============================================================================
// EXEMPLOS DE UTILIZAÇÃO
// ============================================================================

void main() {
  // ==========================================================================
  // EXEMPLO 1 — DATA ESPECÍFICA
  // ==========================================================================

  final DateTime testeData =
      DateTime.utc(
    2026,
    8,
    26,
    1,
    14,
    20,
  );

  final String idTeste =
      SistemaJulia.gerarID(
    alias: "USR",
    dataHora: testeData,
  );

  print("Teste: $idTeste");

  // Resultado esperado:
  //
  //     USR.W26H1B1420


  // ==========================================================================
  // EXEMPLO 2 — SEM ALIAS
  // ==========================================================================

  final String idSemAlias =
      SistemaJulia.gerarID(
    dataHora: testeData,
  );

  print("Sem alias: $idSemAlias");

  // Resultado:
  //
  //     .W26H1B1420


  // ==========================================================================
  // EXEMPLO 3 — DATA/HORA ATUAL
  // ==========================================================================

  final String idAtual =
      SistemaJulia.gerarID(
    alias: "USR",
  );

  print("Atual: $idAtual");


  // ==========================================================================
  // EXEMPLO 4 — EPOCH
  // ==========================================================================

  final int epochMs =
      testeData.millisecondsSinceEpoch;

  final String idEpoch =
      SistemaJulia.deEpoch(
    epochMs,
    alias: "USR",
  );

  print("Epoch: $idEpoch");

  // Deve produzir o mesmo ID do Exemplo 1:
  //
  //     USR.W26H1B1420


  // ==========================================================================
  // EXEMPLO 5 — CICLO DO SÉCULO
  // ==========================================================================

  final String ano2000 =
      SistemaJulia.gerarID(
    dataHora: DateTime.utc(2000, 1, 1),
  );

  final String ano5500 =
      SistemaJulia.gerarID(
    dataHora: DateTime.utc(5500, 1, 1),
  );

  print("2000: $ano2000");
  print("5500: $ano5500");

  // O símbolo do século retorna ao mesmo ponto do ciclo:
  //
  //     2000 → W
  //     5500 → W
}


void main() {
  // Execução do teste -> Retorna exatamente: .V26...
  print("Atual: ${SistemaJulia.gerarID()}");
}
