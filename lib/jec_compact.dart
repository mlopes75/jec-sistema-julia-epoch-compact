class JuliaEpochCompact {
  // Tabela oficial de 35 símbolos.
  // A letra 'O' é excluída para evitar ambiguidade com '0'.
  static const String _base35Alpha =
      'ABCDEFGHIJKLMNPQRSTUVWXYZ';

  static const String _base35Num =
      '1234567890';

  // 1. ENCODE: DateTime -> String JEC
  static String encode(DateTime dt, {String? alias}) {
    // Normalização para UTC.
    dt = dt.toUtc();

    // SÉCULO:
    // 2000-2099 = W
    // 2100-2199 = X
    // 2200-2299 = Y
    // 2300-2399 = Z
    // 2400-2499 = 1
    // ...
    // 3400-3499 = 0
    // 3500-3599 = A
    // ...
    // 5500-5599 = W  <- próximo W
    //
    // O ciclo possui 35 séculos.
    final int seculoCompleto = dt.year ~/ 100;
    final int posicao =
        (seculoCompleto - 20 + 21) % 35;

    final String seculo = posicao < 25
        ? _base35Alpha[posicao]
        : _base35Num[posicao - 25];

    // ANO: últimos dois dígitos.
    final String ano =
        (dt.year % 100).toString().padLeft(2, '0');

    // MÊS: A-L.
    final String mes =
        _base35Alpha[dt.month - 1];

    // DIA:
    // 01-25 = letras
    // 26-31 = 1-6
    final String dia = dt.day <= 25
        ? _base35Alpha[dt.day - 1]
        : (dt.day - 25).toString();

    // HORA: 00-23 = A-Y, sem O.
    final String hora =
        _base35Alpha[dt.hour];

    // MINUTOS: 00-59.
    final String minutos =
        dt.minute.toString().padLeft(2, '0');

    // SEGUNDOS: 00-59.
    final String segundos =
        dt.second.toString().padLeft(2, '0');

    // Prefixo:
    // com alias    -> USR.
    // sem alias    -> .
    final String prefixo =
        (alias != null && alias.isNotEmpty)
            ? '$alias.'
            : '.';

    return '$prefixo'
        '$seculo$ano$mes$dia$hora$minutos$segundos';
  }

  // 2. DECODE: String JEC -> DateTime
  static DateTime decode(String jecId) {
    // Remove o alias, se existir.
    final String corpo =
        jecId.contains('.')
            ? jecId.split('.').last
            : jecId;

    if (corpo.length != 10) {
      throw FormatException(
        'Formato JEC inválido.',
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

    // Reconstrução do século.
    //
    // A posição 21 da tabela é W.
    // O ciclo possui 35 posições.
    final int posicao;

    if (RegExp(r'^[1-9]$').hasMatch(charSeculo)) {
      posicao =
          25 + _base35Num.indexOf(charSeculo);
    } else if (charSeculo == '0') {
      posicao = 34;
    } else {
      posicao =
          _base35Alpha.indexOf(charSeculo);
    }

    if (posicao < 0 || posicao >= 35) {
      throw FormatException(
        'Caractere de século inválido: $charSeculo',
      );
    }

    // Converte a posição do ciclo novamente para o século.
    final int seculoCompleto =
        20 + ((posicao - 21 + 35) % 35);

    final int ano =
        seculoCompleto * 100 + anoDigitos;

    // MÊS.
    final int mes =
        _base35Alpha.indexOf(charMes) + 1;

    if (mes < 1 || mes > 12) {
      throw FormatException(
        'Caractere de mês inválido: $charMes',
      );
    }

    // DIA.
    final int dia;

    if (RegExp(r'^[1-6]$').hasMatch(charDia)) {
      dia = int.parse(charDia) + 25;
    } else {
      dia =
          _base35Alpha.indexOf(charDia) + 1;

      if (dia < 1 || dia > 25) {
        throw FormatException(
          'Caractere de dia inválido: $charDia',
        );
      }
    }

    // HORA.
    final int hora =
        _base35Alpha.indexOf(charHora);

    if (hora < 0 || hora > 23) {
      throw FormatException(
        'Caractere de hora inválido: $charHora',
      );
    }

    return DateTime.utc(
      ano,
      mes,
      dia,
      hora,
      minuto,
      segundo,
    );
  }
}


void main() {
  print('=== TESTES SISTEMA JULIA ===\n');

  // 2026 -> W
  final data1 =
      DateTime.utc(2026, 8, 26, 1, 14, 20);

  final id1 =
      JuliaEpochCompact.encode(
    data1,
    alias: 'USR',
  );

  print('2026: $id1');
  print('Esperado: USR.W26H1B1420');

  // 2100 -> X
  final data2 =
      DateTime.utc(2100, 1, 1);

  final id2 =
      JuliaEpochCompact.encode(data2);

  print('\n2100: $id2');
  print('Esperado: .X00A1A0000');

  // 3500 -> A
  final data3 =
      DateTime.utc(3500, 1, 1);

  final id3 =
      JuliaEpochCompact.encode(data3);

  print('\n3500: $id3');
  print('Esperado: .A00A1A0000');

  // 5500 -> W (próximo W)
  final data4 =
      DateTime.utc(5500, 1, 1);

  final id4 =
      JuliaEpochCompact.encode(data4);

  print('\n5500: $id4');
  print('Esperado: .W00A1A0000');

  // Teste de encode/decode.
  final decodado =
      JuliaEpochCompact.decode(id1);

  print('\nOriginal: $data1');
  print('Decodado: $decodado');
  print(
    'Status: ${data1 == decodado ? "SUCESSO" : "FALHOU"}',
  );
}

  print('-> ID JEC:    $id3');
  print('-> Decodado:  $resultado3');
  print('-> Status:    ${data3 == resultado3 ? "✅ SUCESSO" : "❌ FALHOU"}');
  print('-> ID esperado: .Y00A1A0000\n'); // Y = 2200 ✅
}
