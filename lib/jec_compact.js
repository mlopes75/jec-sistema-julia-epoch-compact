class JuliaEpochCompact {
  // Tabela Base 35 oficial (Exclui totalmente a letra 'O')
  static BASE35_ALPHA = "ABCDEFGHIJKLMNPQRSTUVWXYZ";

  /**
   * 1. ENCODE: Converte um objeto Date para String JEC
   * @param {Date} dt 
   * @param {string} [alias] 
   * @returns {string}
   */
  static encode(dt, alias = null) {
    const seculoCompleto = Math.floor(dt.getFullYear() / 100);
    let seculo;

    // CORRIGIDO: Índice direto (sem subtração)
    if (seculoCompleto < 25) {
      // Século 20 (2000-2099) → índice 20 → 'W' ✅
      // Século 21 (2100-2199) → índice 21 → 'X' ✅
      seculo = this.BASE35_ALPHA[seculoCompleto]; 
    } else {
      // A partir do Século 25 (2500+) usa números
      const digitoSeculo = seculoCompleto - 24; // 25 → '1'
      if (digitoSeculo > 9) throw new Error("Século fora do limite suportado.");
      seculo = String(digitoSeculo);
    }

    const ano = String(dt.getFullYear() % 100).padStart(2, "0");
    
    // Mês mapeado pela tabela oficial (A-L)
    const mes = this.BASE35_ALPHA[dt.getMonth()];

    // Dia (A-Z sem O para 1-25; 1-6 para 26-31)
    const dayVal = dt.getDate();
    const dia = dayVal <= 25 ? this.BASE35_ALPHA[dayVal - 1] : String(dayVal - 25);

    // Hora (A-Y sem O para 00h-23h)
    const hora = this.BASE35_ALPHA[dt.getHours()];

    const minutos = String(dt.getMinutes()).padStart(2, "0");
    const segundos = String(dt.getSeconds()).padStart(2, "0");

    // Ponto inicial SEMPRE presente (padrão JEC)
    const prefixo = alias ? `${alias}.` : ".";
    
    return `${prefixo}${seculo}${ano}${mes}${dia}${hora}${minutos}${segundos}`;
  }

  /**
   * 2. DECODE: Converte String JEC de volta para um objeto Date
   * @param {string} jecId 
   * @returns {Date}
   */
  static decode(jecId) {
    const partes = jecId.split('.');
    if (partes.length < 1 || partes.length > 2) {
      throw new Error("Formato JEC inválido: deve ter 0 ou 1 ponto");
    }
    
    const corpo = partes[partes.length - 1];

    if (corpo.length !== 10) {
      throw new Error("Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.");
    }

    const charSeculo = corpo[0];
    const anoDigitos = parseInt(corpo.substring(1, 3), 10);
    const charMes = corpo[3];
    const charDia = corpo[4];
    const charHora = corpo[5];
    const minuto = parseInt(corpo.substring(6, 8), 10);
    const segundo = parseInt(corpo.substring(8, 10), 10);

    // Reconstrução Dinâmica do Século (CORRIGIDO)
    let seculoCompleto;
    if (/^[1-9]$/.test(charSeculo)) {
      // Caso numérico (século 25+)
      seculoCompleto = parseInt(charSeculo, 10) + 24; // '1' → 25
    } else {
      // Caso alfabético (século 0-24)
      const idxSeculo = this.BASE35_ALPHA.indexOf(charSeculo);
      if (idxSeculo === -1) {
        throw new Error("Caractere de século inválido.");
      }
      seculoCompleto = idxSeculo; // 'W'(20) → século 20 ✅
    }
    const ano = (seculoCompleto * 100) + anoDigitos;

    // Reconstrução do Mês usando a tabela oficial
    const mesIdx = this.BASE35_ALPHA.indexOf(charMes);
    if (mesIdx === -1 || mesIdx > 11) {
      throw new Error(`Caractere de mês inválido: ${charMes} (deve ser A-L)`);
    }

    // Reconstrução do Dia
    let dia;
    if (/^[1-6]$/.test(charDia)) {
      dia = parseInt(charDia, 10) + 25;
    } else {
      const idx = this.BASE35_ALPHA.indexOf(charDia);
      if (idx === -1 || idx >= 25) {
        throw new Error(`Caractere de dia inválido: ${charDia}`);
      }
      dia = idx + 1;
    }

    // Reconstrução da Hora
    const hora = this.BASE35_ALPHA.indexOf(charHora);
    if (hora === -1 || hora > 23) {
      throw new Error(`Caractere de hora inválido: ${charHora} (deve ser A-Y)`);
    }

    // Validação final do dia
    if (dia < 1 || dia > 31) {
      throw new Error(`Dia inválido: ${dia}`);
    }

    return new Date(ano, mesIdx, dia, hora, minuto, segundo);
  }
}

// ===== TESTES =====
console.log("=== INICIANDO TESTES DO SISTEMA JEC COMPACT EM JS ===\n");

// Teste 1: Ano 2026
const data1 = new Date(Date.UTC(2026, 7, 15, 14, 30, 45));
const id1 = JuliaEpochCompact.encode(data1, "TX");
const resultado1 = JuliaEpochCompact.decode(id1);

console.log("Teste 1 (Dia Regular - 15/08/2026):");
console.log(`-> Original:  ${data1.toISOString()}`);
console.log(`-> ID JEC:    ${id1}`);
console.log(`-> Decodado:  ${resultado1.toISOString()}`);
console.log(`-> Status:    ${data1.getTime() === resultado1.getTime() ? "✅ SUCESSO" : "❌ FALHOU"}`);
console.log(`-> Esperado:  TX.W26H1B3045\n`); // W26 = 2026 ✅

// Teste 2: Ano 2100
const data2 = new Date(Date.UTC(2100, 0, 1, 0, 0, 0));
const id2 = JuliaEpochCompact.encode(data2);
const resultado2 = JuliaEpochCompact.decode(id2);

console.log("Teste 2 (Ano 2100):");
console.log(`-> Original:  ${data2.toISOString()}`);
console.log(`-> ID JEC:    ${id2}`);
console.log(`-> Decodado:  ${resultado2.toISOString()}`);
console.log(`-> Status:    ${data2.getTime() === resultado2.getTime() ? "✅ SUCESSO" : "❌ FALHOU"}`);
console.log(`-> Esperado:  .X00A1A0000\n`); // X = 2100 ✅
    const hora = this.BASE35_ALPHA.indexOf(charHora);

    return new Date(ano, mesIdx, dia, hora, minuto, segundo);
  }
}
