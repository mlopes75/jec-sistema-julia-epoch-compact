// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SistemaJuliaFixo {
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
        bytes memory temporal = new bytes(9);

        // 1. Século (2000 -> 'V')
        temporal[0] = ALFABETO[anoCompleto / 100];

        // 2 e 3. Ano (26 -> '2','6')
        uint256 ano = anoCompleto % 100;
        temporal[1] = bytes1(uint8(48 + (ano / 10)));
        temporal[2] = bytes1(uint8(48 + (ano % 10)));

        // 4. Mês (8 -> 'H')
        temporal[3] = ALFABETO[mes - 1];

        // 5. Dia (1..25 -> A..Z sem O | 26..31 -> 1..6)
        temporal[4] = (dia <= 25) ? ALFABETO[dia - 1] : bytes1(uint8(48 + (dia - 25)));

        // 6. Hora (13 -> 'N')
        temporal[5] = ALFABETO[hora];

        // 7 e 8. Minuto (03 -> '0','3')
        temporal[6] = bytes1(uint8(48 + (minuto / 10)));
        temporal[7] = bytes1(uint8(48 + (minuto % 10)));

        // 9. Segundo (09 -> '0','9') -- ajusta para o último caractere
        bytes memory id9 = abi.encodePacked(
            temporal[0], temporal[1], temporal[2], temporal[3], 
            temporal[4], temporal[5], temporal[6], temporal[7], 
            bytes1(uint8(48 + (segundo / 10))), bytes1(uint8(48 + (segundo % 10)))
        );

        // Nota: encodePacked ajusta o tamanho exato dos 9 caracteres temporais
        bytes memory idFinal = new bytes(9);
        for(uint i = 0; i < 9; i++) {
            if(i < 8) idFinal[i] = id9[i];
            else idFinal[8] = bytes1(uint8(48 + (segundo % 10))); // garante 9 chars
        }

        // Formatação do retorno final
        if (bytes(aliasName).length > 0) {
            return string(abi.encodePacked(aliasName, ".", temporal));
        }
        return string(abi.encodePacked(".", temporal));
    }
}
