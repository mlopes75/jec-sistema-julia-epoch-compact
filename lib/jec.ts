/**
 * Julia Epoch Compact (JEC)
 * 
 * Codifica/decodifica datas UTC em identificadores compactos de 10 caracteres
 * com suporte a alias (namespace).
 * 
 * Mapeamento:
 * - Século: (year / 100) % 35 → 0-24 letras (A-Z sem O), 25-34 números (1-0)
 * - Ano: 2 dígitos
 * - Mês: A-L (Janeiro-Dezembro)
 * - Dia: 1-25 → letras (A-Z sem O); 26-31 → '1'..'6'
 * - Hora: 0-23 → A-Y (sem O)
 * - Minuto/Segundo: 2 dígitos
 */
export class JuliaEpochCompact {
  private static readonly ALPHA = 'ABCDEFGHIJKLMNPQRSTUVWXYZ'; // 25 letras (sem O)
  private static readonly NUM = '1234567890';                 // 10 dígitos

  /**
   * Codifica uma data UTC em um ID JEC.
   * @param date Data (será convertida para UTC)
   * @param alias Alias opcional (namespace)
   * @returns ID no formato [alias.]SAA MD H mm ss (10 caracteres temporais)
   */
  static encode(date: Date, alias?: string): string {
    // Força UTC
    const d = new Date(date.getTime());
    const year = d.getUTCFullYear();
    if (year < 0) throw new Error('Ano inválido.');

    // Século cíclico (0-34)
    const century = Math.floor(year / 100) % 35;
    const secChar = century < 25
      ? this.ALPHA[century]
      : this.NUM[century - 25];

    // Ano (2 dígitos)
    const yearStr = String(year % 100).padStart(2, '0');

    // Mês (A-L)
    const monthChar = this.ALPHA[d.getUTCMonth()]; // 0-11

    // Dia: 1-25 → letra, 26-31 → '1'..'6'
    const day = d.getUTCDate();
    const dayChar = day <= 25
      ? this.ALPHA[day - 1]
      : String(day - 25);

    // Hora (0-23 → A-Y)
    const hourChar = this.ALPHA[d.getUTCHours()];

    // Minuto e segundo (2 dígitos)
    const minStr = String(d.getUTCMinutes()).padStart(2, '0');
    const secStr = String(d.getUTCSeconds()).padStart(2, '0');

    // Prefixo
    const prefix = (alias && alias.length > 0) ? `${alias}.` : '.';

    // Monta o ID
    return `${prefix}${secChar}${yearStr}${monthChar}${dayChar}${hourChar}${minStr}${secStr}`;
  }

  /**
   * Decodifica um ID JEC para uma data UTC.
   * @param id ID JEC (com ou sem alias)
   * @returns Data UTC
   */
  static decode(id: string): Date {
    if (!id) throw new Error('ID vazio.');
    const parts = id.split('.');
    if (parts.length > 2) throw new Error('Formato inválido.');
    const body = parts[parts.length - 1];
    if (body.length !== 10) throw new Error('Tamanho incorreto (10 caracteres).');

    const secChar = body[0];
    const yearDigits = parseInt(body.substring(1, 3), 10);
    const monthChar = body[3];
    const dayChar = body[4];
    const hourChar = body[5];
    const minute = parseInt(body.substring(6, 8), 10);
    const second = parseInt(body.substring(8, 10), 10);

    // Decodifica século
    let pos: number;
    if (secChar === '0') {
      pos = 34;
    } else if (secChar >= '1' && secChar <= '9') {
      const idx = this.NUM.indexOf(secChar);
      if (idx === -1) throw new Error('Século inválido.');
      pos = 25 + idx;
    } else {
      pos = this.ALPHA.indexOf(secChar);
      if (pos === -1) throw new Error('Século inválido.');
    }
    const year = pos * 100 + yearDigits;

    // Mês (A-L)
    const month = this.ALPHA.indexOf(monthChar) + 1;
    if (month < 1 || month > 12) throw new Error('Mês inválido.');

    // Dia (letra ou número)
    let day: number;
    if (dayChar >= '1' && dayChar <= '6') {
      day = parseInt(dayChar, 10) + 25;
    } else {
      const idx = this.ALPHA.indexOf(dayChar);
      if (idx < 0 || idx >= 25) throw new Error('Dia inválido.');
      day = idx + 1;
    }
    if (day < 1 || day > 31) throw new Error('Dia inválido.');

    // Hora (A-Y)
    const hour = this.ALPHA.indexOf(hourChar);
    if (hour < 0 || hour > 23) throw new Error('Hora inválida.');

    if (minute < 0 || minute > 59) throw new Error('Minuto inválido.');
    if (second < 0 || second > 59) throw new Error('Segundo inválido.');

    // Cria a data UTC e valida
    const result = new Date(Date.UTC(year, month - 1, day, hour, minute, second));
    if (result.getUTCFullYear() !== year ||
        result.getUTCMonth() !== month - 1 ||
        result.getUTCDate() !== day ||
        result.getUTCHours() !== hour ||
        result.getUTCMinutes() !== minute ||
        result.getUTCSeconds() !== second) {
      throw new Error('Data inválida.');
    }
    return result;
  }
}

// ============================================================
// Testes (executar com ts-node ou node)
// ============================================================
const testCases: [Date, string | undefined, string][] = [
  [new Date(Date.UTC(2026, 7, 15, 14, 30, 45)), 'TX', 'TX.V26HPP3045'],
  [new Date(Date.UTC(2100, 0, 1, 0, 0, 0)), undefined, '.W00AAA0000'],
  [new Date(Date.UTC(2400, 0, 1, 0, 0, 0)), undefined, '.Z00AAA0000'],
  [new Date(Date.UTC(2500, 0, 1, 0, 0, 0)), undefined, '.100AAA0000'],
  [new Date(Date.UTC(3400, 0, 1, 0, 0, 0)), undefined, '.000AAA0000'],
  [new Date(Date.UTC(3500, 0, 1, 0, 0, 0)), undefined, '.A00AAA0000'],
  [new Date(Date.UTC(0, 0, 1, 0, 0, 0)), undefined, '.A00AAA0000'],
];

console.log('=== SISTEMA JULIA (TypeScript) ===\n');
testCases.forEach(([dt, alias, expected], i) => {
  const encoded = JuliaEpochCompact.encode(dt, alias);
  const decoded = JuliaEpochCompact.decode(encoded);
  const ok = (dt.getTime() === decoded.getTime()) && (encoded === expected);
  console.log(`Teste ${i+1}: ${ok ? '✅ SUCESSO' : '❌ FALHOU'}`);
  console.log(`  ID: ${encoded}`);
  console.log(`  Esperado: ${expected}\n`);
});
