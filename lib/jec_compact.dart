class JuliaEpochCompact {
  // Tabela oficial:
  // 25 letras + 10 números.
  // A letra "O" é excluída para evitar confusão com "0".
  static const String _base35Alpha =
      'ABCDEFGHIJKLMNPQRSTUVWXYZ';

  static const String _base35Num =
      '1234567890';

  /// ENCODE
  ///
  /// Converte DateTime em identificador Julia.
  ///
  /// Estrutura:
  ///
  /// [ALIAS].[SÉCULO][ANO][MÊS][DIA][HORA][MIN][SEG]
  ///
  /// Exemplos:
  ///
  /// 2000 -> V
  /// 2100 -> W
  /// 2500 -> 1
  /// 3400 -> 0
  /// 3500 -> A
  static String encode(
    DateTime dt, {
    String? alias,
  }) {
    // O Sistema Julia trabalha em UTC.
    final DateTime data = dt.toUtc();

    final int anoCompleto = data.year;

    if (anoCompleto < 0) {
      throw RangeError('Ano inválido.');
    }

    // Século absoluto.
    //
    // 0000 -> A
    // 2000 -> V
    // 2100 -> W
    // 2400 -> Z
    // 2500 -> 1
    // 3400 -> 0
    // 3500 -> A novamente
    //
    // O ciclo possui 35 séculos = 3500 anos.
    final int seculoCompleto =
        anoCompleto ~/ 100;

    final int posicao =
        seculoCompleto % 35;

    final String seculo =
        posicao < 25
            ? _base35Alpha[posicao]
            : _base35Num[posicao - 25];

    // Ano: últimos dois dígitos.
    final String ano =
        (anoCompleto % 100)
            .toString()
            .padLeft(2, '0');

    // Mês: A-L.
    final String mes =
        _base35Alpha[data.month - 1];

    // Dia:
    // 01-25 -> letras
    // 26-31 -> 1-6
    final String dia =
        data.day <= 25
            ? _base35Alpha[data.day - 1]
            : (data.day - 25).toString();

    // Hora:
    // 00-23 -> A-Y, sem O.
    final String hora =
        _base35Alpha[data.hour];

    // Minutos: 00-59.
    final String minutos =
        data.minute.toString().padLeft(2, '0');

    // Segundos: 00-59.
    final String segundos =
        data.second.toString().padLeft(2, '0');

    // Alias:
    //
    // Com alias:
    // USR.V26H1B1420
    //
    // Sem alias:
    // .V26H1B1420
    final String prefixo =
        alias != null && alias.isNotEmpty
            ? '$alias.'
            : '.';

    return '$prefixo'
        '$seculo'
        '$ano'
        '$mes'
        '$dia'
        '$hora'
        '$minutos'
        '$segundos';
  }

  /// DECODE
  ///
  /// Converte identificador Julia em DateTime UTC.
  ///
  /// O século é cíclico a cada 3500 anos.
  /// Portanto, o decode utiliza o primeiro ciclo:
  ///
  /// 0000-3499.
  ///
  /// Exemplo:
  ///
  /// .V26H1B3045
  /// -> 2026-08-15 14:30:45 UTC
  static DateTime decode(String jecId) {
    if (jecId.isEmpty) {
      throw FormatException(
        'ID Julia não pode ser vazio.',
      );
    }

    // Remove o alias, se existir.
    final List<String> partes =
        jecId.split('.');

    if (partes.length > 2) {
      throw FormatException(
        'Formato JEC inválido: máximo de um ponto.',
      );
    }

    final String corpo =
        partes.last;

    if (corpo.length != 10) {
      throw FormatException(
        'O bloco temporal deve possuir exatamente 10 caracteres.',
      );
    }

    final String charSeculo = corpo[0];

    final int anoDigitos =
        int.parse(corpo.substring(1, 3));

    final String charMes = corpo[3];
    final String charDia = corpo[4];
    final String charHora = corpo[5];

    final int minuto =
        int.parse(corpo.substring(6, 8));

    final int segundo =
        int.parse(corpo.substring(8, 10));

    // ============================================================
    // SÉCULO
    // ============================================================

    int posicao;

    if (RegExp(r'^[1-9]$')
        .hasMatch(charSeculo)) {
      final int indice =
          _base35Num.indexOf(charSeculo);

      if (indice == -1) {
        throw FormatException(
          'Caractere de século inválido: $charSeculo',
        );
      }

      posicao = 25 + indice;
    } else if (charSeculo == '0') {
      // 0 = posição 34.
      posicao = 34;
    } else {
      // A-Z sem O.
      posicao =
          _base35Alpha.indexOf(charSeculo);

      if (posicao == -1) {
        throw FormatException(
          'Caractere de século inválido: $charSeculo',
        );
      }
    }

    // Primeiro ciclo:
    //
    // A = século 0
    // ...
    // V = século 20
    // W = século 21
    // ...
    // Z = século 24
    // 1 = século 25
    // ...
    // 0 = século 34
    final int seculoCompleto =
        posicao;

    final int ano =
        seculoCompleto * 100 + anoDigitos;

    // ============================================================
    // MÊS
    // ============================================================

    final int mes =
        _base35Alpha.indexOf(charMes) + 1;

    if (mes < 1 || mes > 12) {
      throw FormatException(
        'Caractere de mês inválido: $charMes',
      );
    }

    // ============================================================
    // DIA
    // ============================================================

    final int dia;

    if (RegExp(r'^[1-6]$')
        .hasMatch(charDia)) {
      dia =
          int.parse(charDia) + 25;
    } else {
      final int indice =
          _base35Alpha.indexOf(charDia);

      if (indice < 0 || indice >= 25) {
        throw FormatException(
          'Caractere de dia inválido: $charDia',
        );
      }

      dia = indice + 1;
    }

    if (dia < 1 || dia > 31) {
      throw FormatException(
        'Dia inválido: $dia',
      );
    }

    // ============================================================
    // HORA
    // ============================================================

    final int hora =
        _base35Alpha.indexOf(charHora);

    if (hora < 0 || hora > 23) {
      throw FormatException(
        'Caractere de hora inválido: $charHora',
      );
    }

    // ============================================================
    // MINUTOS E SEGUNDOS
    // ============================================================

    if (minuto < 0 || minuto > 59) {
      throw FormatException(
        'Minuto inválido: $minuto',
      );
    }

    if (segundo < 0 || segundo > 59) {
      throw FormatException(
        'Segundo inválido: $segundo',
      );
    }

    // ============================================================
    // DATA FINAL EM UTC
    // ============================================================

    final DateTime resultado =
        DateTime.utc(
      ano,
      mes,
      dia,
      hora,
      minuto,
      segundo,
    );

    // Validação contra datas inexistentes,
    // como 31/02.
    if (resultado.year != ano ||
        resultado.month != mes ||
        resultado.day != dia ||
        resultado.hour != hora ||
        resultado.minute != minuto ||
        resultado.second != segundo) {
      throw FormatException(
        'Data/hora inválida.',
      );
    }

    return resultado;
  }
}


// ================================================================
// TESTES
// ================================================================

void main() {
  print('=== SISTEMA JULIA ===\n');

  // --------------------------------------------------------------
  // 2026 -> V
  // --------------------------------------------------------------

  final DateTime data1 =
      DateTime.utc(
    2026,
    8,
    15,
    14,
    30,
    45,
  );

  final String id1 =
      JuliaEpochCompact.encode(
    data1,
    alias: 'TX',
  );

  final DateTime resultado1 =
      JuliaEpochCompact.decode(id1);

  print('Teste 1 - 2026');
  print('Original: $data1');
  print('ID:       $id1');
  print('Decodado: $resultado1');
  print(
    'Status:   '
    '${data1 == resultado1 ? "SUCESSO" : "FALHOU"}',
  );
  print('Esperado: TX.V26H1B3045\n');


  // --------------------------------------------------------------
  // 2100 -> W
  // --------------------------------------------------------------

  final DateTime data2 =
      DateTime.utc(
    2100,
    1,
    1,
    0,
    0,
    0,
  );

  final String id2 =
      JuliaEpochCompact.encode(data2);

  print('Teste 2 - 2100');
  print('ID:       $id2');
  print('Esperado: .W00A1A0000\n');


  // --------------------------------------------------------------
  // 2400 -> Z
  // --------------------------------------------------------------

  final DateTime data3 =
      DateTime.utc(
    2400,
    1,
    1,
    0,
    0,
    0,
  );

  final String id3 =
      JuliaEpochCompact.encode(data3);

  print('Teste 3 - 2400');
  print('ID:       $id3');
  print('Esperado: .Z00A1A0000\n');


  // --------------------------------------------------------------
  // 2500 -> 1
  // --------------------------------------------------------------

  final DateTime data4 =
      DateTime.utc(
    2500,
    1,
    1,
    0,
    0,
    0,
  );

  final String id4 =
      JuliaEpochCompact.encode(data4);

  print('Teste 4 - 2500');
  print('ID:       $id4');
  print('Esperado: .100A1A0000\n');


  // --------------------------------------------------------------
  // 3400 -> 0
  // --------------------------------------------------------------

  final DateTime data5 =
      DateTime.utc(
    3400,
    1,
    1,
    0,
    0,
    0,
  );

  final String id5 =
      JuliaEpochCompact.encode(data5);

  print('Teste 5 - 3400');
  print('ID:       $id5');
  print('Esperado: .000A1A0000\n');


  // --------------------------------------------------------------
  // 3500 -> A
  // --------------------------------------------------------------

  final DateTime data6 =
      DateTime.utc(
    3500,
    1,
    1,
    0,
    0,
    0,
  );

  final String id6 =
      JuliaEpochCompact.encode(data6);

  print('Teste 6 - 3500');
  print('ID:       $id6');
  print('Esperado: .A00A1A0000\n');
}
