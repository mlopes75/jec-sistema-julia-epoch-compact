class JuliaEpochCompact {
  // Tabela Base 35 oficial (Exclui totalmente a letra 'O')
  private static readonly BASE35_ALPHA: string = "ABCDEFGHIJKLMNPQRSTUVWXYZ";

  /**
   * 1. ENCODE: Converte um objeto Date para uma String JEC compactada
   */
  public static encode(dt: Date, alias: string | null = null): string {
    const seculo: string = "V"; // Século XXI fixo
    const ano: string = String(dt.getFullYear() % 100).padStart(2, "0");
    
    // Mês (A-L -> Jan-Dez)
    const mes: string = String.fromCharCode(65 + dt.getMonth());

    // Dia (A-Z sem O para 1-25; 1-6 para 26-31)
    const dayVal: number = dt.getDate();
    const dia: string = dayVal <= 25 ? this.BASE35_ALPHA[dayVal - 1] : String(dayVal - 25);

    // Hora (A-Y sem O para 00h-23h)
    const hora: string = this.BASE35_ALPHA[dt.getHours()];

    const minutos: string = String(dt.getMinutes()).padStart(2, "0");
    const segundos: string = String(dt.getSeconds()).padStart(2, "0");

    const prefixo: string = alias ? `${alias}.` : "";
    
    return `${prefixo}${seculo}${ano}${mes}${dia}${hora}${minutos}${segundos}`;
  }

  /**
   * 2. DECODE: Converte uma String JEC de volta para um objeto Date válido
   */
  public static decode(jecId: string): Date {
    const partes: string[] = jecId.split('.');
    const corpo: string = partes[partes.length - 1];

    if (corpo.length !== 10) {
      throw new Error("Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.");
    }

    // Fatiamento preciso baseado na estrutura posicional rígida de 10 caracteres
    const charSeculo: string = corpo[0];
    const anoDigitos: number = parseInt(corpo.substring(1, 3), 10);
    const charMes: string = corpo[3];
    const charDia: string = corpo[4];
    const charHora: string = corpo[5];
    const minuto: number = parseInt(corpo.substring(6, 8), 10);
    const segundo: number = parseInt(corpo.substring(8, 10), 10);

    // Reconstrução do Ano
    const ano: number = charSeculo === "V" ? 2000 + anoDigitos : 1900 + anoDigitos;

    // Reconstrução do Mês (No ecossistema JS/TS, Janeiro é 0 e Dezembro é 11)
    const mesIdx: number = charMes.charCodeAt(0) - 65;

    // Reconstrução do Dia
    let dia: number;
    if (/^[1-6]$/.test(charDia)) {
      dia = parseInt(charDia, 10) + 25;
    } else {
      dia = this.BASE35_ALPHA.indexOf(charDia) + 1;
    }

    // Reconstrução da Hora
    const hora: number = this.BASE35_ALPHA.indexOf(charHora);

    return new Date(ano, mesIdx, dia, hora, minuto, segundo);
  }
}
