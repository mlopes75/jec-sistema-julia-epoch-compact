class JuliaEpochCompact {
  static const String _alpha = 'ABCDEFGHIJKLMNPQRSTUVWXYZ';
  static const String _num = '1234567890';

  static String encode(DateTime dt, {String? alias}) {
    final d = dt.toUtc();
    final year = d.year;
    if (year < 0) throw RangeError('Ano inválido.');
    final century = (year ~/ 100) % 35;
    final String sec = century < 25 ? _alpha[century] : _num[century - 25];
    final String ano = (year % 100).toString().padLeft(2, '0');
    final String mes = _alpha[d.month - 1];
    final String dia = d.day <= 25 ? _alpha[d.day - 1] : (d.day - 25).toString();
    final String hora = _alpha[d.hour];
    final String min = d.minute.toString().padLeft(2, '0');
    final String seg = d.second.toString().padLeft(2, '0');
    final String prefix = (alias != null && alias.isNotEmpty) ? '$alias.' : '.';
    return '$prefix$sec$ano$mes$dia$hora$min$seg';
  }

  static DateTime decode(String jecId) {
    if (jecId.isEmpty) throw FormatException('ID vazio.');
    final parts = jecId.split('.');
    if (parts.length > 2) throw FormatException('Formato inválido.');
    final corpo = parts.last;
    if (corpo.length != 10) throw FormatException('Tamanho incorreto.');

    final charSec = corpo[0];
    final anoDig = int.parse(corpo.substring(1, 3));
    final charMes = corpo[3];
    final charDia = corpo[4];
    final charHora = corpo[5];
    final min = int.parse(corpo.substring(6, 8));
    final seg = int.parse(corpo.substring(8, 10));

    // Decodifica século
    int pos;
    if (charSec == '0') pos = 34;
    else if (charSec.compareTo('1') >= 0 && charSec.compareTo('9') <= 0) {
      final idx = _num.indexOf(charSec);
      if (idx == -1) throw FormatException('Século inválido.');
      pos = 25 + idx;
    } else {
      pos = _alpha.indexOf(charSec);
      if (pos == -1) throw FormatException('Século inválido.');
    }
    final year = pos * 100 + anoDig;

    final month = _alpha.indexOf(charMes) + 1;
    if (month < 1 || month > 12) throw FormatException('Mês inválido.');

    int day;
    if (charDia.compareTo('1') >= 0 && charDia.compareTo('6') <= 0) {
      day = int.parse(charDia) + 25;
    } else {
      final idx = _alpha.indexOf(charDia);
      if (idx < 0 || idx >= 25) throw FormatException('Dia inválido.');
      day = idx + 1;
    }
    if (day < 1 || day > 31) throw FormatException('Dia inválido.');

    final hour = _alpha.indexOf(charHora);
    if (hour < 0 || hour > 23) throw FormatException('Hora inválida.');

    if (min < 0 || min > 59) throw FormatException('Minuto inválido.');
    if (seg < 0 || seg > 59) throw FormatException('Segundo inválido.');

    final result = DateTime.utc(year, month, day, hour, min, seg);
    if (result.year != year || result.month != month || result.day != day ||
        result.hour != hour || result.minute != min || result.second != seg) {
      throw FormatException('Data inválida.');
    }
    return result;
  }
}

// Testes
void main() {
  print('=== SISTEMA JULIA ===\n');
  final testCases = [
    (DateTime.utc(2026, 8, 15, 14, 30, 45), 'TX', 'TX.V26HPP3045'),
    (DateTime.utc(2100, 1, 1, 0, 0, 0), null, '.W00AAA0000'),
    (DateTime.utc(2400, 1, 1, 0, 0, 0), null, '.Z00AAA0000'),
    (DateTime.utc(2500, 1, 1, 0, 0, 0), null, '.100AAA0000'),
    (DateTime.utc(3400, 1, 1, 0, 0, 0), null, '.000AAA0000'),
    (DateTime.utc(3500, 1, 1, 0, 0, 0), null, '.A00AAA0000'),
    (DateTime.utc(0, 1, 1, 0, 0, 0), null, '.A00AAA0000'),
  ];

  for (var i = 0; i < testCases.length; i++) {
    final (dt, alias, expected) = testCases[i];
    final encoded = JuliaEpochCompact.encode(dt, alias: alias);
    final decoded = JuliaEpochCompact.decode(encoded);
    final pass = dt == decoded && encoded == expected;
    print('Teste ${i+1}: ${pass ? "SUCESSO" : "FALHOU"}');
    print('  ID: $encoded');
    print('  Esperado: $expected\n');
  }
}
