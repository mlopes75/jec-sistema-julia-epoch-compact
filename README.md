# **💎 JEC - Sistema  ( Julia Epoch Compact )**

O **Sistema Julia** é um algoritmo de compactação de marcas temporais (*timestamps*) concebido para gerar identificadores únicos (IDs) extremamente curtos, altamente legíveis e otimizados para sistemas distribuídos, aplicações móveis e contratos inteligentes em Blockchain. O seu nome é uma homenagem de amor à filha do seu criador.

## **🛡️ Princípios de Design e Arquitetura**

1. **Imunidade ao Bug do Ano 2038:** O sistema opera com a extração de componentes de calendário baseados em arquiteturas de 64 bits/EVM nativa, ignorando completamente o estouro de memória de 32 bits do Unix Epoch tradicional.  
2. **Eliminação da Ambiguidade Visual (Sem a letra "O"):** A letra O é totalmente banida da tabela de mapeamento para evitar qualquer confusão com o número zero (0).  
3. **Mapeamento Híbrido Base 35:**  
   * **Meses:** Mapeados de A a L (Jan-Dez).  
   * **Dias:** Mapeados com letras de A a Z (sem o O) para os dias 1 a 25\. A partir do dia 26, transita suavemente para a numeração de 1 a 6.  
   * **Horas:** Mapeadas de A a Y (00h a 23h, saltando o O).  
4. **Escalabilidade Milenar:** Utiliza o índice do século na Base 35 (onde o século XXI é representado por V), garantindo validade funcional sem colisões pelos próximos milénios.  
5. **Prefixo/Alias Configurável:** Suporta a injeção de namespaces ou aliases operacionais antes do carimbo temporal (ex: alias.V26H1B1420 ou .V26H1B1420).

## **📐 Estrutura do Identificador**

O formato estrutural do ID obedece à sequência:

\[PREFIXO/ALIAS\].\[SÉCULO\]\[ANO\]\[MÊS\]\[DIA\]\[HORA\]\[MINUTOS\]\[SEGUNDOS\]

| Bloco | Tamanho | Descrição / Exemplo |
| :---- | :---- | :---- |
| **Alias** | Variável | Prefixo customizado opcional (ex: USR, TX, PEDIDO). |
| **Século** | 1 Caractere | Índice do século na tabela de 25 letras (Século XXI \= V). |
| **Ano** | 2 Dígitos | Últimos dois dígitos do ano corrente (ex: 26 para 2026). |
| **Mês** | 1 Letra | Mapeamento A-L (ex: Agosto \= H). |
| **Dia** | 1 Caractere | A-Z (dias 1-25) e 1-6 (dias 26-31; ex: dia 26 \= 1). |
| **Hora** | 1 Letra | Mapeamento A-Y sem O (ex: 01h \= B). |
| **Minutos** | 2 Dígitos | Padrão 00-59. |
| **Segundos** | 2 Dígitos | Padrão 00-59. |

💻 Implementações Oficiais
🎯 Dart / Flutter

/// Classe responsável por implementar a arquitetura do **Sistema Julia** 
/// (Julia Epoch Compact - JEC).
/// 
/// O algoritmo gera carimbos temporais (timestamps) compactos, imunes ao 
/// Bug do Ano 2038 e otimizados para evitar ambiguidade visual.
abstract final class SistemaJulia {
  /// Alfabeto de 25 caracteres (Base 35) sem a letra 'O' para evitar
  /// confusão visual com o número zero ('0').
  
  static const String _letrasSemO = "ABCDEFGHIJKLMNPQRSTUVWXYZ";

  /// Gera um identificador único compacto com base em um [DateTime] ou no tempo UTC atual.
  /// 
  /// Parâmetros:
  /// - [alias]: Prefixo opcional para categorização ou namespace do ID.
  /// - [dataHora]: Objeto [DateTime] customizado. Se for `null`, utiliza o `DateTime.now().toUtc()`.
  /// 
  /// Formato retornado:
  /// `[ALIAS].[SÉCULO][ANO][MÊS][DIA][HORA][MINUTOS][SEGUNDOS]`
  static String gerarID({String alias = "", DateTime? dataHora}) {
    final DateTime tempo = (dataHora ?? DateTime.now()).toUtc();

    // 1. Século na Base 35 (ex: 2026 ~/ 100 = 20 -> 'V')
    final int indiceSeculo = tempo.year ~/ 100;
    final String seculoStr = _letrasSemO[indiceSeculo];

    // 2. Ano explícito formatado em 2 dígitos (ex: 2026 -> "26")
    final String anoStr = (tempo.year % 100).toString().padLeft(2, '0');

    // 3. Mês mapeado de 'A' (Jan) a 'L' (Dez)
    final String mesStr = _letrasSemO[tempo.month - 1];

    // 4. Dia (Dias 1 a 25 usam letras 'A'-'Z' sem 'O'; dias 26 a 31 usam '1'-'6')
    final String diaStr = (tempo.day <= 25)
        ? _letrasSemO[tempo.day - 1]
        : (tempo.day - 25).toString();

    // 5. Hora do dia (00h a 23h mapeadas de 'A' a 'Y' sem 'O')
    final String horaStr = _letrasSemO[tempo.hour];

    // 6. Minutos e Segundos padronizados em 2 dígitos cada (00-59)
    final String minutosStr = tempo.minute.toString().padLeft(2, '0');
    final String segundosStr = tempo.second.toString().padLeft(2, '0');

    // Construção do prefixo/alias
    final String prefixo = alias.isNotEmpty ? "$alias." : ".";

    return "$prefixo$seculoStr$anoStr$mesStr$diaStr$horaStr$minutosStr$segundosStr";
  }

  /// Converte um valor Epoch (em milissegundos) para o formato Sistema Julia (JEC).
  /// 
  /// Parâmetros:
  /// - [epochMs]: Timestamp Unix em milissegundos (ex: 1776685389000).
  /// - [alias]: Prefixo opcional.
  static String deEpoch(int epochMs, {String alias = ""}) {
    final DateTime data = DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true);
    return gerarID(alias: alias, dataHora: data);
  }
}

void main() {
  // 1. Uso com hora atual UTC
  print("Atual: ${SistemaJulia.gerarID()}");

  // 2. Uso com um Epoch Unix em milissegundos
  int meuEpoch = 1776685389000; 
  print("De Epoch: ${SistemaJulia.deEpoch(meuEpoch, alias: "LOG")}");

  // 3. Uso com um DateTime específico (para testes)
  DateTime dataFixa = DateTime.utc(2026, 8, 26, 11, 0, 0);
  print("Data Fixa: ${SistemaJulia.gerarID(dataHora: dataFixa, alias: "TX")}");
}

