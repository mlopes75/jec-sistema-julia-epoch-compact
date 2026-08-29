class JuliaEpochCompact {
  // Tabela oficial: 25 letras + 10 números.
  // A letra "O" é excluída para evitar confusão com "0".
  static BASE35_ALPHA = "ABCDEFGHIJKLMNPQRSTUVWXYZ";
  static BASE35_NUM = "1234567890";

  /**
   * 1. ENCODE
   * Converte um objeto Date para String JEC.
   *
   * Estrutura:
   *
   * [ALIAS].[SÉCULO][ANO][MÊS][DIA][HORA][MIN][SEG]
   *
   * Exemplos:
   *
   * 2000 -> V
   * 2100 -> W
   * 2500 -> 1
   * 3400 -> 0
   * 3500 -> A
   */
  static encode(dt, alias = null) {
    if (!(dt instanceof Date) || isNaN(dt.getTime())) {
      throw new TypeError("Data inválida.");
    }

    // O Sistema Julia utiliza UTC.
    const anoCompleto = dt.getUTCFullYear();

    if (anoCompleto < 0) {
      throw new RangeError("Ano inválido.");
    }

    // Século absoluto.
    //
    // 0000 -> 0 -> A
    // 1000 -> 10 -> K
    // 2000 -> 20 -> V
    // 2100 -> 21 -> W
    // 2400 -> 24 -> Z
    // 2500 -> 25 -> 1
    // 3400 -> 34 -> 0
    // 3500 -> 35 % 35 = 0 -> A
    //
    // O ciclo possui 35 séculos = 3500 anos.
    const seculoCompleto =
      Math.floor(anoCompleto / 100);

    const posicao =
      seculoCompleto % 35;

    const seculo =
      posicao < 25
        ? this.BASE35_ALPHA[posicao]
        : this.BASE35_NUM[posicao - 25];

    // Ano: últimos dois dígitos.
    const ano =
      String(anoCompleto % 100).padStart(2, "0");

    // Mês: A-L.
    const mes =
      this.BASE35_ALPHA[dt.getUTCMonth()];

    // Dia:
    // 01-25 -> letras
    // 26-31 -> 1-6
    const dayVal =
      dt.getUTCDate();

    const dia =
      dayVal <= 25
        ? this.BASE35_ALPHA[dayVal - 1]
        : String(dayVal - 25);

    // Hora:
    // 00-23 -> A-Y, sem O.
    const hora =
      this.BASE35_ALPHA[dt.getUTCHours()];

    // Minutos: 00-59.
    const minutos =
      String(dt.getUTCMinutes()).padStart(2, "0");

    // Segundos: 00-59.
    const segundos =
      String(dt.getUTCSeconds()).padStart(2, "0");

    // Alias opcional.
    //
    // Com alias:
    //     USR.V26H1B1420
    //
    // Sem alias:
    //     .V26H1B1420
    const prefixo =
      alias !== null && alias !== ""
        ? `${alias}.`
        : ".";

    return `${prefixo}${seculo}${ano}${mes}${dia}${hora}${minutos}${segundos}`;
  }


  /**
   * 2. DECODE
   * Converte String JEC para Date UTC.
   *
   * ATENÇÃO:
   *
   * O século é cíclico a cada 3500 anos.
   * Portanto, o mesmo código de século + ano pode
   * representar anos separados por 3500 anos.
   *
   * Exemplo:
   *
   * .A00A1A0000
   *
   * pode representar:
   * 0000, 3500, 7000, 10500...
   *
   * Por isso, o decode utiliza o primeiro ciclo
   * (0000-3499).
   */
  static decode(jecId) {
    if (typeof jecId !== "string") {
      throw new TypeError(
        "ID Julia deve ser uma String."
      );
    }

    const partes =
      jecId.split(".");

    if (partes.length < 1 || partes.length > 2) {
      throw new Error(
        "Formato JEC inválido: deve possuir no máximo um ponto."
      );
    }

    const corpo =
      partes[partes.length - 1];

    if (corpo.length !== 10) {
      throw new Error(
        "O bloco temporal deve possuir exatamente 10 caracteres."
      );
    }

    const charSeculo = corpo[0];

    const anoDigitos =
      Number(corpo.substring(1, 3));

    const charMes = corpo[3];
    const charDia = corpo[4];
    const charHora = corpo[5];

    const minuto =
      Number(corpo.substring(6, 8));

    const segundo =
      Number(corpo.substring(8, 10));


    // ================================================================
    // SÉCULO
    // ================================================================

    let posicao;

    if (/^[1-9]$/.test(charSeculo)) {
      // 1-9 = posições 25-33.
      const idx =
        this.BASE35_NUM.indexOf(charSeculo);

      if (idx === -1) {
        throw new Error(
          `Caractere de século inválido: ${charSeculo}`
        );
      }

      posicao = 25 + idx;

    } else if (charSeculo === "0") {
      // 0 = posição 34.
      posicao = 34;

    } else {
      // A-Z sem O.
      posicao =
        this.BASE35_ALPHA.indexOf(charSeculo);

      if (posicao === -1) {
        throw new Error(
          `Caractere de século inválido: ${charSeculo}`
        );
      }
    }

    // Primeiro ciclo:
    //
    // A = século 0
    // ...
    // Z = século 24
    // 1 = século 25
    // ...
    // 0 = século 34
    const seculoCompleto =
      posicao;

    const ano =
      seculoCompleto * 100 + anoDigitos;


    // ================================================================
    // MÊS
    // ================================================================

    const mesIdx =
      this.BASE35_ALPHA.indexOf(charMes);

    if (mesIdx < 0 || mesIdx > 11) {
      throw new Error(
        `Caractere de mês inválido: ${charMes}`
      );
    }


    // ================================================================
    // DIA
    // ================================================================

    let dia;

    if (/^[1-6]$/.test(charDia)) {
      dia =
        Number(charDia) + 25;

    } else {
      const idx =
        this.BASE35_ALPHA.indexOf(charDia);

      if (idx < 0 || idx >= 25) {
        throw new Error(
          `Caractere de dia inválido: ${charDia}`
        );
      }

      dia = idx + 1;
    }


    // ================================================================
    // HORA
    // ================================================================

    const hora =
      this.BASE35_ALPHA.indexOf(charHora);

    if (hora < 0 || hora > 23) {
      throw new Error(
        `Caractere de hora inválido: ${charHora}`
      );
    }


    // ================================================================
    // VALIDAÇÕES
    // ================================================================

    if (
      !Number.isInteger(anoDigitos) ||
      anoDigitos < 0 ||
      anoDigitos > 99
    ) {
      throw new Error("Ano inválido.");
    }

    if (
      !Number.isInteger(minuto) ||
      minuto < 0 ||
      minuto > 59
    ) {
      throw new Error("Minuto inválido.");
    }

    if (
      !Number.isInteger(segundo) ||
      segundo < 0 ||
      segundo > 59
    ) {
      throw new Error("Segundo inválido.");
    }

    if (dia < 1 || dia > 31) {
      throw new Error(`Dia inválido: ${dia}`);
    }


    // ================================================================
    // DATA UTC
    // ================================================================

    const resultado =
      new Date(
        Date.UTC(
          ano,
          mesIdx,
          dia,
          hora,
          minuto,
          segundo
        )
      );


    // Impede datas inexistentes, como 31/02.
    if (
      resultado.getUTCFullYear() !== ano ||
      resultado.getUTCMonth() !== mesIdx ||
      resultado.getUTCDate() !== dia ||
      resultado.getUTCHours() !== hora ||
      resultado.getUTCMinutes() !== minuto ||
      resultado.getUTCSeconds() !== segundo
    ) {
      throw new Error(
        "Data/hora inválida."
      );
    }

    return resultado;
  }
}


// ============================================================================
// TESTES
// ============================================================================

console.log(
  "=== SISTEMA JULIA ===\n"
);


// -----------------------------------------------------------------------------
// 2026 -> V
// -----------------------------------------------------------------------------

const data1 =
  new Date(
    Date.UTC(2026, 7, 15, 14, 30, 45)
  );

const id1 =
  JuliaEpochCompact.encode(
    data1,
    "TX"
  );

const resultado1 =
  JuliaEpochCompact.decode(id1);

console.log(
  "Teste 1 - 2026"
);

console.log(
  "Original: ",
  data1.toISOString()
);

console.log(
  "ID:       ",
  id1
);

console.log(
  "Decodado: ",
  resultado1.toISOString()
);

console.log(
  "Status:   ",
  data1.getTime() === resultado1.getTime()
    ? "SUCESSO"
    : "FALHOU"
);

console.log(
  "Esperado:  TX.V26H1B3045\n"
);


// -----------------------------------------------------------------------------
// 2100 -> W
// -----------------------------------------------------------------------------

const data2 =
  new Date(
    Date.UTC(2100, 0, 1, 0, 0, 0)
  );

const id2 =
  JuliaEpochCompact.encode(data2);

console.log(
  "Teste 2 - 2100"
);

console.log(
  "ID:       ",
  id2
);

console.log(
  "Esperado:  .W00A1A0000\n"
);


// -----------------------------------------------------------------------------
// 2400 -> Z
// -----------------------------------------------------------------------------

const data3 =
  new Date(
    Date.UTC(2400, 0, 1, 0, 0, 0)
  );

const id3 =
  JuliaEpochCompact.encode(data3);

console.log(
  "Teste 3 - 2400"
);

console.log(
  "ID:       ",
  id3
);

console.log(
  "Esperado:  .Z00A1A0000\n"
);


// -----------------------------------------------------------------------------
// 2500 -> 1
// -----------------------------------------------------------------------------

const data4 =
  new Date(
    Date.UTC(2500, 0, 1, 0, 0, 0)
  );

const id4 =
  JuliaEpochCompact.encode(data4);

console.log(
  "Teste 4 - 2500"
);

console.log(
  "ID:       ",
  id4
);

console.log(
  "Esperado:  .100A1A0000\n"
);


// -----------------------------------------------------------------------------
// 3400 -> 0
// -----------------------------------------------------------------------------

const data5 =
  new Date(
    Date.UTC(3400, 0, 1, 0, 0, 0)
  );

const id5 =
  JuliaEpochCompact.encode(data5);

console.log(
  "Teste 5 - 3400"
);

console.log(
  "ID:       ",
  id5
);

console.log(
  "Esperado:  .000A1A0000\n"
);


// -----------------------------------------------------------------------------
// 3500 -> A
// -----------------------------------------------------------------------------

const data6 =
  new Date(
    Date.UTC(3500, 0, 1, 0, 0, 0)
  );

const id6 =
  JuliaEpochCompact.encode(data6);

console.log(
  "Teste 6 - 3500"
);

console.log(
  "ID:       ",
  id6
);

console.log(
  "Esperado:  .A00A1A0000\n"
);
    const hora = this.BASE35_ALPHA.indexOf(charHora);

    return new Date(ano, mesIdx, dia, hora, minuto, segundo);
  }
}
