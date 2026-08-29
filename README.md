# **💎 JEC - Sistema  ( Julia Epoch Compact )**

O **Sistema Julia** é exclusivamente um algoritmo determinístico de compactação e codificação temporal, concebido para gerar identificadores temporais extremamente curtos, legíveis e sem ambiguidade visual, a partir de um instante temporal e de um alias opcional, destinados à identificação de eventos, registros, checkpoints, sites, aplicações móveis e contratos inteligentes em Blockchain e transações; sua responsabilidade termina na geração desse identificador, enquanto questões de persistência, indexação, unicidade, rejeição de duplicatas e controle de concorrência pertencem exclusivamente à camada consumidora.

O seu nome é uma homenagem de amor à filha do seu criador.

Tem por objetivos :
- Timestamps compactos e legíveis para checkpoints NRS
- Identificadores de sites/transações sem ambiguidade visual
- Auditoria distribuída com IDs humano-legíveis 
- Imunidade a Y2038 e escalável por milênio

## **🛡️ Princípios de Design e Arquitetura**

1. **Imunidade ao Bug do Ano 2038:** O sistema opera com a extração de componentes de calendário baseados em arquiteturas de 64 bits/EVM nativa, ignorando completamente o estouro de memória de 32 bits do Unix Epoch tradicional.  
2. **Eliminação da Ambiguidade Visual (Sem a letra "O"):** A letra O é totalmente banida da tabela de mapeamento para evitar qualquer confusão com o número zero (0).  
3. **Mapeamento Híbrido 25 Alfabético + 10 Numérico, extremamente funcional e lógico.:**  
   * **Meses:** Mapeados de A a L (Jan-Dez).  
   * **Dias:** Mapeados com letras de A a Z (sem o O) para os dias 1 a 25\. A partir do dia 26, transita suavemente para a numeração de 1 a 6.  
   * **Horas:** Mapeadas de A a Y (00h a 23h, saltando o O).  
4. **Escalabilidade Milenar:** Escalabilidade Milenar: Utiliza tabela de 35 símbolos para representação de séculos sem colisões funcionais:
- ALFABÉTICO (25 caracteres, Posição 1-25): A B C D E F G H I J K L M N P Q R S T U V W X Y Z
- NUMÉRICO (10 dígitos, ordem especial, Posição 26-35): 1 2 3 4 5 6 7 8 9 0

Onde o século XXI é representado por V, garantindo validade funcional pelos próximos milénios (até Século 35 = ano 3499) sem colisões.  
5. **Prefixo/Alias Configurável:** Suporta a injeção de namespaces ou aliases operacionais antes do carimbo temporal (ex: alias.V26H1B1420 ou .V26H1B1420).

## **📐 Estrutura do Identificador**

O formato estrutural do ID obedece à sequência:

\[PREFIXO/ALIAS\].\[SÉCULO\]\[ANO\]\[MÊS\]\[DIA\]\[HORA\]\[MINUTOS\]\[SEGUNDOS\]

| Bloco | Tamanho | Descrição / Exemplo |
| :---- | :---- | :---- |
| **Alias** | Variável | Prefixo customizado opcional (ex: Jose, TX, PEDIDO). |
| **Século** | 1 Caractere | Índice do século na tabela de 25 + 10, (2000 \= V). |
| **Ano** | 2 Dígitos | Últimos dois dígitos do ano corrente (ex: 26 para 2026). |
| **Mês** | 1 Letra | Mapeamento A-L (ex: Agosto \= H). |
| **Dia** | 1 Caractere | A-Z (dias 1-25) e 1-6 (dias 26-31; ex: dia 26 \= 1). |
| **Hora** | 1 Letra | Mapeamento A-Y sem O (ex: 01h \= B). |
| **Minutos** | 2 Dígitos | Padrão 00-59. |
| **Segundos** | 2 Dígitos | Padrão 00-59. |

💻 Implementações Oficiais
🎯 Dart / Flutter / Solidity / TypeScript 

