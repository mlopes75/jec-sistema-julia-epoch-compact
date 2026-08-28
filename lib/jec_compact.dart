class JuliaEpochCompact {
  // Tabela Base 35 oficial (Exclui totalmente a letra 'O')
  static const String _base35Alpha = 'ABCDEFGHIJKLMNPQRSTUVWXYZ';

  /// 1. ENCODE: Converte DateTime para String JEC
  static String encode(DateTime dt, {String? alias}) {
    int seculoCompleto = dt.year ~/ 100;
    String seculo;

    // Lógica milenar idêntica ao Solidity, JS e Go
    if (seculoCompleto <= 25) {
      seculo = _base35Alpha[seculoCompleto - 1];
    } else {
      int digitoSeculo = seculoCompleto - 25;
      if (digitoSeculo > 9) {
        throw ArgumentError('Século fora do limite suportado.');
      }
      seculo = digitoSeculo.toString();
    }

    String ano = (dt.year % 100).toString().padLeft(2, '0');
    
    // Mês mapeado estritamente através da tabela oficial
    String mes = _base35Alpha[dt.month - 1];

    // Dia (A-Z sem O para 1-25; 1-6 para 26-31)
    String dia;
    if (dt.day <= 25) {
      dia = _base35Alpha[dt.day - 1];
    } else {
      dia = (dt.day - 25).toString();
    }

    // Hora (A-Y sem O para 00h-23h)
    String hora = _base35Alpha[dt.hour];

    String minutos = dt.minute.toString().padLeft(2, '0');
    String segundos = dt.second.toString().padLeft(2, '0');

    String prefixo = (alias != null && alias.isNotEmpty) ? '$alias.' : '';
    
    return '$prefixo$seculo$ano$mes$dia$hora$minutos$segundos';
  }

  /// 2. DECODE: Converte String JEC de volta para DateTime
  static DateTime decode(String jecId) {
    String corpo = jecId.contains('.') ? jecId.split('.').last : jecId;

    if (corpo.length != 10) {
      throw FormatException('Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.');
    }

    String charSeculo = corpo[0];
    int anoDigitos    = int.parse(corpo.substring(1, 3));
    String charMes    = corpo[3];
    String charDia    = corpo[4];
    String charHora   = corpo[5];
    int minuto        = int.parse(corpo.substring(6, 8));
    int segundo       = int.parse(corpo.substring(8, 10));

    // Reconstrução Dinâmica do Século
    int seculoCompleto;
    if (RegExp(r'^[1-9]$').hasMatch(charSeculo)) {
      seculoCompleto = int.parse(charSeculo) + 25;
    } else {
      int idxSeculo = _base35Alpha.indexOf(charSeculo);
      if (idxSeculo == -1) {
        throw FormatException('Caractere de século inválido: $charSeculo');
      }
      seculoCompleto = idxSeculo + 1;
    }
    int ano = (seculoCompleto * 100) + anoDigitos;

    // Reconstrução do Mês usando a tabela oficial
    int mes = _base35Alpha.indexOf(charMes) + 1;
    if (mes == 0) {
      throw FormatException('Caractere de mês inválido: $charMes');
    }

    // Reconstrução do Dia
    int dia;
    if (RegExp(r'^[1-6]$').hasMatch(charDia)) {
      dia = int.parse(charDia) + 25;
    } else {
      dia = _base35Alpha.indexOf(charDia) + 1;
    }

    // Reconstrução da Hora
    int hora = _base35Alpha.indexOf(charHora);

    return DateTime(ano, mes, dia, hora, minuto, segundo);
  }
}

void main() {
  print('=== INICIANDO TESTES DO SISTEMA JEC COMPACT ===\n');

  // Caso 1: Teste com Dia menor ou igual a 25
  DateTime data1 = DateTime(2026, 8, 15, 14, 30, 45);
  String id1 = JuliaEpochCompact.encode(data1, alias: 'TX');
  DateTime resultado1 = JuliaEpochCompact.decode(id1);
  
  print('Teste 1 (Dia Regular - 15/08):');
  print('-> Original:  $data1');
  print('-> ID JEC:    $id1');
  print('-> Decodado:  $resultado1');
  print('-> Status:    ${data1 == resultado1 ? "✅ SUCESSO" : "❌ FALHOU"}\n');

  // Caso 2: Teste com Dia limite (Maior que 25)
  DateTime data2 = DateTime(2026, 12, 28, 23, 59, 00);
  String id2 = JuliaEpochCompact.encode(data2);
  DateTime resultado2 = JuliaEpochCompact.decode(id2);

  print('Teste 2 (Dia Limite - 28/12):');
  print('-> Original:  $data2');
  print('-> ID JEC:    $id2');
  print('-> Decodado:  $resultado2');
  print('-> Status:    ${data2 == resultado2 ? "✅ SUCESSO" : "❌ FALHOU"}\n');
}
