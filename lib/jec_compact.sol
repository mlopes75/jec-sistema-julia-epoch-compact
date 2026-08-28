// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SistemaJuliaFixo {
    // 25 caracteres (Sem o 'O')
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
        bytes memory temporal = new bytes(10);

        // 1. Século (Mapeia século 20 para o índice 19 -> 'V')
        uint256 seculo = anoCompleto / 100;
        if (seculo <= 25) {
            // Século 20 vira índice 19 ('V'). Século 25 vira índice 24 ('Z')
            temporal[0] = ALFABETO[seculo - 1]; 
        } else {
            // A partir do Século 26 (Ano 2600), começa de 1 a 9
            uint256 digitoSeculo = seculo - 25;
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

        // Formatação do retorno final
        if (bytes(aliasName).length > 0) {
            return string(abi.encodePacked(aliasName, ".", temporal));
        }
        return string(abi.encodePacked(".", temporal));
    }
}
