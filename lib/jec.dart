class JuliaEpochCompact {
  // Tabela Base 35 oficial (Exclui totalmente a letra 'O')
  static const String _base35Alpha = 'ABCDEFGHIJKLMNPQRSTUVWXYZ';

  /// 1. ENCODE: Converte DateTime para String JEC
  static String encode(DateTime dt, {String? alias}) {
    String seculo = 'V'; // Século XXI fixo
    String ano = (dt.year % 100).toString().padLeft(2, '0');
    
    // Mês (A-L)
    String mes = String.fromCharCode(65 + (dt.month - 1));

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
    // Remove o prefixo/alias se ele existir na string
    String corpo = jecId.contains('.') ? jecId.split('.').last : jecId;

    if (corpo.length != 10) {
      throw FormatException('Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.');
    }

    // Divisão cirúrgica das posições (Corrigido)
    String charSeculo = corpo[0];
    int anoDigitos    = int.parse(corpo.substring(1, 3));
    String charMes    = corpo[3];
    String charDia    = corpo[4];
    String charHora   = corpo[5];
    int minuto        = int.parse(corpo.substring(6, 8));
    int segundo       = int.parse(corpo.substring(8, 10));

    // Reconstrução do Ano (Século XXI para 'V')
    int ano = (charSeculo == 'V') ? 2000 + anoDigitos : 1900 + anoDigitos;

    // Reconstrução do Mês
    int mes = charMes.codeUnitAt(0) - 65 + 1;

    // Reconstrução do Dia
    int dia;
    if (RegExp(r'[1-6]').hasMatch(charDia)) {
      dia = int.parse(charDia) + 25;
    } else {
      dia = _base35Alpha.indexOf(charDia) + 1;
    }

    // Reconstrução da Hora
    int hora = _base35Alpha.indexOf(charHora);

    return DateTime(ano, mes, dia, hora, minuto, segundo);
  }
}

/// 3. EXECUÇÃO DOS TESTES DE VALIDAÇÃO
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
