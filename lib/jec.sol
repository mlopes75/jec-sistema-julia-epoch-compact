// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract JuliaEpochCompact {
    // 25 letras (sem 'O') + 10 números
    bytes constant ALPHA = "ABCDEFGHIJKLMNPQRSTUVWXYZ";
    bytes constant NUM = "1234567890";

    /// @dev Gera ID JEC: [ALIAS.] + 10 caracteres temporais
    function encode(
        string calldata alias,
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) external pure returns (string memory) {
        require(year >= 0, "year");
        require(month >= 1 && month <= 12, "month");
        require(day >= 1 && day <= 31, "day");
        require(hour <= 23, "hour");
        require(minute <= 59, "minute");
        require(second <= 59, "second");

        // Século (cíclico a cada 3500 anos)
        uint256 sec = (year / 100) % 35;
        bytes1 secChar = sec < 25 ? ALPHA[sec] : NUM[sec - 25];

        // Ano (2 dígitos)
        uint256 y = year % 100;
        bytes1 y1 = bytes1(uint8(48 + y / 10));
        bytes1 y0 = bytes1(uint8(48 + y % 10));

        // Mês (A-L)
        bytes1 mon = ALPHA[month - 1];

        // Dia: 1-25 -> letra, 26-31 -> '1'..'6'
        bytes1 d = day <= 25 ? ALPHA[day - 1] : bytes1(uint8(48 + (day - 25)));

        // Hora: 0-23 -> A-Y (sem O)
        bytes1 h = ALPHA[hour];

        // Minuto e segundo (2 dígitos)
        bytes1 m1 = bytes1(uint8(48 + minute / 10));
        bytes1 m0 = bytes1(uint8(48 + minute % 10));
        bytes1 s1 = bytes1(uint8(48 + second / 10));
        bytes1 s0 = bytes1(uint8(48 + second % 10));

        // Monta bloco temporal (10 bytes)
        bytes memory temporal = new bytes(10);
        temporal[0] = secChar;
        temporal[1] = y1;
        temporal[2] = y0;
        temporal[3] = mon;
        temporal[4] = d;
        temporal[5] = h;
        temporal[6] = m1;
        temporal[7] = m0;
        temporal[8] = s1;
        temporal[9] = s0;

        // Prefixo com alias (ou '.')
        if (bytes(alias).length > 0) {
            return string(abi.encodePacked(alias, ".", temporal));
        }
        return string(abi.encodePacked(".", temporal));
    }

    /// @dev Decodifica um ID JEC para os componentes (ano, mês, dia, hora, minuto, segundo)
    /// Nota: O decode usa o primeiro ciclo (0-3499) por simplicidade.
    function decode(string calldata jecId)
        external
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        bytes memory id = bytes(jecId);
        require(id.length >= 11, "ID curto"); // pelo menos "." + 10 caracteres

        // Encontra a posição do ponto (separador)
        uint256 dotPos = type(uint256).max;
        for (uint256 i = 0; i < id.length; i++) {
            if (id[i] == ".") {
                dotPos = i;
                break;
            }
        }
        require(dotPos != type(uint256).max, "Sem ponto");
        require(id.length - dotPos - 1 == 10, "Bloco temporal deve ter 10 caracteres");

        // Extrai o corpo temporal (após o ponto)
        bytes memory temporal = new bytes(10);
        for (uint256 i = 0; i < 10; i++) {
            temporal[i] = id[dotPos + 1 + i];
        }

        // Decodifica século
        bytes1 secChar = temporal[0];
        uint256 sec;
        if (secChar == "0") {
            sec = 34;
        } else if (secChar >= "1" && secChar <= "9") {
            uint256 idx = _indexOf(NUM, secChar);
            require(idx != type(uint256).max, "Seculo invalido");
            sec = 25 + idx;
        } else {
            uint256 idx = _indexOf(ALPHA, secChar);
            require(idx != type(uint256).max, "Seculo invalido");
            sec = idx;
        }
        year = sec * 100 + _parse2Digits(temporal[1], temporal[2]);

        // Mês
        uint256 idxMon = _indexOf(ALPHA, temporal[3]);
        require(idxMon != type(uint256).max && idxMon < 12, "Mes invalido");
        month = idxMon + 1;

        // Dia
        bytes1 dChar = temporal[4];
        if (dChar >= "1" && dChar <= "6") {
            day = uint8(dChar) - 48 + 25;
        } else {
            uint256 idxDay = _indexOf(ALPHA, dChar);
            require(idxDay != type(uint256).max && idxDay < 25, "Dia invalido");
            day = idxDay + 1;
        }
        require(day >= 1 && day <= 31, "Dia invalido");

        // Hora
        uint256 idxHour = _indexOf(ALPHA, temporal[5]);
        require(idxHour != type(uint256).max && idxHour < 24, "Hora invalida");
        hour = idxHour;

        // Minuto e segundo
        minute = _parse2Digits(temporal[6], temporal[7]);
        second = _parse2Digits(temporal[8], temporal[9]);
        require(minute <= 59 && second <= 59, "Minuto/segundo invalido");

        // Validação simples de data (evita 31/02 etc.)
        // (Solidity não tem validação nativa, então fazemos uma verificação aproximada)
        // Para simplificar, apenas garantimos que o dia não seja > 29 em fevereiro, etc.
        // Mas o ideal é usar uma biblioteca de datas.
        if (month == 2) {
            // Ano bissexto aproximado
            bool leap = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
            require(day <= (leap ? 29 : 28), "Dia invalido para Fevereiro");
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            require(day <= 30, "Dia invalido para mes com 30 dias");
        }
        // Para os outros meses, o dia já foi validado (<=31)
    }

    // Utilitários
    function _indexOf(bytes memory set, bytes1 ch) private pure returns (uint256) {
        for (uint256 i = 0; i < set.length; i++) {
            if (set[i] == ch) return i;
        }
        return type(uint256).max;
    }

    function _parse2Digits(bytes1 tens, bytes1 units) private pure returns (uint256) {
        return (uint8(tens) - 48) * 10 + (uint8(units) - 48);
    }
}
