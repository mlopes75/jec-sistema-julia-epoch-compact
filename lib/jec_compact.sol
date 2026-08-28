// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SistemaJuliaFixo {
    // 25 caracteres (Sem o 'O') - índices 0 a 24
    bytes constant ALFABETO = "ABCDEFGHIJKLMNPQRSTUVWXYZ"; 

    function gerarIDJulia(
        string memory aliasName,
        uint256 anoCompleto,
        uint256 mes,
        uint256 dia,
        uint256 hora,
        uint256 minuto,
        uint256 segundo
    ) public pure returns (string memory) {
        // ===== VALIDAÇÕES =====
        require(mes >= 1 && mes <= 12, "Mes invalido (1-12)");
        require(dia >= 1 && dia <= 31, "Dia invalido (1-31)");
        require(hora <= 23, "Hora invalida (0-23)");
        require(minuto <= 59, "Minuto invalido (0-59)");
        require(segundo <= 59, "Segundo invalido (0-59)");
        require(anoCompleto >= 2000 && anoCompleto <= 9999, "Ano fora do limite (2000-9999)");
        
        bytes memory temporal = new bytes(10);

        // 1. Século índice direto
        uint256 seculo = anoCompleto / 100;
        if (seculo < 25) {
            // Século 20 (2000-2099) → índice 20 → 'W' ✅
            // Século 21 (2100-2199) → índice 21 → 'X' ✅
            // Século 22 (2200-2299) → índice 22 → 'Y' ✅
            // Século 23 (2300-2399) → índice 23 → 'Z' ✅
            temporal[0] = ALFABETO[seculo]; // ← CORREÇÃO AQUI
        } else {
            // A partir do Século 24 (2400+) usa números
            uint256 digitoSeculo = seculo - 23; // 24 → '1', 25 → '2', ...
            require(digitoSeculo <= 9, "Seculo fora do limite suportado");
            temporal[0] = bytes1(uint8(48 + digitoSeculo));
        }

        // 2 e 3. Ano (26 -> '2','6')
        uint256 ano = anoCompleto % 100;
        temporal[1] = bytes1(uint8(48 + (ano / 10)));
        temporal[2] = bytes1(uint8(48 + (ano % 10)));

        // 4. Mês (Mapeamento A-L)
        temporal[3] = ALFABETO[mes - 1];

        // 5. Dia (1..25 -> A..Z sem O | 26..31 -> 1..6)
        temporal[4] = (dia <= 25) ? ALFABETO[dia - 1] : bytes1(uint8(48 + (dia - 25)));

        // 6. Hora (0..23 -> A..Y sem O)
        temporal[5] = ALFABETO[hora];

        // 7 e 8. Minuto (00..59 -> '0','0')
        temporal[6] = bytes1(uint8(48 + (minuto / 10)));
        temporal[7] = bytes1(uint8(48 + (minuto % 10)));

        // 9 e 10. Segundo (00..59 -> '0','0')
        temporal[8] = bytes1(uint8(48 + (segundo / 10)));
        temporal[9] = bytes1(uint8(48 + (segundo % 10)));

        // Formatação do retorno final (Ponto SEMPRE presente)
        if (bytes(aliasName).length > 0) {
            return string(abi.encodePacked(aliasName, ".", temporal));
        }
        return string(abi.encodePacked(".", temporal));
    }
}
