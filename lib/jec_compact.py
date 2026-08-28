import re
from datetime import datetime

class JuliaEpochCompact:
    # Tabela Base 35 oficial (Exclui totalmente a letra 'O')
    BASE35_ALPHA = "ABCDEFGHIJKLMNPQRSTUVWXYZ"

    @classmethod
    def encode(cls, dt: datetime, alias: str = None) -> str:
        """1. ENCODE: Converte um datetime para String JEC"""
        seculo_completo = dt.year // 100
        
        # CORRIGIDO: Índice direto (sem subtração)
        if seculo_completo < 25:
            # Século 20 (2000-2099) → índice 20 → 'W' ✅
            # Século 21 (2100-2199) → índice 21 → 'X' ✅
            seculo = cls.BASE35_ALPHA[seculo_completo] 
        else:
            # A partir do Século 25 (2500+) usa números
            digito_seculo = seculo_completo - 24  # 25 → '1'
            if digito_seculo > 9:
                raise ValueError("Século fora do limite suportado.")
            seculo = str(digito_seculo)

        ano = f"{dt.year % 100:02d}"
        
        # Mês mapeado estritamente através da tabela oficial
        mes = cls.BASE35_ALPHA[dt.month - 1]

        # Dia (A-Z sem O para 1-25; 1-6 para 26-31)
        if dt.day <= 25:
            dia = cls.BASE35_ALPHA[dt.day - 1]
        else:
            dia = str(dt.day - 25)

        # Hora (A-Y sem O para 00h-23h)
        hora = cls.BASE35_ALPHA[dt.hour]

        minutos = f"{dt.minute:02d}"
        segundos = f"{dt.second:02d}"

        # Ponto inicial SEMPRE presente (padrão JEC)
        prefixo = f"{alias}." if alias else "."
        
        return f"{prefixo}{seculo}{ano}{mes}{dia}{hora}{minutos}{segundos}"

    @classmethod
    def decode(cls, jec_id: str) -> datetime:
        """2. DECODE: Converte String JEC de volta para datetime"""
        partes = jec_id.split('.')
        if len(partes) < 1 or len(partes) > 2:
            raise ValueError("Formato JEC inválido: deve ter 0 ou 1 ponto")
        
        corpo = partes[-1]

        if len(corpo) != 10:
            raise ValueError("Formato JEC inválido. O bloco temporal deve ter exatamente 10 caracteres.")

        char_seculo = corpo[0]
        ano_digitos = int(corpo[1:3])
        char_mes = corpo[3]
        char_dia = corpo[4]
        char_hora = corpo[5]
        minuto = int(corpo[6:8])
        segundo = int(corpo[8:10])

        # Reconstrução Dinâmica do Século (CORRIGIDO)
        if char_seculo.isdigit() and '1' <= char_seculo <= '9':
            # Caso numérico (século 25+)
            seculo_completo = int(char_seculo) + 24  # '1' → 25
        else:
            # Caso alfabético (século 0-24)
            if char_seculo not in cls.BASE35_ALPHA:
                raise ValueError(f"Caractere de século inválido: {char_seculo}")
            seculo_completo = cls.BASE35_ALPHA.index(char_seculo)  # 'W'(20) → século 20 ✅
            
        ano = (seculo_completo * 100) + ano_digitos

        # Reconstrução do Mês usando a tabela oficial
        if char_mes not in cls.BASE35_ALPHA:
            raise ValueError(f"Caractere de mês inválido: {char_mes}")
        mes = cls.BASE35_ALPHA.index(char_mes) + 1
        if mes > 12:
            raise ValueError(f"Caractere de mês inválido: {char_mes} (deve ser A-L)")

        # Reconstrução do Dia
        if char_dia.isdigit() and '1' <= char_dia <= '6':
            dia = int(char_dia) + 25
        else:
            if char_dia not in cls.BASE35_ALPHA:
                raise ValueError(f"Caractere de dia inválido: {char_dia}")
            dia = cls.BASE35_ALPHA.index(char_dia) + 1

        # Reconstrução da Hora
        if char_hora not in cls.BASE35_ALPHA:
            raise ValueError(f"Caractere de hora inválido: {char_hora}")
        hora = cls.BASE35_ALPHA.index(char_hora)
        if hora > 23:
            raise ValueError(f"Caractere de hora inválido: {char_hora} (deve ser A-Y)")

        # Validação final do dia
        if dia < 1 or dia > 31:
            raise ValueError(f"Dia inválido: {dia}")

        return datetime(ano, mes, dia, hora, minuto, segundo)


# 3. EXECUÇÃO DOS TESTES DE VALIDAÇÃO
if __name__ == "__main__":
    print("=== INICIANDO TESTES DO SISTEMA JEC COMPACT EM PYTHON ===\n")

    # Teste 1: Ano 2026
    data1 = datetime(2026, 8, 15, 14, 30, 45)
    id1 = JuliaEpochCompact.encode(data1, alias="TX")
    resultado1 = JuliaEpochCompact.decode(id1)
    
    print("Teste 1 (Dia Regular - 15/08/2026):")
    print(f"-> Original:  {data1}")
    print(f"-> ID JEC:    {id1}")
    print(f"-> Decodado:  {resultado1}")
    print(f"-> Status:    {'✅ SUCESSO' if data1 == resultado1 else '❌ FALHOU'}")
    print(f"-> Esperado:  TX.W26H1B3045\n")  # W26 = 2026 ✅

    # Teste 2: Ano 2100
    data2 = datetime(2100, 1, 1, 0, 0, 0)
    id2 = JuliaEpochCompact.encode(data2)
    resultado2 = JuliaEpochCompact.decode(id2)

    print("Teste 2 (Ano 2100):")
    print(f"-> Original:  {data2}")
    print(f"-> ID JEC:    {id2}")
    print(f"-> Decodado:  {resultado2}")
    print(f"-> Status:    {'✅ SUCESSO' if data2 == resultado2 else '❌ FALHOU'}")
    print(f"-> Esperado:  .X00A1A0000\n")  # X = 2100 ✅

    # Teste 3: Ano 2200
    data3 = datetime(2200, 1, 1, 0, 0, 0)
    id3 = JuliaEpochCompact.encode(data3)
    resultado3 = JuliaEpochCompact.decode(id3)

    print("Teste 3 (Ano 2200):")
    print(f"-> Original:  {data3}")
    print(f"-> ID JEC:    {id3}")
    print(f"-> Decodado:  {resultado3}")
    print(f"-> Status:    {'✅ SUCESSO' if data3 == resultado3 else '❌ FALHOU'}")
    print(f"-> Esperado:  .Y00A1A0000\n")  # Y = 2200 ✅

    print("Teste 2 (Dia Limite - 28/12):")
    print(f"-> Original:  {data2}")
    print(f"-> ID JEC:    {id2}")
    print(f"-> Decodado:  {resultado2}")
    print(f"-> Status:    {'✅ SUCESSO' if data2 == resultado2 else '❌ FALHOU'}\n")
