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
    const seculo = "V"; // Século XXI fixo
    const ano = String(dt.getFullYear() % 100).padStart(2, "0");
    
    // Mês (A-L -> Jan-Dez)
    const mes = String.fromCharCode(65 + dt.getMonth());

    // Dia (A-Z sem O para 1-25; 1-6 para 26-31)
    const dayVal = dt.getDate();
    const dia = dayVal <= 25 ? this.BASE35_ALPHA[dayVal - 1] : String(dayVal - 25);

    // Hora (A-Y sem O para 00h-23h)
    const hora = this.BASE35_ALPHA[dt.getHours()];

    const minutos = String(dt.getMinutes()).padStart(2, "0");
    const segundos = String(dt.getSeconds()).padStart(2, "0");

    const prefixo = alias ? `${alias}.` : "";
    
    return `${prefixo}${seculo}${ano}${mes}${dia}${hora}${minutos}${segundos}`;
  }

  /**
   * 2. DECODE: Converte String JEC de volta para um objeto Date
   * @param {string} jecId 
   * @returns {Date}
   */
  static decode(jecId) {
    // Remove o prefixo/alias se ele existir na string
    const partes = jecId.split('.');
    const corpo = partes[partes.length - 1];

    if (corpo.length !== 10) {
      throw new Error("Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.");
    }

    // Fatiamento preciso das posições por índice
    const charSeculo = corpo[0];
    const anoDigitos = parseInt(corpo.substring(1, 3), 10);
    const charMes = corpo[3];
    const charDia = corpo[4];
    const charHora = corpo[5];
    const minuto = parseInt(corpo.substring(6, 8), 10);
    const segundo = parseInt(corpo.substring(8, 10), 10);

    // Reconstrução do Ano (Século XXI para 'V')
    const ano = charSeculo === "V" ? 2000 + anoDigitos : 1900 + anoDigitos;

    // Reconstrução do Mês (JS trabalha com meses indexados em 0: Jan = 0, Fev = 1...)
    const mesIdx = charMes.charCodeAt(0) - 65;

    // Reconstrução do Dia
    let dia;
    if (/^[1-6]$/.test(charDia)) {
      dia = parseInt(charDia, 10) + 25;
    } else {
      dia = this.BASE35_ALPHA.indexOf(charDia) + 1;
    }

    // Reconstrução da Hora
    const hora = this.BASE35_ALPHA.indexOf(charHora);

    return new Date(ano, mesIdx, dia, hora, minuto, segundo);
  }
}

// === 3. EXECUÇÃO DOS TESTES DE VALIDAÇÃO ===
console.log("=== INICIANDO TESTES DO SISTEMA JEC COMPACT EM JAVASCRIPT ===\n");

// Caso 1: Teste com Dia menor ou igual a 25
const data1 = new Date(2026, 7, 15, 14, 30, 45); // Nota: Agosto é index 7 em JS
const id1 = JuliaEpochCompact.encode(data1, "TX");
const resultado1 = JuliaEpochCompact.decode(id1);

console.log("Teste 1 (Dia Regular - 15/08):");
console.log("-> Original:  ", data1.toString());
console.log("-> ID JEC:    ", id1);
console.log("-> Decodado:  ", resultado1.toString());
console.log("-> Status:    ", data1.getTime() === resultado1.getTime() ? "✅ SUCESSO" : "❌ FALHOU", "\n");

// Caso 2: Teste com Dia limite (Maior que 25)
const data2 = new Date(2026, 11, 28, 23, 59, 0); // Nota: Dezembro é index 11 em JS
const id2 = JuliaEpochCompact.encode(data2);
const resultado2 = JuliaEpochCompact.decode(id2);

console.log("Teste 2 (Dia Limite - 28/12):");
console.log("-> Original:  ", data2.toString());
console.log("-> ID JEC:    ", id2);
console.log("-> Decodado:  ", resultado2.toString());
console.log("-> Status:    ", data2.getTime() === resultado2.getTime() ? "✅ SUCESSO" : "❌ FALHOU");
