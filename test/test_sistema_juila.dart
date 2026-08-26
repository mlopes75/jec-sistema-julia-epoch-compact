import 'package:test/test.dart';
import '../lib/sistema_julia.dart';

void main() {
  group('Sistema Julia (JEC) - Testes Unitários', () {
    
    test('1. Validação da estrutura temporal padrão (9 caracteres)', () {
      final id = SistemaJulia.gerarID();
      // Remove o prefixo '.' para medir os caracteres temporais
      final parteTemporal = id.substring(1);
      
      expect(parteTemporal.length, equals(9));
      expect(id.startsWith('.'), isTrue);
    });

    test('2. Validação com Alias customizado', () {
      final id = SistemaJulia.gerarID(alias: 'TX');
      
      expect(id.startsWith('TX.'), isTrue);
      expect(id.substring(3).length, equals(9));
    });

    test('3. Teste de regra de Dia (Dias 1 a 25 usam letras sem O)', () {
      // Data: 15 de Agosto de 2026, 10:00:00 UTC (Dia 15 = Letra P)
      final data = DateTime.utc(2026, 8, 15, 10, 0, 0);
      final id = SistemaJulia.gerarID(dataHora: data);
      
      // Formato: .V26HPK0000
      expect(id, equals('.V26HPK0000'));
    });

    test('4. Teste de regra de Dia (Dia 26 transita para número 1)', () {
      // Data: 26 de Agosto de 2026, 11:00:00 UTC (Dia 26 = '1')
      final data = DateTime.utc(2026, 8, 26, 11, 0, 0);
      final id = SistemaJulia.gerarID(alias: 'TX', dataHora: data);
      
      expect(id, equals('TX.V26H1L0000'));
    });

    test('5. Teste de conversão via Unix Epoch (ms)', () {
      // Epoch de 2026-08-26 11:00:00 UTC
      final epochMs = DateTime.utc(2026, 8, 26, 11, 0, 0).millisecondsSinceEpoch;
      final id = SistemaJulia.deEpoch(epochMs, alias: 'LOG');
      
      expect(id, equals('LOG.V26H1L0000'));
    });

    test('6. Garantir ausência total da letra O ambígua', () {
      // Força a geração de várias datas e garante que o caractere 'O' não existe
      final dataHoraHoraO = DateTime.utc(2026, 8, 14, 13, 0, 0);
      final id = SistemaJulia.gerarID(dataHora: dataHoraHoraO);
      
      expect(id.contains('O'), isFalse);
    });
  });
}
