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

    // Lógica milenar idêntica ao Solidity
    if (seculoCompleto <= 25) {
      seculo = this.BASE35_ALPHA[seculoCompleto - 1];
    } else {
      const digitoSeculo = seculoCompleto - 25;
      if (digitoSeculo > 9) throw new Error("Século fora do limite suportado.");
      seculo = String(digitoSeculo);
    }

    const ano = String(dt.getFullYear() % 100).padStart(2, "0");
    
    // Mês mapeado pela tabela oficial (Garante sincronia com Solidity)
    const mes = this.BASE35_ALPHA[dt.getMonth()];

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
    const partes = jecId.split('.');
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

    // Reconstrução Dinâmica do Século
    let seculoCompleto;
    if (/^[1-9]$/.test(charSeculo)) {
      seculoCompleto = parseInt(charSeculo, 10) + 25;
    } else {
      seculoCompleto = this.BASE35_ALPHA.indexOf(charSeculo) + 1;
      if (seculoCompleto === 0) throw new Error("Caractere de século inválido.");
    }
    const ano = (seculoCompleto * 100) + anoDigitos;

    // Reconstrução do Mês usando a tabela oficial
    const mesIdx = this.BASE35_ALPHA.indexOf(charMes);

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
