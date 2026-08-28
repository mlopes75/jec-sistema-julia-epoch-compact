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
🎯 Dart / Flutter / Python / JavaScript / Go

🧠 Vantagens da versão em Python:Fatiamento nativo: O uso do operador de slice (corpo[1:3]) do Python torna o tratamento das substrings muito visual e direto.Busca Simples: O método .index() substitui a necessidade de iterar manualmente pelos caracteres para encontrar a posição de mapeamento da hora ou do dia.
🧠 Destaques da versão Go:Fatiamento nativo em tempo constante: Operações como corpo[1:3] extraem os bytes da string de forma imediata e com alocação zero de memória extra, ideal para APIs de altíssima performance.Retorno idiomático de erros: Seguindo as boas práticas do Go, a função Decode retorna a tupla (time.Time, error) de forma explícita, obrigando o desenvolvedor a tratar falhas de conversão de dados.
🧠 Destaques da versão JavaScript:Indexação de meses: Diferente das outras linguagens, o objeto Date do JavaScript inicia a contagem de meses em 0 (Janeiro é 0 e Dezembro é 11). A lógica de conversão foi adaptada sutilmente na linha dt.getMonth() para manter total compatibilidade com o padrão original do repositório.Validação por Regex: O uso da expressão regular /^[1-6]$/.test() valida instantaneamente se o caractere do dia pertence à faixa estendida numérica (dias 26 a 31).


