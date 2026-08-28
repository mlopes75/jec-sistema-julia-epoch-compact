import 'package:test/test.dart';
import '../lib/sistema_julia.dart';

void main() {
  group('Sistema Julia (JEC) - Testes Unitários', () {
    
    test('1. Validação da estrutura temporal padrão (10 caracteres)', () {
      final id = SistemaJulia.gerarID();
      // Remove o prefixo '.' para medir os caracteres temporais
      final parteTemporal = id.substring(1);
      
      expect(parteTemporal.length, equals(10)); // ← CORRIGIDO: 10
      expect(id.startsWith('.'), isTrue);
    });

    test('2. Validação com Alias customizado', () {
      final id = SistemaJulia.gerarID(alias: 'TX');
      
      expect(id.startsWith('TX.'), isTrue);
      expect(id.substring(3).length, equals(10)); // ← CORRIGIDO: 10
    });

    test('3. Teste de regra de Dia (Dias 1 a 25 usam letras sem O)', () {
      // Data: 15 de Agosto de 2026, 10:00:00 UTC (Dia 15 = Letra P)
      final data = DateTime.utc(2026, 8, 15, 10, 0, 0);
      final id = SistemaJulia.gerarID(dataHora: data);
      
      // CORRIGIDO: W = século XXI (2000-2099)
      // .W26 (2026) + H (Agosto) + P (Dia 15) + K (Hora 10) + 0000
      expect(id, equals('.W26HPK0000')); // ← CORRIGIDO
    });

    test('4. Teste de regra de Dia (Dia 26 transita para número 1)', () {
      // Data: 26 de Agosto de 2026, 11:00:00 UTC (Dia 26 = '1')
      final data = DateTime.utc(2026, 8, 26, 11, 0, 0);
      final id = SistemaJulia.gerarID(alias: 'TX', dataHora: data);
      
      // CORRIGIDO: W26 (2026) + H (Agosto) + 1 (Dia 26) + L (Hora 11) + 0000
      expect(id, equals('TX.W26H1L0000')); 
    });

    test('5. Teste de conversão via Unix Epoch (ms)', () {
      // Epoch de 2026-08-26 11:00:00 UTC
      final epochMs = DateTime.utc(2026, 8, 26, 11, 0, 0).millisecondsSinceEpoch;
      final id = SistemaJulia.deEpoch(epochMs, alias: 'LOG');
      
      expect(id, equals('LOG.W26H1L0000')); // ← CORRIGIDO
    });

    test('6. Garantir ausência total da letra O ambígua', () {
      // Força a geração de várias datas e garante que o caractere 'O' não existe
      final data = DateTime.utc(2026, 8, 14, 13, 0, 0);
      final id = SistemaJulia.gerarID(dataHora: data);
      
      expect(id.contains('O'), isFalse);
    });

    test('7. Teste com diferentes séculos', () {
      // Teste para ano 2100
      final data2100 = DateTime.utc(2100, 1, 1, 0, 0, 0);
      final id2100 = SistemaJulia.gerarID(dataHora: data2100);
      expect(id2100, equals('.X00A1A0000')); // X = século XXII (2100-2199)
      
      // Teste para ano 2200
      final data2200 = DateTime.utc(2200, 1, 1, 0, 0, 0);
      final id2200 = SistemaJulia.gerarID(dataHora: data2200);
      expect(id2200, equals('.Y00A1A0000')); // Y = século XXIII (2200-2299)
    });

    test('8. Teste com todos os dias do mês', () {
      for (int dia = 1; dia <= 31; dia++) {
        final data = DateTime.utc(2026, 8, dia, 0, 0, 0);
        final id = SistemaJulia.gerarID(dataHora: data);
        
        // Verifica que o ID tem 10 caracteres após o ponto
        final parteTemporal = id.contains('.') 
            ? id.split('.').last 
            : id;
        expect(parteTemporal.length, equals(10));
        
        // Verifica que não contém 'O'
        expect(id.contains('O'), isFalse);
      }
    });
  });
}
